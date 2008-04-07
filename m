From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC] fib_trie: memory waste solutions
Date: Mon, 7 Apr 2008 17:15:03 +0200
Message-ID: <20080407151503.GD16647@one.firstfloor.org>
References: <20080401172702.094c0700@extreme> <47F33D42.9080302@cosmosbay.com> <47F39998.8040605@cosmosbay.com> <20080402110335.66b04181@extreme> <47F3E031.1030806@cosmosbay.com> <20080404090257.2ec38b0c@extreme> <18425.50538.876583.892728@robur.slu.se> <87bq4mrt9v.fsf@basil.nowhere.org> <18426.13019.345218.79888@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org
To: Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:42498 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752011AbYDGPKp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2008 11:10:45 -0400
Content-Disposition: inline
In-Reply-To: <18426.13019.345218.79888@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 07, 2008 at 04:42:35PM +0200, Robert Olsson wrote:
> 
> Andi Kleen writes:
> 
>  > >  Do we get slower with vmalloc due to TLB-lookups etc? Guess this
>  > >  should be investigated.
>  > 
>  > In some cases it might even go faster because a lot of x86 CPUs
>  > have far more 4K TLBs than 2M TLBs. vmalloc is just quite expensive
>  > in setup/free time, but that shouldn't be a big issue here.
> 
> 
>  I've did some rDoS testing and the lookup performance is the same or 
>  slightly better. So it should be fine.  

If you want more realistic worst case numbers run something in user space in 
the background that thrashes the TLBs constantly and then see how
the numbers change.

The main advantage of using large pages is that they tend to be separated
from 4K TLBs and since most user space doesn't use large pages it 
gives the kernel an effective private TLB pool.

With vmalloc it will now compete with whatever other TLB pigs are active.

-Andi
