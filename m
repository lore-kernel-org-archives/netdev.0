From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/8] net: Kill hold_net release_net
Date: Wed, 11 Mar 2015 10:07:27 -0700
Message-ID: <1426093647.11398.50.camel@edumazet-glaptop2.roam.corp.google.com>
References: <871tlxtbhd.fsf_-_@x220.int.ebiederm.org>
	 <CANn89iJ2auNoChr3FuFh-AGaPaw5_wwqfjZrtup1+xu6reVHMA@mail.gmail.com>
	 <87d25hrv9m.fsf@x220.int.ebiederm.org>
	 <20150219.144929.1003473344851168804.davem@davemloft.net>
	 <87h9tu114z.fsf_-_@x220.int.ebiederm.org>
	 <87vbi7fq92.fsf_-_@x220.int.ebiederm.org>
	 <87pp8ffq63.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, edumazet@google.com,
	netdev@vger.kernel.org, stephen@networkplumber.org,
	nicolas.dichtel@6wind.com, roopa@cumulusnetworks.com,
	hannes@stressinduktion.org, ddutt@cumulusnetworks.com,
	vipin@cumulusnetworks.com, shmulik.ladkani@gmail.com,
	dsahern@gmail.com, Julian Anastasov <ja@ssi.bg>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:44180 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751901AbbCKRHa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 13:07:30 -0400
Received: by igdh15 with SMTP id h15so14013730igd.3
        for <netdev@vger.kernel.org>; Wed, 11 Mar 2015 10:07:29 -0700 (PDT)
In-Reply-To: <87pp8ffq63.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-03-11 at 11:35 -0500, Eric W. Biederman wrote:

> @@ -163,9 +162,7 @@ static void fib_rules_cleanup_ops(struct fib_rules_ops *ops)
>  static void fib_rules_put_rcu(struct rcu_head *head)
>  {
>  	struct fib_rules_ops *ops = container_of(head, struct fib_rules_ops, rcu);
> -	struct net *net = ops->fro_net;
>  
> -	release_net(net);
>  	kfree(ops);
>  }


Looks like this function is no longer needed, can caller can instead do

-	call_rcu(&rule->rcu, fib_rule_put_rcu);
+	kfree_rcu(rule, rcu);
