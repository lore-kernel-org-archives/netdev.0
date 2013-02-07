From: Joe Perches <joe@perches.com>
Subject: Re: [RFC PATCH] tg3: Convert chip type macros to inline functions
Date: Wed, 06 Feb 2013 17:05:38 -0800
Message-ID: <1360199138.12464.37.camel@joe-AO722>
References: <1360194298.12464.35.camel@joe-AO722>
	 <1360197671.796.3.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Hauke Mehrtens <hauke@hauke-m.de>,
	mcarlson@broadcom.com, nsujir@broadcom.com
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:44015 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755435Ab3BGBFl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2013 20:05:41 -0500
In-Reply-To: <1360197671.796.3.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-02-06 at 16:41 -0800, Michael Chan wrote:
> On Wed, 2013-02-06 at 15:44 -0800, Joe Perches wrote:
> > There are several macros that are used for
> > chip identification.
> > 
> > Perhaps it'd be better to use static inlines
> > instead of these macros as the code becomes a
> > bit more readable with less uppercase use.
[]
> > #define GET_ASIC_REV(CHIP_REV_ID)       ((CHIP_REV_ID) >> 12)
> > 
> > becomes:
> > 
> > static inline u32 tg3_asic_rev(const struct tg3 *tp)
> > {
> >         return tp->pci_chip_rev_id >> 12;
> > }

[]

> I think these don't have to be inline.  there is only one call in the
> fast path that I can see (tg3_start_xmit), and we can easily change that
> to test for a flag instead.  I wonder if that will make it smaller.

Nope.

Even if you make it static in tg3.c,
gcc inlines it anyway.
