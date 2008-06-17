From: Josip Rodin <joy@entuzijast.net>
Subject: Re: bnx2_poll panicking kernel
Date: Wed, 18 Jun 2008 00:37:08 +0200
Message-ID: <20080617223708.GA30292@orion.carnet.hr>
References: <20080616140454.GD5350@solarflare.com> <1551EAE59135BE47B544934E30FC4FC002AABD77@nt-irva-0751.brcm.ad.broadcom.com> <20080616191354.GA11760@orion.carnet.hr> <20080616213821.GA8844@orion.carnet.hr> <20080616214829.GA9334@orion.carnet.hr> <1213659908.18055.26.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	netdev <netdev@vger.kernel.org>, mirrors@debian.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orion.CARNet.hr ([161.53.160.90]:39529 "EHLO orion.carnet.hr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758391AbYFQWhM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 18:37:12 -0400
Content-Disposition: inline
In-Reply-To: <1213659908.18055.26.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 16, 2008 at 04:45:08PM -0700, Michael Chan wrote:
> On Mon, 2008-06-16 at 23:48 +0200, Josip Rodin wrote:
> > > Crap, it just crashed again, with 2.6.25.6.
> 
> Looking at the panic dmesg, I believe it was crashing because skb was
> NULL in bnx2_tx_int().
> 
> > 
> > I should mention that I might have a clue - around the time the crashes
> > started, I started using HTB with the following configuration:
> 
> This rings a bell.  A similar crash was reported by a user using HTB on
> a tg3 device.  After some analysis, my suspicion was that the shinfo
> (skb)->nr_frags on the TX packet was corrupted before the SKB was freed
> by the driver.  In both the tg3 and bnx2 drivers, we rely on the
> nr_frags to locate the TX packet boundaries on the ring to free the
> packets.
> 
> Please try this debug patch below.  If the theory is correct, the patch
> should avoid the crash and will print something to the dmesg log every
> time a crash is avoided.  Please run it again with the HTB rules and
> send me the dmesg log containing:
> 
> bnx2: skb->nr_frags ...
> 
> Here's the debug patch below.  It saves the nr_frags from the SKB and
> uses it to locate the packet boundaries instead.  It will also compare
> the saved value with the one in SKB and print a warning when they don't
> match.  Please apply to 2.6.25.6.

After applying this patch, two rsync runs went through without any problem,
yay.

Yet, there were no alerts from the new printk in the patch...?

-- 
     2. That which causes joy or happiness.
