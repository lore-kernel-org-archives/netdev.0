From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net] sctp: allow receiving msg when TCP-style sk is in
 CLOSED state
Date: Sat, 30 Jul 2016 10:22:10 -0300
Message-ID: <20160730132210.GC2957@localhost.localdomain>
References: <d108342f2f89cfdf7f9abc529a746a032e236b78.1469859281.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
	davem@davemloft.net, Vlad Yasevich <vyasevich@gmail.com>,
	daniel@iogearbox.net
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45572 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752102AbcG3NWO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Jul 2016 09:22:14 -0400
Content-Disposition: inline
In-Reply-To: <d108342f2f89cfdf7f9abc529a746a032e236b78.1469859281.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 30, 2016 at 02:14:41PM +0800, Xin Long wrote:
> Commit 141ddefce7c8 ("sctp: change sk state to CLOSED instead of
> CLOSING in sctp_sock_migrate") changed sk state to CLOSED if the
> assoc is closed when sctp_accept clones a new sk.
> 
> If there is still data in sk receive queue, users will not be able
> to read it any more, as sctp_recvmsg returns directly if sk state
> is CLOSED.
> 
> This patch is to add CLOSED state check in sctp_recvmsg to allow
> reading data from TCP-style sk with CLOSED state as what TCP does.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

So scripts can track this later more easily,

Fixes: 141ddefce7c8 ("sctp: change sk state to CLOSED instead of CLOSING in sctp_sock_migrate")
Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

> ---
>  net/sctp/socket.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index 8812e1b..9fc417a 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -2079,7 +2079,7 @@ static int sctp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len,
>  	lock_sock(sk);
>  
>  	if (sctp_style(sk, TCP) && !sctp_sstate(sk, ESTABLISHED) &&
> -	    !sctp_sstate(sk, CLOSING)) {
> +	    !sctp_sstate(sk, CLOSING) && !sctp_sstate(sk, CLOSED)) {
>  		err = -ENOTCONN;
>  		goto out;
>  	}
> -- 
> 2.1.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
