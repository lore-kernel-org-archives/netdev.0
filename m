From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net v4] sctp: asconf's process should verify address parameter
 is in the beginning
Date: Wed, 26 Aug 2015 17:33:28 -0400
Message-ID: <55DE30A8.7020402@redhat.com>
References: <e003fc0660f6b2eefd25618ea7a037e62952a54d.1440623004.git.lucien.xin@gmail.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: mleitner@redhat.com, davem@davemloft.net
To: Xin Long <lucien.xin@gmail.com>,
	network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44075 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751659AbbHZVda (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Aug 2015 17:33:30 -0400
In-Reply-To: <e003fc0660f6b2eefd25618ea7a037e62952a54d.1440623004.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/26/2015 05:03 PM, Xin Long wrote:
> in sctp_process_asconf(), we get address parameter from the beginning of
> the addip params. but we never check if it's really there. if the addr
> param is not there, it still can pass sctp_verify_asconf(), then to be
> handled by sctp_process_asconf(), it will not be safe.
> 
> so add detection in sctp_verify_asconf() to check the address parameter is in
> the beginning, or return false to send abort.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

-vlad

> ---
>  net/sctp/sm_make_chunk.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
> index 06320c8..f3fc881 100644
> --- a/net/sctp/sm_make_chunk.c
> +++ b/net/sctp/sm_make_chunk.c
> @@ -3132,12 +3132,14 @@ bool sctp_verify_asconf(const struct sctp_association *asoc,
>  		case SCTP_PARAM_IPV4_ADDRESS:
>  			if (length != sizeof(sctp_ipv4addr_param_t))
>  				return false;
> -			addr_param_seen = true;
> +			if (param.v == addip->addip_hdr.params)
> +				addr_param_seen = true;
>  			break;
>  		case SCTP_PARAM_IPV6_ADDRESS:
>  			if (length != sizeof(sctp_ipv6addr_param_t))
>  				return false;
> -			addr_param_seen = true;
> +			if (param.v == addip->addip_hdr.params)
> +				addr_param_seen = true;
>  			break;
>  		case SCTP_PARAM_ADD_IP:
>  		case SCTP_PARAM_DEL_IP:
> 
