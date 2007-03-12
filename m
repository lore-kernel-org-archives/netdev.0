From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH] NetLabel: parse the CIPSO ranged tag on incoming packets
Date: Mon, 12 Mar 2007 10:50:41 -0400 (EDT)
Message-ID: <Line.LNX.4.64.0703121050180.9351@d.namei>
References: <20070312134615.294091233@flek.zko.hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail6.sea5.speakeasy.net ([69.17.117.8]:54688 "EHLO
	mail6.sea5.speakeasy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030192AbXCLOup (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2007 10:50:45 -0400
In-Reply-To: <20070312134615.294091233@flek.zko.hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 12 Mar 2007, Paul Moore wrote:

> Commit 484b366932be0b73a22c74a82748ca10a721643e added support for the CIPSO
> ranged categories tag.  However, it appears that I made a mistake when rebasing
> then patch to the latest upstream sources for submission and dropped the part
> of the patch that actually parses the tag on incoming packets.  This patch
> fixes this mistake by adding the required function call to the
> cipso_v4_skbuff_getattr() function.
> 
> I've run this patch over the weekend and have not noticed any problems.
> 
> Signed-off-by: Paul Moore <paul.moore@hp.com>

Acked-by: James Morris <jmorris@namei.org>

> ---
>  net/ipv4/cipso_ipv4.c |    5 +++++
>  1 file changed, 5 insertions(+)
> 
> Index: net-2.6_bugfix_2/net/ipv4/cipso_ipv4.c
> ===================================================================
> --- net-2.6_bugfix_2.orig/net/ipv4/cipso_ipv4.c
> +++ net-2.6_bugfix_2/net/ipv4/cipso_ipv4.c
> @@ -1933,6 +1933,11 @@ int cipso_v4_skbuff_getattr(const struct
>  						 &cipso_ptr[6],
>  						 secattr);
>  		break;
> +	case CIPSO_V4_TAG_RANGE:
> +		ret_val = cipso_v4_parsetag_rng(doi_def,
> +						&cipso_ptr[6],
> +						secattr);
> +		break;
>  	}
>  
>  skbuff_getattr_return:
> 
> --
> paul moore
> linux security @ hp
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-- 
James Morris
<jmorris@namei.org>
