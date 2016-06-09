From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCHv3 net-next] sctp: sctp should change socket state when
 shutdown is received
Date: Thu, 9 Jun 2016 16:42:47 +0300
Message-ID: <ce5d05f9-3700-1007-2253-2ccaa00e6064@cogentembedded.com>
References: <4ad023d07da2c81ea9f5014e48f0aa34b50b64eb.1465471336.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
	davem@davemloft.net, eric.dumazet@gmail.com
To: Xin Long <lucien.xin@gmail.com>,
	network dev <netdev@vger.kernel.org>,
	linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f46.google.com ([209.85.215.46]:34933 "EHLO
	mail-lf0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932069AbcFINmu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 09:42:50 -0400
Received: by mail-lf0-f46.google.com with SMTP id u74so26616131lff.2
        for <netdev@vger.kernel.org>; Thu, 09 Jun 2016 06:42:50 -0700 (PDT)
In-Reply-To: <4ad023d07da2c81ea9f5014e48f0aa34b50b64eb.1465471336.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 6/9/2016 2:22 PM, Xin Long wrote:

> Now sctp doesn't change socket state upon shutdown reception. It changes
> just the assoc state, even though it's a TCP-style socket.
>
> For some cases, if we really need to check sk->sk_state, it's necessary to
> fix this issue, at least when we use ss or netstat to dump, we can get a
> more exact information.
>
> As an improvement, we will change sk->sk_state when we change asoc->state
> to SHUTDOWN_RECEIVED, and also do it in sctp_shutdown to keep consistent with
> sctp_close.
>
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
[...]
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index 67154b8..80d860a 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
[...]
> @@ -7564,10 +7565,12 @@ static void sctp_sock_migrate(struct sock *oldsk, struct sock *newsk,
>  	/* If the association on the newsk is already closed before accept()
>  	 * is called, set RCV_SHUTDOWN flag.
>  	 */
> -	if (sctp_state(assoc, CLOSED) && sctp_style(newsk, TCP))
> +	if (sctp_state(assoc, CLOSED) && sctp_style(newsk, TCP)) {
> +		newsk->sk_state = SCTP_SS_CLOSING;
>  		newsk->sk_shutdown |= RCV_SHUTDOWN;
> +	} else
> +		newsk->sk_state = SCTP_SS_ESTABLISHED;

    CodingStyle: all arms of the *if* statment should use {} if at least one 
arm uses {}.

MBR, Sergei
