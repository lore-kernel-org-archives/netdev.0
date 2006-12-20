From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH][RFC] tcp: fix ambiguity in the `before' relation
Date: Wed, 20 Dec 2006 20:01:00 +0000
Message-ID: <20061220200100.GA27176@infradead.org>
References: <200612141507.06888@strip-the-willow>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:54238 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030342AbWLTUBD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Dec 2006 15:01:03 -0500
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Content-Disposition: inline
In-Reply-To: <200612141507.06888@strip-the-willow>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 14, 2006 at 03:07:06PM +0000, Gerrit Renker wrote:
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index c99774f..b7d8317 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -242,14 +242,9 @@ extern int tcp_memory_pressure;
>  
>  static inline int before(__u32 seq1, __u32 seq2)
>  {
> -        return (__s32)(seq1-seq2) < 0;
> +        return (__s32)(seq2-seq1) > 0;
>  }
> -
> -static inline int after(__u32 seq1, __u32 seq2)
> -{
> -	return (__s32)(seq2-seq1) < 0;
> -}
> -
> +#define after(seq2, seq1) 	before(seq1, seq2)

Btw, these macfox/inlines are named quite a bit too generic for
something that is in tcp.h

