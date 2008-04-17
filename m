From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] SCTP: Initialize partial_bytes_acked to 0, when all of
 the data is acked.
Date: Thu, 17 Apr 2008 16:29:12 -0400
Message-ID: <4807B318.2000307@hp.com>
References: <4805A2CA.7030808@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	lksctp-dev <lksctp-developers@lists.sourceforge.net>,
	linux-sctp@vger.kernel.org
To: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:43656 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752398AbYDQU3P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Apr 2008 16:29:15 -0400
In-Reply-To: <4805A2CA.7030808@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gui Jianfeng wrote:
> Vlad,
> According to RFC4960 7.2.2, 
> When all of the data transmitted by the sender has
> been acknowledged by the recerver, partial_bytes_acked is initialized to 0.
> 
> This patch conforms to rfc requirement. 
> Without this fix, cwnd might be error incremented.
> 
> Signed-off-by: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
> ---
>  net/sctp/outqueue.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
> index c071446..cf79485 100644
> --- a/net/sctp/outqueue.c
> +++ b/net/sctp/outqueue.c
> @@ -1544,6 +1544,9 @@ static void sctp_check_transmitted(struct sctp_outq *q,
>  						  bytes_acked);
>  
>  			transport->flight_size -= bytes_acked;
> +			if (transport->flight_size == 0) {
> +				transport->partial_bytes_acked = 0;
> +			}
>  			q->outstanding_bytes -= bytes_acked;
>  		} else {
>  			/* RFC 2960 6.1, sctpimpguide-06 2.15.2

Loose the braces, otherwise looks good.

-vlad

