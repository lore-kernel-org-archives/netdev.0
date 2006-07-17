From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 3/7] NetLabel: CIPSOv4 engine
Date: Sun, 16 Jul 2006 22:42:07 -0400
Message-ID: <200607162242.08622.paul.moore@hp.com>
References: <20060714185915.270209000@flek.zko.hp.com> <200607161210.44873.paul.moore@hp.com> <20060716.181230.59471240.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, netdev@vger.kernel.org, selinux@tycho.nsa.gov,
	sds@epoch.ncsc.mil, pratt@argus-systems.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.cce.hp.com ([161.114.21.22]:46271 "EHLO
	ccerelrim01.cce.hp.com") by vger.kernel.org with ESMTP
	id S932224AbWGQCmW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Jul 2006 22:42:22 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060716.181230.59471240.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 16 July 2006 9:12 pm, David Miller wrote:
> From: Paul Moore <paul.moore@hp.com>
> Date: Sun, 16 Jul 2006 12:10:44 -0400
>
> > On Friday 14 July 2006 10:03 pm, James Morris wrote:
> > > On Fri, 14 Jul 2006, paul.moore@hp.com wrote:
> > > > +/**
> > > > + * cipso_v4_bitmap_walk - Walk a bitmap looking for a bit
> > > >
> > > > + * cipso_v4_bitmap_setbit - Sets a single bit in a bitmap
> > >
> > > Can you use lib/bitmap.c instead?
> >
> > Looking again at include/asm/bitops.h I think I now remember why I
> > decided not to use them in the first place.
>
> lib/bitmap.c and the asm/bitops.h operations are two entirely
> different animals.

I probably should have been more clear - I didn't see anything in lib/bitmap.c 
(or include/linux/bitmap.h) that I think would have been useful.  However, 
include/linux/bitmap.h makes reference to asm/bitops.h which does have some 
function which may have been useful if they didn't have the length 
restrictions.

> Wrt. your asm/bitops.h concerns, is there any reason you cannot pad
> out your bitmaps to be a modulo of "long" which is required for
> those routines?

Right now I use both the bitmap_walk() and bitmap_setbit() routines to deal 
with both CIPSO tags straight from the sk_buff as well as the internal bitmap 
representation.  Padding out the internal bitmaps would require some code 
changes but there isn't much I can do about the packet I don't believe.  True 
it would probably be okay for most packets to assume you could access an 
entire "long"s worth of memory but then again it would only take one evil 
packet to start causing problems ...

-- 
paul moore
linux security @ hp
