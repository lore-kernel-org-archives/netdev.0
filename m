From: Vladislav Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] SCTP: Fix SCTP_SET_PEER_PRIMARY_ADDR to accpet v4mapped
 address
Date: Fri, 10 Dec 2010 18:13:58 -0500
Message-ID: <4D02B436.5000605@hp.com>
References: <4CFEF74D.7020704@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-sctp@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:47051 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751857Ab0LJXOE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 18:14:04 -0500
In-Reply-To: <4CFEF74D.7020704@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/07/2010 10:11 PM, Wei Yongjun wrote:
> SCTP_SET_PEER_PRIMARY_ADDR does not accpet v4mapped address, using
> v4mapped address in SCTP_SET_PEER_PRIMARY_ADDR socket option will
> get -EADDRNOTAVAIL error if v4map is enabled. This patch try to
> fix it by mapping v4mapped address to v4 address if allowed.
> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

Looks good.

Acked-by: Vlad Yasevich <vladislav.yasevich@hp.com>

-vlad

> ---
>  net/sctp/socket.c |    8 ++++++++
>  1 files changed, 8 insertions(+), 0 deletions(-)
> 
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index 6bd5543..0b9ee34 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -2932,6 +2932,7 @@ static int sctp_setsockopt_peer_primary_addr(struct sock *sk, char __user *optva
>  	struct sctp_association	*asoc = NULL;
>  	struct sctp_setpeerprim	prim;
>  	struct sctp_chunk	*chunk;
> +	struct sctp_af		*af;
>  	int 			err;
>  
>  	sp = sctp_sk(sk);
> @@ -2959,6 +2960,13 @@ static int sctp_setsockopt_peer_primary_addr(struct sock *sk, char __user *optva
>  	if (!sctp_state(asoc, ESTABLISHED))
>  		return -ENOTCONN;
>  
> +	af = sctp_get_af_specific(prim.sspp_addr.ss_family);
> +	if (!af)
> +		return -EINVAL;
> +
> +	if (!af->addr_valid((union sctp_addr *)&prim.sspp_addr, sp, NULL))
> +		return -EADDRNOTAVAIL;
> +
>  	if (!sctp_assoc_lookup_laddr(asoc, (union sctp_addr *)&prim.sspp_addr))
>  		return -EADDRNOTAVAIL;
>  
> 
> 

