From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] panic during unregister_netdevice()
Date: Wed, 5 Nov 2003 16:33:50 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031105163350.66bf2763.davem@redhat.com>
References: <Pine.LNX.4.44.0311051558350.1359-100000@DYN318430BLD.beaverton.ibm.com>
	<20031105163025.796cc462.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: krkumar@us.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20031105163025.796cc462.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 5 Nov 2003 16:30:25 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> Hey, what if the dev refcount goes to zero before your dev_hold?
> Actually this repeated notifier looks like it wouldn't work anyway.
> Why would a protocol drop it's reference when notified a second time?
> 
> I would argue even running the loop once means some protocol is busted.

If the loops runs once or twice that is not a bug, it is possible for
processes to grab onto the device via rtnetlink queries and similar
and we have to pause and potentially schedule to deal with that.

The core problem is that we end up putting the device reference to
zero a second time, and for that reason we should prevent it by
holding onto a reference around the entire loop and wait for the
refcount to drop to '1'.

That would fix the bug wouldn't it?
