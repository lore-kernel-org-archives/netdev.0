From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [Patch net] ipv6: fix rtnl lock assertion failure in
 ipv6_sock_ac_join()
Date: Tue, 02 Sep 2014 23:29:41 +0200
Message-ID: <1409693381.15984.19.camel@localhost>
References: <1409681239-4852-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Sabrina Dubroca <sd@queasysnail.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:41836 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750820AbaIBV3o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 17:29:44 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by gateway2.nyi.internal (Postfix) with ESMTP id 8EAAA20D8F
	for <netdev@vger.kernel.org>; Tue,  2 Sep 2014 17:29:43 -0400 (EDT)
In-Reply-To: <1409681239-4852-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Cong,

On Di, 2014-09-02 at 11:07 -0700, Cong Wang wrote:
> @@ -198,7 +198,7 @@ void ipv6_sock_ac_close(struct sock *sk)
>  	spin_unlock_bh(&ipv6_sk_ac_lock);
>  
>  	prev_index = 0;
> -	rcu_read_lock();
> +	rtnl_lock();
>  	while (pac) {
>  		struct ipv6_ac_socklist *next = pac->acl_next;
>  
> @@ -211,7 +211,7 @@ void ipv6_sock_ac_close(struct sock *sk)
>  		sock_kfree_s(sk, pac, sizeof(*pac));
>  		pac = next;
>  	}
> -	rcu_read_unlock();
> +	rtnl_unlock();
>  }
>  

Nit:
You forgot to convert a dev_get_by_index_rcu to __dev_get_by_index in
ipv6_sock_ac_close.

Bye,
Hannes
