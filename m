From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net] sctp: do not mark sk dumped when inet_sctp_diag_fill
 returns err
Date: Fri, 15 Sep 2017 09:55:33 -0300
Message-ID: <20170915125533.GD4529@localhost.localdomain>
References: <c5398945d4e80ed8b8497675dd0449763fec4eec.1505444568.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        davem@davemloft.net, Neil Horman <nhorman@tuxdriver.com>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48068 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751335AbdIOMzm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 15 Sep 2017 08:55:42 -0400
Content-Disposition: inline
In-Reply-To: <c5398945d4e80ed8b8497675dd0449763fec4eec.1505444568.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 15, 2017 at 11:02:48AM +0800, Xin Long wrote:
> sctp_diag would not actually dump out sk/asoc if inet_sctp_diag_fill
> returns err, in which case it shouldn't mark sk dumped by setting
> cb->args[3] as 1 in sctp_sock_dump().
> 
> Otherwise, it could cause some asocs to have no parent's sk dumped
> in 'ss --sctp'.
> 
> So this patch is to not set cb->args[3] when inet_sctp_diag_fill()
> returns err in sctp_sock_dump().
> 
> Fixes: 8f840e47f190 ("sctp: add the sctp_diag.c file")
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

> ---
>  net/sctp/sctp_diag.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/net/sctp/sctp_diag.c b/net/sctp/sctp_diag.c
> index 7008a99..22ed01a 100644
> --- a/net/sctp/sctp_diag.c
> +++ b/net/sctp/sctp_diag.c
> @@ -309,7 +309,6 @@ static int sctp_sock_dump(struct sctp_transport *tsp, void *p)
>  					cb->nlh->nlmsg_seq,
>  					NLM_F_MULTI, cb->nlh,
>  					commp->net_admin) < 0) {
> -			cb->args[3] = 1;
>  			err = 1;
>  			goto release;
>  		}
> -- 
> 2.1.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
