From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] sctp: xmit sctp packet always return no route error
Date: Mon, 29 Jun 2009 09:12:54 -0400
Message-ID: <4A48BDD6.1020001@hp.com>
References: <4A488021.50002@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Netdev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:3725 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751680AbZF2NMw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2009 09:12:52 -0400
In-Reply-To: <4A488021.50002@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wei Yongjun wrote:
> Commit 'net: skb->dst accessors'(adf30907d63893e4208dfe3f5c88ae12bc2f25d5)
> broken the sctp protocol stack, the sctp packet can never be sent out after
> Eric Dumazet's patch, which have typo in the sctp code.
> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

Oh-oh!!  Thanks for catching this.

Acked-by: Vlad Yasevich <vladisalv.yasevich@hp.com>

-vlad

> ---
>  net/sctp/output.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/sctp/output.c b/net/sctp/output.c
> index b764114..b94c211 100644
> --- a/net/sctp/output.c
> +++ b/net/sctp/output.c
> @@ -407,7 +407,7 @@ int sctp_packet_transmit(struct sctp_packet *packet)
>  	}
>  	dst = dst_clone(tp->dst);
>  	skb_dst_set(nskb, dst);
> -	if (dst)
> +	if (!dst)
>  		goto no_route;
>  
>  	/* Build the SCTP header.  */

