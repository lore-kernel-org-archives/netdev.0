From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: 2.6.7-rc3: waiting for eth0 to become free
Date: Thu, 10 Jun 2004 08:36:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040610083652.6f3ba3a6@dell_ss3.pdx.osdl.net>
References: <1086722310.1682.1.camel@teapot.felipe-alfaro.com>
	<20040608124215.291a7072@dell_ss3.pdx.osdl.net>
	<1086725369.1806.1.camel@teapot.felipe-alfaro.com>
	<20040608140200.2ddaa6f4@dell_ss3.pdx.osdl.net>
	<1086794282.1706.2.camel@teapot.felipe-alfaro.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: NetDev Mailinglist <netdev@oss.sgi.com>,
        Kernel Mailinglist
 <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Felipe Alfaro Solana <felipe_alfaro@linuxmail.org>
In-Reply-To: <1086794282.1706.2.camel@teapot.felipe-alfaro.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 09 Jun 2004 17:18:02 +0200
Felipe Alfaro Solana <felipe_alfaro@linuxmail.org> wrote:

> On Tue, 2004-06-08 at 14:02 -0700, Stephen Hemminger wrote:
> > On Tue, 08 Jun 2004 22:09:29 +0200
> > Felipe Alfaro Solana <felipe_alfaro@linuxmail.org> wrote:
> > 
> > > On Tue, 2004-06-08 at 12:42 -0700, Stephen Hemminger wrote:
> > > > On Tue, 08 Jun 2004 21:18:30 +0200
> > > > Felipe Alfaro Solana <felipe_alfaro@linuxmail.org> wrote:
> > > > 
> > > > > Hi!
> > > > > 
> > > > > On my laptop, when using a CardBus 3c59x-based NIC, I need to run
> > > > > "cardctl eject" so the system won't freeze when resuming. "cardctl
> > > > > eject" worked fine in 2.6.7-rc2-mm2, even when there were programs with
> > > > > network sockets opened (for example, Evolution mantaining a connection
> > > > > against an IMAP server): the card is ejected (well, not physically),
> > > > > even when there are ESTABLISHED connections.
> > > > > 
> > > > > However, starting with 2.6.7-rc3, "cardctl eject" hangs if a program
> > > > > holds any socket open. After a while the "unregister_netdevice: waiting
> > > > > for eth0 to become free" message starts appearing on the kernel message
> > > > > ring. The only apparent solution is killing that program, ejecting the
> > > > > card from its slot and wait until 3c59x.o usage count reaches zero.
> > > > > 
> > > > > Can someone tell me what's going on here?
> > > > > Thank you very much.
> > > > 
> > > > What protocols are you running? Is IPV6 loaded?
> > > 
> > > I'm using IPv4, IPv6 and IPSec ESP with AES/CBC.
> > > Do you want .config?
> > 
> > Not really, could you see if it is an IPv6 vs IPSec problem by not running/loading
> > one or the other.
> > 
> > What is happening is that some subsystem is holding a reference to the device (calling dev_hold())
> > but not cleaning up (calling dev_put).  It can be a hard to track which of the many
> > things routing, etc are not being cleared properly.  Look for routes that still
> > get stuck (ip route) and neighbor cache entries.  Most of these end up being
> > protocol bugs.
> 
> The two attached patches, one for net/ipv4/route.c, the other for net/
> ipv6/route.c fix all my problems when running "cardctl eject" while a
> program mantains an open network socket (ESTABLISHED).
> 
> Both patches apply cleanly against 2.6.7-rc3 and 2.6.7-rc3-mm1.
> I'm not completely sure what has changed in 2.6.7-rc3 that is breaking
> cardctl for me, as it Just Worked(TM) fine in 2.6.7-rc2.
> 
> Hope this can throw some light at this issue.

Since you effectively remove rth->idev, why not remove it from the structure
to make sure no code is still expecting it to be set.
