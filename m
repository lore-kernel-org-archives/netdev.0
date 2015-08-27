From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net v4] sctp: asconf's process should verify address parameter
 is in the beginning
Date: Thu, 27 Aug 2015 08:46:15 -0400
Message-ID: <55DF0697.5050608@gmail.com>
References: <842bb5735d0ea0e632695f49dc85021faa176784.1440663994.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: mleitner@redhat.com, davem@davemloft.net
To: Xin Long <lucien.xin@gmail.com>,
	network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f45.google.com ([209.85.192.45]:35391 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754586AbbH0MqX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 08:46:23 -0400
Received: by qgj62 with SMTP id 62so9814333qgj.2
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 05:46:23 -0700 (PDT)
In-Reply-To: <842bb5735d0ea0e632695f49dc85021faa176784.1440663994.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/27/2015 04:26 AM, Xin Long wrote:
> in sctp_process_asconf(), we get address parameter from the beginning of
> the addip params. but we never check if it's really there. if the addr
> param is not there, it still can pass sctp_verify_asconf(), then to be
> handled by sctp_process_asconf(), it will not be safe.
> 
> so add a code in sctp_verify_asconf() to check the address parameter is in
> the beginning, or return false to send abort.
> 
> note that this can also detect multiple address parameters, and reject it.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>

Looks good to me.

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

-vlad

> ---
>  net/sctp/sm_make_chunk.c | 7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
> index 06320c8..a655ddc 100644
> --- a/net/sctp/sm_make_chunk.c
> +++ b/net/sctp/sm_make_chunk.c
> @@ -3132,11 +3132,18 @@ bool sctp_verify_asconf(const struct sctp_association *asoc,
>  		case SCTP_PARAM_IPV4_ADDRESS:
>  			if (length != sizeof(sctp_ipv4addr_param_t))
>  				return false;
> +			/* ensure there is only one addr param and it's in the
> +			 * beginning of addip_hdr params, or we reject it.
> +			 */
> +			if (param.v != addip->addip_hdr.params)
> +				return false;
>  			addr_param_seen = true;
>  			break;
>  		case SCTP_PARAM_IPV6_ADDRESS:
>  			if (length != sizeof(sctp_ipv6addr_param_t))
>  				return false;
> +			if (param.v != addip->addip_hdr.params)
> +				return false;
>  			addr_param_seen = true;
>  			break;
>  		case SCTP_PARAM_ADD_IP:
> 
