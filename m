From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net] net: sctp: fix passing wrong parameter header to
 param_type2af in sctp_process_param
Date: Thu, 29 Jan 2015 09:43:51 -0500
Message-ID: <20150129144351.GC1999@hmsreliant.think-freely.org>
References: <1422525958-5737-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, vyasevich@gmail.com, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org,
	Saran Maruti Ramanara <saran.neti@telus.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:34570 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750840AbbA2OoH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 09:44:07 -0500
Content-Disposition: inline
In-Reply-To: <1422525958-5737-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 29, 2015 at 11:05:58AM +0100, Daniel Borkmann wrote:
> From: Saran Maruti Ramanara <saran.neti@telus.com>
> 
> When making use of RFC5061, section 4.2.4. for setting the primary IP
> address, we're passing a wrong parameter header to param_type2af(),
> resulting always in NULL being returned.
> 
> At this point, param.p points to a sctp_addip_param struct, containing
> a sctp_paramhdr (type = 0xc004, length = var), and crr_id as a correlation
> id. Followed by that, as also presented in RFC5061 section 4.2.4., comes
> the actual sctp_addr_param, which also contains a sctp_paramhdr, but
> this time with the correct type SCTP_PARAM_IPV{4,6}_ADDRESS that
> param_type2af() can make use of. Since we already hold a pointer to
> addr_param from previous line, just reuse it for param_type2af().
> 
> Fixes: d6de3097592b ("[SCTP]: Add the handling of "Set Primary IP Address" parameter to INIT")
> Signed-off-by: Saran Maruti Ramanara <saran.neti@telus.com>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>  net/sctp/sm_make_chunk.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
> index e49e231..06320c8 100644
> --- a/net/sctp/sm_make_chunk.c
> +++ b/net/sctp/sm_make_chunk.c
> @@ -2608,7 +2608,7 @@ do_addr_param:
>  
>  		addr_param = param.v + sizeof(sctp_addip_param_t);
>  
> -		af = sctp_get_af_specific(param_type2af(param.p->type));
> +		af = sctp_get_af_specific(param_type2af(addr_param->p.type));
>  		if (af == NULL)
>  			break;
>  
> -- 
> 1.7.11.7
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>
