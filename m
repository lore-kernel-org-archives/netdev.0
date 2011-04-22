From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: [PATCH net-next-2.6 v5 5/5] sctp: Add ADD/DEL ASCONF handling
 at the receiver
Date: Fri, 22 Apr 2011 12:05:19 +0800
Message-ID: <4DB0FE7F.5010300@cn.fujitsu.com>
References: <8F7C47DA-A0A2-48BE-84A7-1D073B5617AE@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: Michio Honda <micchie@sfc.wide.ad.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:56160 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750701Ab1DVEFi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Apr 2011 00:05:38 -0400
In-Reply-To: <8F7C47DA-A0A2-48BE-84A7-1D073B5617AE@sfc.wide.ad.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> This patch fixes the problem that the original code cannot delete the remote address where the corresponding transport is currently directed, even when the ASCONF is sent from the other address (this situation happens when the single-homed sender transmits  ASCONF with ADD and DEL.)  

we should apply this patch first before patch 4, so patch 5 and
patch 4 should change the order in the patchset.

> Signed-off-by: Michio Honda <micchie@sfc.wide.ad.jp>
> ---
> diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
> index de98665..a9f25d7 100644
> --- a/net/sctp/sm_make_chunk.c
> +++ b/net/sctp/sm_make_chunk.c
> @@ -2990,7 +2990,7 @@ static __be16 sctp_process_asconf_param(struct sctp_association *asoc,
>  		 * an Error Cause TLV set to the new error code 'Request to
>  		 * Delete Source IP Address'
>  		 */
> -		if (sctp_cmp_addr_exact(sctp_source(asconf), &addr))
> +		if (sctp_cmp_addr_exact(&asconf->source, &addr))
>  			return SCTP_ERROR_DEL_SRC_IP;
>  
>  		/* Section 4.2.2
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
