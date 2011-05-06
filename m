From: Phil Sutter <phil@nwl.cc>
Subject: Re: ARM, AF_PACKET: caching problems on Marvell Kirkwood
Date: Fri, 6 May 2011 18:12:09 +0200
Message-ID: <20110506161209.GB20777@orbit.nwl.cc>
References: <20110408130643.GA8730@orbit.nwl.cc>
 <20110505141107.GC30443@orbit.nwl.cc>
 <1304607362.3032.84.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	ne@erfurth.eu, Johann Baudy <johann.baudy@gnu-log.net>,
	Lennert Buytenhek <kernel@wantstofly.org>,
	Nicolas Pitre <nico@fluxnic.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([91.121.141.167]:43012 "EHLO orbit.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751615Ab1EFQML (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 May 2011 12:12:11 -0400
Content-Disposition: inline
In-Reply-To: <1304607362.3032.84.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Thu, May 05, 2011 at 04:56:02PM +0200, Eric Dumazet wrote:
> I assume you use latest linux-2.6 or net-next-2.6 ?

Well, initially we noticed the problem on 2.6.34.7, but I verified it
against both 2.6.37 and linux-2.6 from three days ago.

> Could you try to force vmalloc() use ?
> 
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index b5362e9..0b5a89c 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -2383,7 +2383,7 @@ static inline char *alloc_one_pg_vec_page(unsigned long order)
>  	gfp_t gfp_flags = GFP_KERNEL | __GFP_COMP |
>  			  __GFP_ZERO | __GFP_NOWARN | __GFP_NORETRY;
>  
> -	buffer = (char *) __get_free_pages(gfp_flags, order);
> +	buffer = NULL;
>  
>  	if (buffer)
>  		return buffer;

Thanks for the hint. I tried that, but the problem persists.

Greetings, Phil
