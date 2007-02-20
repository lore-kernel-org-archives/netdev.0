From: Max Krasnyansky <maxk@qualcomm.com>
Subject: Re: [TIPC] Missing null check in the socket code.
Date: Tue, 20 Feb 2007 10:48:32 -0800
Message-ID: <45DB4280.6030102@qualcomm.com>
References: <1171607254637-git-send-email-maxk@qualcomm.com> <11716072541171-git-send-email-maxk@qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jon.maloy@ericsson.com,
	allan.stephens@windriver.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from warlock.qualcomm.com ([129.46.50.49]:58551 "EHLO
	warlock.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030371AbXBTSy6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Feb 2007 13:54:58 -0500
Received: from numenor.qualcomm.com (numenor.qualcomm.com [129.46.51.58])
	by warlock.qualcomm.com (8.13.6/8.13.6/1.0) with ESMTP id l1KIsvLG018221
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Tue, 20 Feb 2007 10:54:57 -0800 (PST)
In-Reply-To: <11716072541171-git-send-email-maxk@qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Max Krasnyansky wrote:
> Fixes an oops in the non-blocking mode.
> 
> Signed-off-by: Max Krasnyansky <maxk@qualcomm.com>
> ---
>  net/tipc/socket.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/net/tipc/socket.c b/net/tipc/socket.c
> index 2a6a5a6..767f791 100644
> --- a/net/tipc/socket.c
> +++ b/net/tipc/socket.c
> @@ -862,6 +862,10 @@ restart:
>  	/* Get access to first message in receive queue */
>  
>  	buf = skb_peek(&sock->sk->sk_receive_queue);
> +	if (NULL == buf) {
> +		res = -EAGAIN;
> +		goto exit;
> +	}
>  	msg = buf_msg(buf);
>  	sz = msg_data_sz(msg);
>  	err = msg_errcode(msg);

Just a reminder. Please apply.

Thanx
Max
