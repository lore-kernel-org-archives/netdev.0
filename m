From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net] sctp: fix double EPs display in sctp_diag
Date: Wed, 25 May 2016 17:23:01 -0300
Message-ID: <20160525202301.GO7313@localhost.localdomain>
References: <738ddd5de8d4c5fb8a99cee15de3305215e04962.1464203363.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
	davem@davemloft.net, Vlad Yasevich <vyasevich@gmail.com>,
	daniel@iogearbox.net, phil@nwl.cc
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33290 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750840AbcEYUXF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 May 2016 16:23:05 -0400
Content-Disposition: inline
In-Reply-To: <738ddd5de8d4c5fb8a99cee15de3305215e04962.1464203363.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 26, 2016 at 03:09:23AM +0800, Xin Long wrote:
> We have this situation: that EP hash table, contains only the EPs
> that are listening, while the transports one, has the opposite.
> We have to traverse both to dump all.
> 
> But when we traverse the transports one we will also get EPs that are
> in the EP hash if they are listening. In this case, the EP is dumped
> twice.
> 
> We will fix it by checking if the endpoint that is in the endpoint
> hash table contains any ep->asoc in there, as it means we will also
> find it via transport hash, and thus we can/should skip it, depending
> on the filters used, like 'ss -l'.
> 
> Still, we should NOT skip it if the user is listing only listening
> endpoints, because then we are not traversing the transport hash.
> so we have to check idiag_states there also.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

> ---
>  net/sctp/sctp_diag.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/net/sctp/sctp_diag.c b/net/sctp/sctp_diag.c
> index 8e3e769..1ce724b 100644
> --- a/net/sctp/sctp_diag.c
> +++ b/net/sctp/sctp_diag.c
> @@ -356,6 +356,9 @@ static int sctp_ep_dump(struct sctp_endpoint *ep, void *p)
>  	if (cb->args[4] < cb->args[1])
>  		goto next;
>  
> +	if ((r->idiag_states & ~TCPF_LISTEN) && !list_empty(&ep->asocs))
> +		goto next;
> +
>  	if (r->sdiag_family != AF_UNSPEC &&
>  	    sk->sk_family != r->sdiag_family)
>  		goto next;
> -- 
> 2.1.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
