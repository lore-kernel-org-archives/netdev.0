From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] support for large number of network devices.
Date: Tue, 13 Jan 2004 15:59:21 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040113155921.342db463.davem@redhat.com>
References: <20040113154610.38f5934c.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040113154610.38f5934c.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 13 Jan 2004 15:46:10 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> When using pseudo network devices, and really big machines; there is
> sometimes a need to have a lot of network devices.  This replaces the
> existing 2.6.1 limit of 100 entries an was O(n^2)
> with a algorithm that will handle up to 32768 entries with O(n) behaviour.
> 
> Does need a temporary page, but that shouldn't be a big deal.
> It has the same semantics, it will find the first empty name and use it.

I think your code has different semantics than exist currently.

For example, let's use the example of asking for "slip%d" then "eth%d".
The existing code would hand out "slip0" then "eth0", but your code would
deliver "slip0" then "eth1" which is not correct.

Or did I miss something clever in your algorithm?
