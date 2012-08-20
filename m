From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: Use netinet->inet_opt in
 inet_csk_route_child_sock()
Date: Mon, 20 Aug 2012 02:51:47 -0700 (PDT)
Message-ID: <20120820.025147.936465141809418575.davem@davemloft.net>
References: <1345239312-19266-1-git-send-email-christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: christoph.paasch@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52744 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750828Ab2HTJvs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2012 05:51:48 -0400
In-Reply-To: <1345239312-19266-1-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Paasch <christoph.paasch@uclouvain.be>
Date: Fri, 17 Aug 2012 23:35:12 +0200

> @@ -404,7 +404,7 @@ struct dst_entry *inet_csk_route_child_sock(struct sock *sk,
>  {
>  	const struct inet_request_sock *ireq = inet_rsk(req);
>  	struct inet_sock *newinet = inet_sk(newsk);
> -	struct ip_options_rcu *opt = ireq->opt;
> +	struct ip_options_rcu *opt = rcu_dereference(newinet->inet_opt);
>  	struct net *net = sock_net(sk);

We're not inside of a rcu_read_lock() protected section, so this access
is not legitimate.  If you enabled RCU lock debugging, you would have
triggered a warning in the kernel log.
