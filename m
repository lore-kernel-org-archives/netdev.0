From: Yuval Mintz <yuvalmin@broadcom.com>
Subject: RE: bnx2x_sriov.c: Missing switch/case breaks?
Date: Sat, 14 Dec 2013 13:26:19 +0000
Message-ID: <979A8436335E3744ADCD3A9F2A2B68A52AF1A7FF@SJEXCHMB10.corp.ad.broadcom.com>
References: <1386975703.2479.48.camel@joe-AO722>
	 <979A8436335E3744ADCD3A9F2A2B68A52AF1A735@SJEXCHMB10.corp.ad.broadcom.com>
 <1387004267.2276.7.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Ariel Elior <ariele@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:3413 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753855Ab3LNN0W convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Dec 2013 08:26:22 -0500
In-Reply-To: <1387004267.2276.7.camel@joe-AO722>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > > Hi Ariel.
> > >
> > > I wrote a little checkpatch script to look for missing
> > > switch/case breaks.
> > >
> > > http://www.kernelhub.org/?msg=379933&p=2
> > >
> > > There are _many_ instances of case blocks in sriov.c
> > > that could be missing breaks as they use fall-throughs.
> > >
> > > It would be good if these are actually intended to be
> > > fall-throughs to add a /* fall-through */ comment between
> > > each case block.
> > >
> > Hi Joe,
> 
> Hi Yuval.
> 
> > The `vfop' part of the code contains a lot of usage of the
> `bnx2x_vfop_finalize()',
> > which either goto or return at the end of almost every case.
> > "Normal" analysis tools/scripts fail to recognize them as  valid case
> breaks.
> >
> > Adding `fallthrough' comments would make little sense, as this is not the
> real
> > behavior; Perhaps we need some alternative comment? (something in the
> line
> > of `macro case break')
> 
> No idea.  It's certainly an ugly macro.
> 

True.

> This does have a fallthrough path though when
> (rc == 0  && next == VFOP_VERIFY_PEND) so

This is a very rare path - there's exactly one place in the bnx2x code
Where `next == VFOP_VERIFY_PEND' (also notice this path prints an
error, so this is obviously not the expected behaviour).

> maybe there should be a break after most all
> uses of this macro anyway.  When next is

Won't some static code analysis tools regard such `break' calls as
unreachable code?

> VFOP_VERIFY_PEND, then a "fall-through" comment
> would be appropriate.
> 
> cheers, Joe

Thanks,
Yuval
