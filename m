From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net v2] ipv6: fix a potential deadlock in
 do_ipv6_setsockopt()
Date: Thu, 20 Oct 2016 06:47:06 -0700
Message-ID: <1476971226.7065.5.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1476945312-15572-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sploving1@gmail.com,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:33631 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935355AbcJTNrI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 09:47:08 -0400
Received: by mail-it0-f68.google.com with SMTP id k64so6037985itb.0
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 06:47:08 -0700 (PDT)
In-Reply-To: <1476945312-15572-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-10-19 at 23:35 -0700, Cong Wang wrote:
> Baozeng reported this deadlock case:

...

> +
> +void ipv6_sock_mc_close(struct sock *sk)
> +{
> +	struct ipv6_pinfo *np = inet6_sk(sk);
> +
> +	if (!rcu_access_pointer(np->ipv6_mc_list))
> +		return;

I wonder if rcu_dereference_protected(..., lockdep_sock_is_held(sk))
could be used instead, to get lockdep support ?

> +	rtnl_lock();
> +	__ipv6_sock_mc_close(sk);
>  	rtnl_unlock();
>  }
>  

Thanks !
