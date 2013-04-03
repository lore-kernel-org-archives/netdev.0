From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH -next] sctp: fix error return code in __sctp_connect()
Date: Wed, 03 Apr 2013 10:52:59 -0400
Message-ID: <515C424B.2010405@gmail.com>
References: <CAPgLHd-X5Qw64BnaSMr2ny6==jXGpRAYC7_1MGhP2v_GcVeApQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, nhorman@tuxdriver.com, davem@davemloft.net,
	yongjun_wei@trendmicro.com.cn, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f50.google.com ([209.85.128.50]:46242 "EHLO
	mail-qe0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932360Ab3DCOxD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Apr 2013 10:53:03 -0400
In-Reply-To: <CAPgLHd-X5Qw64BnaSMr2ny6==jXGpRAYC7_1MGhP2v_GcVeApQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/03/2013 09:02 AM, Wei Yongjun wrote:
> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
>
> Fix to return a negative error code from the error handling
> case instead of 0, as returned elsewhere in this function.
>
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

-vlad

> ---
>   net/sctp/socket.c | 5 +++--
>   1 file changed, 3 insertions(+), 2 deletions(-)
>
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index dd21ae3..f631c5f 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -1119,9 +1119,10 @@ static int __sctp_connect(struct sock* sk,
>   		/* Make sure the destination port is correctly set
>   		 * in all addresses.
>   		 */
> -		if (asoc && asoc->peer.port && asoc->peer.port != port)
> +		if (asoc && asoc->peer.port && asoc->peer.port != port) {
> +			err = -EINVAL;
>   			goto out_free;
> -
> +		}
>
>   		/* Check if there already is a matching association on the
>   		 * endpoint (other than the one created here).
>
