From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH RFC 2/3] ipv4: make flow functions more grepable by
 removing flowi4_update_output
Date: Tue, 14 Jun 2016 09:04:14 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1606140902240.2467@ja.home.ssi.bg>
References: <1465850858-8559-1-git-send-email-hannes@stressinduktion.org> <1465850858-8559-3-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, dsa@cumulusnetworks.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:55132 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750987AbcFNGEV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2016 02:04:21 -0400
In-Reply-To: <1465850858-8559-3-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Mon, 13 Jun 2016, Hannes Frederic Sowa wrote:

> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>  include/net/flow.h              | 11 -----------
>  include/net/route.h             |  8 ++++----
>  net/netfilter/ipvs/ip_vs_xmit.c |  9 +++++++--
>  net/sctp/protocol.c             | 10 ++++------
>  4 files changed, 15 insertions(+), 23 deletions(-)
> 
> diff --git a/include/net/flow.h b/include/net/flow.h
> index 2c8e95b987c98c..6276a81f7b3d13 100644
> --- a/include/net/flow.h
> +++ b/include/net/flow.h
> @@ -90,17 +90,6 @@ struct flowi4 {
>  #define fl4_gre_key		uli.gre_key
>  } __attribute__((__aligned__(BITS_PER_LONG/8)));
>  
> -/* Reset some input parameters after previous lookup */
> -static inline void flowi4_update_output(struct flowi4 *fl4, int oif, __u8 tos,
> -					__be32 daddr, __be32 saddr)
> -{
> -	fl4->flowi4_oif = oif;
> -	fl4->flowi4_tos = tos;
> -	fl4->daddr = daddr;
> -	fl4->saddr = saddr;
> -}

	My preference is this function to stay, it helps
to know the few places that use the route result for new
lookup.

Regards
