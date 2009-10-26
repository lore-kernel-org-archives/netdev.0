From: Tobias Oetiker <tobi-7K0TWYW2a3pyDzI6CaY1VQ@public.gmane.org>
Subject: Re: [PATCH 0/5] Candidate fix for increased number of GFP_ATOMIC
 failures V2
Date: Mon, 26 Oct 2009 18:37:36 +0100 (CET)
Message-ID: <alpine.DEB.2.00.0910261835440.24625@wbuna.brgvxre.pu>
References: <1256221356-26049-1-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Frans Pop <elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org>, Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>,
	Sven Geggus <lists-+AJD3D7QEjjt/htJsj1pd9AswbaBtrod@public.gmane.org>,
	Karol Lewandowski <karol.k.lewandowski-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Reinette Chatre <reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Kalle Valo <kalle.valo-X3B1VOXEql0@public.gmane.org>,
	David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>,
	Mohamed Abbas <mohamed.abbas-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Pekka Enberg <penberg-bbCR+/B0CizivPeTLB3BmA@public.gmane.org>,
	Bartlomiej Zolnierkiewicz <bzolnier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>,
	Stephan von Krawczynski <skraw-DcQCyzbjH0jQT0dZR+AlfA@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org\\\"" <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>
To: Mel Gorman <mel-wPRd99KPJ+uzQB+pC5nmwQ@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1256221356-26049-1-git-send-email-mel-wPRd99KPJ+uzQB+pC5nmwQ@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Mel,

I have no done additional tests ... and can report the following

Thursday Mel Gorman wrote:

>   1/5 page allocator: Always wake kswapd when restarting an allocation attempt after direct reclaim failed
>   2/5 page allocator: Do not allow interrupts to use ALLOC_HARDER
>
>
> 	These patches correct problems introduced by me during the 2.6.31-rc1
> 	merge window. The patches were not meant to introduce any functional
> 	changes but two were missed.
>
> 	If your problem goes away with just these two patches applied,
> 	please tell me.

1+2 do not help

> Test 3: If you are getting allocation failures, try with the following patch
>
>   3/5 vmscan: Force kswapd to take notice faster when high-order watermarks are being hit
>
> 	This is a functional change that causes kswapd to notice sooner
> 	when high-order watermarks have been hit. There have been a number
> 	of changes in page reclaim since 2.6.30 that might have delayed
> 	when kswapd kicks in for higher orders
>
> 	If your problem goes away with these three patches applied, please
> 	tell me

1+2+3 do not help either

> Test 4: If you are still getting failures, apply the following
>   4/5 page allocator: Pre-emptively wake kswapd when high-order watermarks are hit
>
> 	This patch is very heavy handed and pre-emptively kicks kswapd when
> 	watermarks are hit. It should only be necessary if there has been
> 	significant changes in the timing and density of page allocations
> 	from an unknown source. Tobias, this patch is largely aimed at you.
> 	You reported that with patches 3+4 applied that your problems went
> 	away. I need to know if patch 3 on its own is enough or if both
> 	are required
>
> 	If your problem goes away with these four patches applied, please
> 	tell me

3 allone does not help
3+4 does ...

cheers
tobi
-- 
Tobi Oetiker, OETIKER+PARTNER AG, Aarweg 15 CH-4600 Olten, Switzerland
http://it.oetiker.ch tobi-7K0TWYW2a3pyDzI6CaY1VQ@public.gmane.org ++41 62 775 9902 / sb: -9900
