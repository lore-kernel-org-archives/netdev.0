From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH] tipc: set sk_err correctly when connection fails
Date: Tue, 27 Aug 2013 08:45:26 +0800
Message-ID: <521BF6A6.1020309@windriver.com>
References: <1377266200-26691-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <jon.maloy@ericsson.com>,
	<paul.gortmaker@windriver.com>,
	<tipc-discussion@lists.sourceforge.net>,
	<nhan.tt.vo@dektech.com.au>
To: <erik.hugne@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:59493 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752341Ab3H0Apx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Aug 2013 20:45:53 -0400
In-Reply-To: <1377266200-26691-1-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/23/2013 09:56 PM, erik.hugne@ericsson.com wrote:
> From: Erik Hugne <erik.hugne@ericsson.com>
> 
> This fixes a problem when connect() fails and returns the error
> code as a positive value, whereas errno itself is never set. The
> reason is that error codes set in sk_err should never be inverted.
> 
> Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>

Acked-by: Ying Xue <ying.xue@windriver.com>

> ---
>  net/tipc/socket.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/tipc/socket.c b/net/tipc/socket.c
> index ce8249c..6cc7ddd 100644
> --- a/net/tipc/socket.c
> +++ b/net/tipc/socket.c
> @@ -1257,7 +1257,7 @@ static u32 filter_connect(struct tipc_sock *tsock, struct sk_buff **buf)
>  		/* Accept only ACK or NACK message */
>  		if (unlikely(msg_errcode(msg))) {
>  			sock->state = SS_DISCONNECTING;
> -			sk->sk_err = -ECONNREFUSED;
> +			sk->sk_err = ECONNREFUSED;
>  			retval = TIPC_OK;
>  			break;
>  		}
> @@ -1268,7 +1268,7 @@ static u32 filter_connect(struct tipc_sock *tsock, struct sk_buff **buf)
>  		res = auto_connect(sock, msg);
>  		if (res) {
>  			sock->state = SS_DISCONNECTING;
> -			sk->sk_err = res;
> +			sk->sk_err = -res;
>  			retval = TIPC_OK;
>  			break;
>  		}
> 
