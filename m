From: "David S. Miller" <davem@davemloft.net>
Subject: Re: An interface goes away while a socket is bound to it..what
 happens?
Date: Mon, 17 Jan 2005 19:39:45 -0800
Message-ID: <20050117193945.3d3b1860.davem@davemloft.net>
References: <41EC825B.4030603@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <41EC825B.4030603@candelatech.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 17 Jan 2005 19:28:27 -0800
Ben Greear <greearb@candelatech.com> wrote:

> The interesting part to me is that I do not appearantly see any errors
> while continuing to send UDP packets on the socket that was bound to the
> original ppp0 interface, and yet no packets are ever routed over the new
> ppp0 interface.  I would expect it to either fail the write, or to just
> magically keep working.

If you have bound to the local IP address, when your T1 goes down
that local IP address should no longer be assosciated with the
system even when the PPP interface comes back up, so what should
happen is that the route lookup in udp_sendmsg() will fail and sendmsg()
will return with that error code.
