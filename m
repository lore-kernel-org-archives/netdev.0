From: Martin Michlmayr <tbm@cyrius.com>
Subject: Re: [PATCH 12/21] r8169: confusion between hardware and IP header
	alignment
Date: Mon, 26 Nov 2007 09:36:13 +0100
Message-ID: <20071126083613.GL20922@deprecation.cyrius.com>
References: <20070629201212.GA3240@electric-eye.fr.zoreil.com> <20070629202555.GN3240@electric-eye.fr.zoreil.com> <20071123074549.GE18081@deprecation.cyrius.com> <20071125230524.GC21363@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Edward Hsu <edward_hsu@realtek.com.tw>,
	bunk@stusta.de
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sorrow.cyrius.com ([65.19.161.204]:4152 "EHLO sorrow.cyrius.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753202AbXKZIgd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Nov 2007 03:36:33 -0500
Content-Disposition: inline
In-Reply-To: <20071125230524.GC21363@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Francois Romieu <romieu@fr.zoreil.com> [2007-11-26 00:05]:
> > I'd like to backport the fix to the 2.6.18 kernel that is in our
> > stable release and have a couple of questions:
> >  - Does your later patch "align the IP header when there is no DMA
> >    constraint" fix any bugs or is it merely an improvement?
> It fixes a "it was faster before" problem.

Before the patch I'm interested in backporting, right?  In that case,
the patch I suggested would fix a bug but also introduce a performance
regression.  So maybe the later patch should also be backported.  What
do you think?

> >  - Should I change "align" to 8 for RTL_CFG_1, as it's done in
> >    current kernels?
> No. RTL_CFG_1 is for the 8168 (slightly different beast).

Yes, but might 8168 users face similar problems as the one I saw?

> If you have 6dccd16b7c2703e8bbf8bca62b5cf248332afbe2 applied, you
> want c946b3047205d7e107be16885bbb42ab9f10350a too.
...
> If you move from the 8110SB to the 8110SC, you will probably want to apply
> 65d916d95314566f426cc40ff0f17b754a773b0b

I don't have 6dccd16b7c2703e8bbf8bca62b5cf248332afbe2 and it still
says 8110SB, so I won't need these patches for my device.  However,
these patches look like candidates to put into 2.6.18 anyway.  I'd
like to avoid backporting too many changes from 2.6.24 to 2.6.18, but
are there any fixes we should absolutely have?

> Btw, could you send me a dmesg from a recent kernel ? I'd like to keep a
> trace of the XID value for your device.

With 2.6.24-rc2-g8c086340-dirty:
r8169 Gigabit Ethernet driver 2.2LK loaded
eth0: RTL8169sb/8110sb at 0xe085c200, 00:14:fd:10:33:8e, XID 10000000 IRQ 27
r8169 Gigabit Ethernet driver 2.2LK loaded
eth1: RTL8169sb/8110sb at 0xe085e300, 00:14:fd:10:33:8f, XID 10000000 IRQ 30

-- 
Martin Michlmayr
http://www.cyrius.com/
