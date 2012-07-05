From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: BISECTED: Re: REGRESSION: 3.4.0->3.5.0-rc2 kernel WARNING on cable
 plug on Acer Aspire One, no network
Date: Thu, 05 Jul 2012 08:58:03 +0200
Message-ID: <012601cd5a7b$886fd4c0$994f7e40$%szyprowski@samsung.com>
References: <4FF25A05.7050007@palosanto.com> <4FF25CC2.3050101@palosanto.com>
 <03be01cd58de$6c2a06d0$447e1470$%szyprowski@samsung.com>
 <4FF30129.5000702@palosanto.com>
 <000901cd59b2$f2a542e0$d7efc8a0$%szyprowski@samsung.com>
 <4FF514B2.4050000@palosanto.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: =?utf-8?Q?'Alex_Villac=C3=ADs_Lasso'?= <a_villacis@palosanto.com>,
	'Francois Romieu' <romieu@fr.zoreil.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:14832 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750931Ab2GEG63 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2012 02:58:29 -0400
Received: from epcpsbgm2.samsung.com (mailout2.samsung.com [203.254.224.25])
 by mailout2.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M6O00F13E13Z7P0@mailout2.samsung.com> for
 netdev@vger.kernel.org; Thu, 05 Jul 2012 15:58:25 +0900 (KST)
Received: from AMDC159 ([106.116.147.30])
 by mmp1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0M6O00FYPE0T7250@mmp1.samsung.com> for netdev@vger.kernel.org;
 Thu, 05 Jul 2012 15:58:25 +0900 (KST)
In-reply-to: <4FF514B2.4050000@palosanto.com>
Content-language: pl
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Thursday, July 05, 2012 6:15 AM Alex Villac=C3=ADs Lasso wrote:

> El 04/07/12 02:02, Marek Szyprowski escribi=C3=B3:
> > Hello,
> >
> > On Tuesday, July 03, 2012 4:27 PM Alex Villac=C3=AD=C2=ACs Lasso wr=
ote:
> >
> >> El 03/07/12 00:40, Marek Szyprowski escribi=C3=B3:
> >>> Hi Alex,
> >>>
> >>> On Tuesday, July 03, 2012 4:45 AM Alex Villac=C3=ADs Lasso wrote:
> >>>
> >>>> -------- Mensaje original --------
> >>>> Asunto:  BISECTED: Re: REGRESSION: 3.4.0->3.5.0-rc2 kernel WARNI=
NG on cable
> >>>> plug on Acer Aspire One, no network Fecha:  Mon, 02 Jul 2012 21:=
33:41 -0500 De:
> >>>>    Alex Villac=C3=ADs Lasso <a_villacis@palosanto.com> Para:  Fr=
ancois Romieu
> >>>> <romieu@fr.zoreil.com> CC:  netdev@vger.kernel.org
> >>>> El 01/07/12 08:50, Alex Villac=C3=ADs Lasso escribi=C3=B3:
> >>>>> El 11/06/12 16:38, Francois Romieu escribi=C3=B3:
> >>>>>> Alex Villac=C3=ADs Lasso <a_villacis@palosanto.com> :
> >>>>>> [...]
> >>>>>>> $ grep XID dmesg-3.5.0-rc2.txt
> >>>>>>> [   15.873858] r8169 0000:02:00.0: eth0: RTL8102e at 0xf7c0e0=
00,
> >>>>>>> 00:1e:68:e5:5d:b1, XID 04a00000 IRQ 44
> >>>>>> The 8102e has not been touched by that many suspect patches bu=
t I do
> >>>>>> not see where the problem is :o(
> >>>>>>
> >>>>>> Can you peel off the r8169 patches between 3.4.0 and 3.5-rc ?
> >>>>>>
> >>>>> Still present in 3.5-rc5. Bisection still in progress.
> >>>>>
> >>>>> --
> >>>>> To unsubscribe from this list: send the line "unsubscribe netde=
v" in
> >>>>> the body of a message to majordomo@vger.kernel.org
> >>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.h=
tml
> >>>> My full bisection points to this commit:
> >>>>
> >>>> commit 0a2b9a6ea93650b8a00f9fd5ee8fdd25671e2df6
> >>>> Author: Marek Szyprowski <m.szyprowski@samsung.com>
> >>>> Date:   Thu Dec 29 13:09:51 2011 +0100
> >>>>
> >>>>       X86: integrate CMA with DMA-mapping subsystem
> >>>>
> >>>>       This patch adds support for CMA to dma-mapping subsystem f=
or x86
> >>>>       architecture that uses common pci-dma/pci-nommu implementa=
tion. This
> >>>>       allows to test CMA on KVM/QEMU and a lot of common x86 box=
es.
> >>>>
> >>>>       Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> >>>>       Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> >>>>       CC: Michal Nazarewicz <mina86@mina86.com>
> >>>>       Acked-by: Arnd Bergmann <arnd@arndb.de>
> >>>>
> >>>> Is this commit somehow messing with the network card DMA?
> >>> This commit in fact touches DMA-mapping subsystem and introduces =
a bug,
> >>> which has been finally fixed by commit c080e26edc3a2a3 merged to =
v3.5-rc3.
> >>> After applying it the DMA-mapping subsystem should work exactly t=
he same was
> >>> as in v3.4. Could you please check if it fixes this issue?
> >>>
> >>> Best regards
> >> No. It still fails in 3.5-rc5, as mentioned before.
> > Hmm. I was a bit confused, because both the subject and git bisect =
log pointed to v3.5-rc2,
> > which had that bug. Maybe there is one some other issue present in =
v3.5-rc5 not related to
> > my patches?
> >
> > Could you check with v3.5-rc5 if reverting patch c080e26edc3a2a3cdf=
a4c430c663ee1c3bbd8fae
> > and 0a2b9a6ea93650b8a00f9fd5ee8fdd25671e2df6 fixes the problems wit=
h rtl driver?
> >
> > Best regards
> Reverting the two patches indeed fixes the bug on -rc5.

That's really strange. Could you check if you have CMA disabled in the =
config? After preparing
a c080e26edc3a2a3cdfa4c430c663ee1c3bbd8fae fixup patch, I was really co=
nvinced that there are
no functional changes in x86 dma mapping code when CMA is disabled. I w=
ill provide some=20
patches to revert different parts of my changes, so we will find which =
line causes issues.

Best regards
--=20
Marek Szyprowski
Samsung Poland R&D Center
