From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next-2.6] packet: use vzalloc()
Date: Sat, 20 Nov 2010 19:43:48 -0500
Message-ID: <20101121004348.GA29311@hmsreliant.think-freely.org>
References: <1290274314.2756.84.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:50235 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753966Ab0KUArq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Nov 2010 19:47:46 -0500
Content-Disposition: inline
In-Reply-To: <1290274314.2756.84.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 20, 2010 at 06:31:54PM +0100, Eric Dumazet wrote:
> alloc_one_pg_vec_page() is supposed to return zeroed memory, so use
> vzalloc() instead of vmalloc()
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Neil Horman <nhorman@tuxdriver.com>
Acked-by: Neil Horman <nhorman@tuxdriver.com>

Thanks Eric!

> ---
>  net/packet/af_packet.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index b6372dd..422705d 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -2367,7 +2367,7 @@ static inline char *alloc_one_pg_vec_page(unsigned long order,
>  	 * __get_free_pages failed, fall back to vmalloc
>  	 */
>  	*flags |= PGV_FROM_VMALLOC;
> -	buffer = vmalloc((1 << order) * PAGE_SIZE);
> +	buffer = vzalloc((1 << order) * PAGE_SIZE);
>  
>  	if (buffer)
>  		return buffer;
> 
> 
> 
