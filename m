From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 3/7] NetLabel: CIPSOv4 engine
Date: Sun, 16 Jul 2006 12:10:44 -0400
Message-ID: <200607161210.44873.paul.moore@hp.com>
References: <20060714185739.780700000@flek.zko.hp.com> <20060714185915.270209000@flek.zko.hp.com> <Pine.LNX.4.64.0607142202380.19821@d.namei>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov,
	"David S. Miller" <davem@davemloft.net>, sds@epoch.ncsc.mil,
	pratt@argus-systems.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.hp.com ([192.151.27.10]:19647 "EHLO mailhub.hp.com")
	by vger.kernel.org with ESMTP id S1751281AbWGPQKx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Jul 2006 12:10:53 -0400
To: James Morris <jmorris@namei.org>
In-Reply-To: <Pine.LNX.4.64.0607142202380.19821@d.namei>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 14 July 2006 10:03 pm, James Morris wrote:
> On Fri, 14 Jul 2006, paul.moore@hp.com wrote:
> > +/**
> > + * cipso_v4_bitmap_walk - Walk a bitmap looking for a bit
> >
> > + * cipso_v4_bitmap_setbit - Sets a single bit in a bitmap
>
> Can you use lib/bitmap.c instead?

Looking again at include/asm/bitops.h I think I now remember why I decided not 
to use them in the first place.  At least on the x86 side it looks like the 
underlying btsl instruction may access an entire word when the bitmap may 
only by a byte long.  I imagine in the practical sense it probably wouldn't 
be too serious of an issue, but there are too many corner cases here for me 
to be able to say for certain so I'll defer to the experts here.

If it is safe it shouldn't be too difficult to use the set/clear_bit() 
functions in cipso_v4_bitmap_setbit() and the find_*_bit() functions in 
cipso_v4_bitmap_walk().

As an aside, I've made the other changes you suggested but I won't have a 
chance to test them until Monday morning.  Assuming all goes well during some 
quick testing I'll post a new patchset around mid-day on Monday.

-- 
paul moore
linux security @ hp
