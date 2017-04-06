From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net] sctp: listen on the sock only when it's state is
 listening or closed
Date: Thu, 6 Apr 2017 10:02:19 -0300
Message-ID: <20170406130219.GF911@localhost.localdomain>
References: <19f73778f8e27b05ee9aa25ece57db6b0e73d197.1491455452.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        davem@davemloft.net, Neil Horman <nhorman@tuxdriver.com>,
        andreyknvl@google.com
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41384 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754302AbdDFNCY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Apr 2017 09:02:24 -0400
Content-Disposition: inline
In-Reply-To: <19f73778f8e27b05ee9aa25ece57db6b0e73d197.1491455452.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 06, 2017 at 01:10:52PM +0800, Xin Long wrote:
> Now sctp doesn't check sock's state before listening on it. It could
> even cause changing a sock with any state to become a listening sock
> when doing sctp_listen.
> 
> This patch is to fix it by checking sock's state in sctp_listen, so
> that it will listen on the sock with right state.
> 
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Tested-by: Andrey Konovalov <andreyknvl@google.com>
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Dave, please consider this for -stable. Thanks

> ---
>  net/sctp/socket.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index c1401f4..d9d4c92 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -7034,6 +7034,9 @@ int sctp_inet_listen(struct socket *sock, int backlog)
>  	if (sock->state != SS_UNCONNECTED)
>  		goto out;
>  
> +	if (!sctp_sstate(sk, LISTENING) && !sctp_sstate(sk, CLOSED))
> +		goto out;
> +
>  	/* If backlog is zero, disable listening. */
>  	if (!backlog) {
>  		if (sctp_sstate(sk, CLOSED))
> -- 
> 2.1.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
