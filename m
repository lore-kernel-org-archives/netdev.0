From: Stefan Becker <chemobejk@gmail.com>
Subject: Re: [PATCH] r8169: Fix WOL in power down case
Date: Tue, 1 Nov 2011 17:28:46 +0000 (UTC)
Message-ID: <loom.20111101T174532-579@post.gmane.org>
References: <20111007221906.810698ba9bf825566a2478bb@gmx.de> <20111007210017.GA27820@electric-eye.fr.zoreil.com> <20111007214200.GA28365@electric-eye.fr.zoreil.com> <20111008003156.ef4dfaa76576ca8079edfbb9@gmx.de> <20111007232834.GA29770@electric-eye.fr.zoreil.com> <20111009104907.0c6cd439900ca5eb7789295f@gmx.de> <20111009115438.GA12343@electric-eye.fr.zoreil.com> <20111009191331.cbfca0b6b724921f35fd8c41@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:51660 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753691Ab1KARaI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Nov 2011 13:30:08 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1RLIA0-00066G-Lk
	for netdev@vger.kernel.org; Tue, 01 Nov 2011 18:30:04 +0100
Received: from 86-60-137-83-dyn-dsl.ssp.fi ([86.60.137.83])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2011 18:30:04 +0100
Received: from chemobejk by 86-60-137-83-dyn-dsl.ssp.fi with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2011 18:30:04 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marc Ballarin <ballarin.marc <at> gmx.de> writes:
> 
> On Sun, 9 Oct 2011 13:54:38 +0200
> Francois Romieu <romieu <at> fr.zoreil.com> wrote:
> 
> > ...
> > Moreover, the patch duplicates a chunk of conditional code:
> > 1) it bloats the driver (ok, we have seen worse...).
> > 2) you can bet that both instances won't be updated if / when
> >    RTL_GIGA_MAC_VER_xy appears.
> 
> I thought so 
> 
> > 
> > The patch below should fix it.
> 
> Yes, it works fine here. Thanks a lot.
> 

I just upgraded to Fedora 16 with Kernel 3.1.0 and WoL stopped working in the
power down case on my R8168 :-(

[    8.557372] r8169 0000:02:00.0: eth0: RTL8168c/8111c at 0xf809a000,
00:1f:d0:5a:22:77, XID 1c4000c0 IRQ 43

02:00.0 Ethernet controller [0200]: Realtek Semiconductor Co., Ltd.
RTL8111/8168B PCI Express Gigabit Ethernet controller [10ec:8168] (rev 02)

I've checked the SRPM and git commit 649b3b8c4e868 with the fix discussed here
is included. It obviously doesn't work for my HW.

According to the code the combination "RTL8168c/8111c" means RTL_GIGA_MAC_VER_19
to _22, so the code changes in the fix commit don't apply to them. Could it be
that the fix doesn't cover all the necessary HW?

Regards,

           Stefan

PS: Please CC me in your reply, as I don't read the mailing list.
