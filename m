From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: netif_rx packet dumping
Date: Fri, 4 Mar 2005 04:31:07 +0100
Message-ID: <20050304033107.GD29058@xi.wantstofly.org>
References: <20050303132143.7eef517c@dxpl.pdx.osdl.net> <1109885065.1098.285.camel@jzny.localdomain> <20050303133237.5d64578f.davem@davemloft.net> <20050303135416.0d6e7708@dxpl.pdx.osdl.net> <Pine.LNX.4.58.0503031657300.22311@tesla.psc.edu> <1109888811.1092.352.camel@jzny.localdomain> <20050303151606.3587394f@dxpl.pdx.osdl.net> <Pine.LNX.4.58.0503031818270.22311@tesla.psc.edu> <20050304014227.GB28874@xi.wantstofly.org> <Pine.LNX.4.58.0503032116020.28187@tesla.psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>, baruch@ev-en.org,
        netdev@oss.sgi.com
To: John Heffner <jheffner@psc.edu>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0503032116020.28187@tesla.psc.edu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Mar 03, 2005 at 10:10:55PM -0500, John Heffner wrote:

> The forwarding case where you actually need congestion control, as
> opposed to absorbing bursts, is pretty gross.  If you have a router
> (more likely firewall) whose bottleneck is the CPU, then you're
> operating entirely in you input queue.  Yuck.

Yes.  This does happen under DoS (or just if your hardware is plain
underspec'ed), and even though you can't really avoid interrupt
livelock and starving userland processes when you're using a non-NAPI
driver (which is what we're talking about here), you don't want to go
OOM as well.

Removing the backlog is a problem also for the non-forwarding case --
you don't want someone to be able to OOM your server just by flooding
it with enough packets.  ("Wait, I can't drop those, those might be
legitimate ACKs!")


--L
