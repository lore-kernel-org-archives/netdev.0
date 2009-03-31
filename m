From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Subject: Re: [PATCH] ucc_geth: Rework the TX logic.
Date: Tue, 31 Mar 2009 11:07:36 +0200
Message-ID: <OFEAA9D1E3.4B2F3270-ONC125758A.00307236-C125758A.00322239@transmode.se>
References: <1238089445-28396-1-git-send-email-Joakim.Tjernlund@transmode.se>	<2a27d3730903270245k6e8633eehfb5cd3fcebd36240@mail.gmail.com> <OFDCE90357.0EDC5DC1-ONC1257586.003759A3-C1257586.00390AD3@transmode.se> <49CCD3E8.9040007@freescale.com> <OFEFCEAFB5.CC21FFBB-ONC1257589.005AEF16-C1257589.005B64EB@transmode.se> <49D0FFBB.7000009@freescale.com> <OF3127420C.081D4097-ONC1257589.00603E3D-C1257589.006093B3@transmode.se> <49D1052D.2050609@freescale.com> <OF70832E04.3DC53F05-ONC1257589.00663AFF-C1257589.0066C397@transmode.se> <49D11E47.8080106@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Li Yang <leoli@freescale.com>, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, pku.leo@gmail.com
To: Scott Wood <scottwood@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([213.115.205.20]:52258 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753880AbZCaJHj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Mar 2009 05:07:39 -0400
In-Reply-To: <49D11E47.8080106@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Scott Wood <scottwood@freescale.com> wrote on 30/03/2009 21:32:23:
> 
> Joakim Tjernlund wrote:
> >> different since descriptors are in MURAM which is ioremap()ed -- 
though 
> >> switching to a cacheable mapping with barriers should be a 
performance 
> >> improvement.
> > 
> > I always thought that MURAM was very fast. The whole reason to have 
BDs in
> > MURAM is that it is faster than normal RAM, at least that is what I 
> > thought.
> 
> Yeah, on second thought it probably wouldn't be worth it.  There's also 
> the question of under what circumstances the QE's MURAM accesses will be 

> cache-coherent.

I am a bit confused, what isn't worth it? Currently MURAM isn't used by 
ucc_geth, but
it is easy to change. Swap MEM_PART_SYSTEM to MEM_PART_MURAM, however, 
just
tried that and the driver stopped working. I known this worked earlier 
because
I tried it and I even think I sent a patch to Leo.

What choices do we have, I see three:

1) MEM_PART_SYSTEM, as today.
2) MEM_PART_MURAM. I guess this should be uncacheable memory?
3) as gianfar, dma_alloc_coherent(). I presume this is uncacheable memory?

My guess would be 2 or 3. Do they have the same synchronization
sematics?

> 
> As for the CPU not reordering guarded+cache inhibited accesses, that 
> initially seemed to be true for the new arch stuff (book3e/book3s, but 
> not really, see below), but the classic arch documentation only 
> guarantees stores to such regions to be in-order (and the 
> explicitly-specified operation of eieio on I+G accesses wouldn't make 
> much sense if they were already guaranteed to be in-order).
> 
> Then I looked at the EREF to see what older book E documents had to say 
> on the issue, and it suggests that when the architecture document says 
> "out of order", it really means "speculative" (and reading the arch 
> doc's definition of "out of order" seems to confirm this -- redefining 
> terms is bad, m'kay?).  So it seems that the simple answer is no, 
> guarded storage is not guaranteed to be in order, unless the only thing 
> that can cause an out-of-order access is speculative execution.

Very informative, thanks.

