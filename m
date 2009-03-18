From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] fix sctp breakage
Date: Wed, 18 Mar 2009 08:28:44 -0400
Message-ID: <49C0E8FC.70706@hp.com>
References: <20090318031405.GX28946@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:36837 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755073AbZCRM2s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2009 08:28:48 -0400
In-Reply-To: <20090318031405.GX28946@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Al Viro wrote:
> broken by commit 5e739d1752aca4e8f3e794d431503bfca3162df4; AFAICS should
> be -stable fodder as well...
> 
> Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
> ---
> diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
> index 4c8d9f4..905fda5 100644
> --- a/net/sctp/endpointola.c
> +++ b/net/sctp/endpointola.c
> @@ -111,7 +111,8 @@ static struct sctp_endpoint *sctp_endpoint_init(struct sctp_endpoint *ep,
>  		if (sctp_addip_enable) {
>  			auth_chunks->chunks[0] = SCTP_CID_ASCONF;
>  			auth_chunks->chunks[1] = SCTP_CID_ASCONF_ACK;
> -			auth_chunks->param_hdr.length += htons(2);
> +			auth_chunks->param_hdr.length =
> +					htons(sizeof(sctp_paramhdr_t) + 2);
>  		}
>  	}
>  

ACK.  That wasn't a good way to write that increment.  I should have thought more
about it, but at the time it seemed like a good idea...

Thanks
-vlad

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

