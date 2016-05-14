From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] nf_conntrack: avoid kernel pointer value leak in slab
 name
Date: Sat, 14 May 2016 23:33:22 +0200
Message-ID: <20160514213322.GD9763@1wt.eu>
References: <alpine.LFD.2.20.1605141116100.24646@i7>
 <CA+55aFx_PuzNC0riLEN7PUpVnvQg374ZqCYBV-Uw6Be-OA=DwQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Network Development List <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wtarreau.pck.nerim.net ([62.212.114.60]:28632 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753913AbcENVd3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 May 2016 17:33:29 -0400
Content-Disposition: inline
In-Reply-To: <CA+55aFx_PuzNC0riLEN7PUpVnvQg374ZqCYBV-Uw6Be-OA=DwQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 14, 2016 at 02:31:04PM -0700, Linus Torvalds wrote:
> On Sat, May 14, 2016 at 11:24 AM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
> >
> >
> > -       net->ct.slabname = kasprintf(GFP_KERNEL, "nf_conntrack_%p", net);
> > +       net->ct.slabname = kasprintf(GFP_KERNEL, "nf_conntrack_%llu",
> > +                               (u64)atomic64_inc_return(&unique_id));
> 
> Oh well. I suspect this is going to cause a new warning on alpha and
> ia64 and possibly others.
> 
> "u64" is indeed "unsigned long long" on x86 and many other
> architectures, but on alpga and ia64 it's just "unsigned long".
> 
> So that case should have been to "long long". I detest how there isn't
> a "64-bit size" printf specifier.

Why simply not cast the atomic to (unsigned long long) instead of (u64)
so that %llu always matches ?

Willy
