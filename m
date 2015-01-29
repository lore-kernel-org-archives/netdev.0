From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net] net: sctp: fix passing wrong parameter header to
 param_type2af in sctp_process_param
Date: Thu, 29 Jan 2015 08:27:07 -0500
Message-ID: <54CA352B.7020203@gmail.com>
References: <1422525958-5737-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	Saran Maruti Ramanara <saran.neti@telus.com>
To: Daniel Borkmann <dborkman@redhat.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f47.google.com ([209.85.192.47]:57167 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752205AbbA2N1K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 08:27:10 -0500
In-Reply-To: <1422525958-5737-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/29/2015 05:05 AM, Daniel Borkmann wrote:
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

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

Thanks
-vlad

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
> 
