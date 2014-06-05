From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH V2 net-next] LISP: Locator/Identifier Separation Protocol
Date: Thu, 5 Jun 2014 15:12:08 -0700
Message-ID: <CAHA+R7MU6mcQjvqzHT5qSsPzxdbPC=pSh3MbNF2yOUNJocKiJg@mail.gmail.com>
References: <4D3092DF-BB04-4C50-88B9-EBBA349C7B17@logicalelegance.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	"Vina Ermagan (vermagan)" <vermagan@cisco.com>,
	"Lorand Jakab -X (lojakab - M SQUARED CONSULTING INC. at Cisco)"
	<lojakab@cisco.com>
To: Christopher White <chris@logicalelegance.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f52.google.com ([209.85.216.52]:51816 "EHLO
	mail-qa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752007AbaFEWMJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 18:12:09 -0400
Received: by mail-qa0-f52.google.com with SMTP id cm18so2403077qab.25
        for <netdev@vger.kernel.org>; Thu, 05 Jun 2014 15:12:08 -0700 (PDT)
In-Reply-To: <4D3092DF-BB04-4C50-88B9-EBBA349C7B17@logicalelegance.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 5, 2014 at 2:14 PM, Christopher White
<chris@logicalelegance.com> wrote:
> +void lisp_sock_release(struct lisp_sock *s)
> +{
> +       struct sock *sk = s->sock->sk;
> +       struct net *net = sock_net(sk);
> +       struct lisp_net *ln = net_generic(net, lisp_net_id);
> +
> +       if (!atomic_dec_and_test(&s->refcnt))
> +               return;
> +       spin_lock(&ln->sock_lock);
> +       hlist_del_rcu(&s->hlist);
> +       rcu_assign_sk_user_data(s->sock->sk, NULL);
> +       spin_unlock(&ln->sock_lock);
> +       queue_work(lisp_wq, &s->del_work);
> +}
> +EXPORT_SYMBOL_GPL(lisp_sock_release);

Why do you export this symbol?


> +
> +static int create_v4_sock(struct net *net, __be16 port, struct socket **psock,
> +                         u32 flags)
> +{


It looks like this function is very similar to the one in vxlan tunnel,
it would be better to unify and move it to net/core/sock.c.
