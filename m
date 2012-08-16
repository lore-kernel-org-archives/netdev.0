From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next] sctp: fix compile issue with disabled CONFIG_NET_NS
Date: Thu, 16 Aug 2012 11:58:34 -0700
Message-ID: <87fw7m64v9.fsf@xmission.com>
References: <20120816112449.GA17354@uweber-WS>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Ulrich Weber <ulrich.weber@sophos.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:55560 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752118Ab2HPS6n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2012 14:58:43 -0400
In-Reply-To: <20120816112449.GA17354@uweber-WS> (Ulrich Weber's message of
	"Thu, 16 Aug 2012 13:24:49 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ulrich Weber <ulrich.weber@sophos.com> writes:

> struct seq_net_private has no struct net
> if CONFIG_NET_NS is not enabled

My mistake.

Reviewed-by: "Eric W. Biederman" <ebiederm@xmission.com>

> Signed-off-by: Ulrich Weber <ulrich.weber@sophos.com>

Ulrich do you get any performance advantage by disabling the network
namespace?

I am wondering if there is any benefit to keeping it possible to disable
the network namespace?

The original reason for the option was so that distributions and
other who wanted to avoid new code could protect their users, and
that reasons seems to have long since passed.

> ---
>  net/sctp/proc.c |    9 +++------
>  1 file changed, 3 insertions(+), 6 deletions(-)
>
> diff --git a/net/sctp/proc.c b/net/sctp/proc.c
> index 3e62ee5..d9cb2ab 100644
> --- a/net/sctp/proc.c
> +++ b/net/sctp/proc.c
> @@ -199,7 +199,6 @@ static void * sctp_eps_seq_next(struct seq_file *seq, void *v, loff_t *pos)
>  /* Display sctp endpoints (/proc/net/sctp/eps). */
>  static int sctp_eps_seq_show(struct seq_file *seq, void *v)
>  {
> -	struct seq_net_private *priv = seq->private;
>  	struct sctp_hashbucket *head;
>  	struct sctp_ep_common *epb;
>  	struct sctp_endpoint *ep;
> @@ -216,7 +215,7 @@ static int sctp_eps_seq_show(struct seq_file *seq, void *v)
>  	sctp_for_each_hentry(epb, node, &head->chain) {
>  		ep = sctp_ep(epb);
>  		sk = epb->sk;
> -		if (!net_eq(sock_net(sk), priv->net))
> +		if (!net_eq(sock_net(sk), seq_file_net(seq)))
>  			continue;
>  		seq_printf(seq, "%8pK %8pK %-3d %-3d %-4d %-5d %5d %5lu ", ep, sk,
>  			   sctp_sk(sk)->type, sk->sk_state, hash,
> @@ -307,7 +306,6 @@ static void * sctp_assocs_seq_next(struct seq_file *seq, void *v, loff_t *pos)
>  /* Display sctp associations (/proc/net/sctp/assocs). */
>  static int sctp_assocs_seq_show(struct seq_file *seq, void *v)
>  {
> -	struct seq_net_private *priv = seq->private;
>  	struct sctp_hashbucket *head;
>  	struct sctp_ep_common *epb;
>  	struct sctp_association *assoc;
> @@ -324,7 +322,7 @@ static int sctp_assocs_seq_show(struct seq_file *seq, void *v)
>  	sctp_for_each_hentry(epb, node, &head->chain) {
>  		assoc = sctp_assoc(epb);
>  		sk = epb->sk;
> -		if (!net_eq(sock_net(sk), priv->net))
> +		if (!net_eq(sock_net(sk), seq_file_net(seq)))
>  			continue;
>  		seq_printf(seq,
>  			   "%8pK %8pK %-3d %-3d %-2d %-4d "
> @@ -423,7 +421,6 @@ static void sctp_remaddr_seq_stop(struct seq_file *seq, void *v)
>  
>  static int sctp_remaddr_seq_show(struct seq_file *seq, void *v)
>  {
> -	struct seq_net_private *priv = seq->private;
>  	struct sctp_hashbucket *head;
>  	struct sctp_ep_common *epb;
>  	struct sctp_association *assoc;
> @@ -438,7 +435,7 @@ static int sctp_remaddr_seq_show(struct seq_file *seq, void *v)
>  	sctp_local_bh_disable();
>  	read_lock(&head->lock);
>  	sctp_for_each_hentry(epb, node, &head->chain) {
> -		if (!net_eq(sock_net(epb->sk), priv->net))
> +		if (!net_eq(sock_net(epb->sk), seq_file_net(seq)))
>  			continue;
>  		assoc = sctp_assoc(epb);
>  		list_for_each_entry(tsp, &assoc->peer.transport_addr_list,
