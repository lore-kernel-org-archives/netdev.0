From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: tun: Use netif_receive_skb instead of netif_rx
Date: Thu, 20 May 2010 08:03:35 +0200
Message-ID: <1274335415.2658.46.camel@edumazet-laptop>
References: <4BF4517F.1010206@athenacr.com>
	 <20100519.195533.22536631.davem@davemloft.net>
	 <20100520025741.GA6129@gondor.apana.org.au>
	 <20100519.200522.140743640.davem@davemloft.net>
	 <20100520033446.GA6434@gondor.apana.org.au>
	 <1274332507.2658.31.camel@edumazet-laptop>
	 <20100520052059.GC7443@gondor.apana.org.au>
	 <1274333779.2658.43.camel@edumazet-laptop>
	 <20100520054642.GA7836@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, bmb@athenacr.com,
	tgraf@redhat.com, nhorman@tuxdriver.com, nhorman@redhat.com,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:33361 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753530Ab0ETGDl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 May 2010 02:03:41 -0400
Received: by wyg36 with SMTP id 36so1039783wyg.19
        for <netdev@vger.kernel.org>; Wed, 19 May 2010 23:03:39 -0700 (PDT)
In-Reply-To: <20100520054642.GA7836@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 20 mai 2010 =C3=A0 15:46 +1000, Herbert Xu a =C3=A9crit :

> +#ifdef CONFIG_NET_CLS_CGROUP
> +static inline u32 task_cls_classid(struct task_struct *p)
> +{
> +	return container_of(task_subsys_state(p, net_cls_subsys_id),
> +			    struct cgroup_cls_state, css).classid;
> +}
> +#else
> +int net_cls_subsys_id =3D -1;
> +EXPORT_SYMBOL_GPL(net_cls_subsys_id);
> +
> +static inline u32 task_cls_classid(struct task_struct *p)
> +{
> +	int id;
> +	u32 classid;
> +
> +	rcu_read_lock();
> +	id =3D rcu_dereference(net_cls_subsys_id);
> +	if (id >=3D 0)
> +		classid =3D container_of(task_subsys_state(p, id),
> +				       struct cgroup_cls_state, css)->classid;
> +	rcu_read_unlock();
> +
> +	return classid;
> +}
> +#endif

I still dont understand why you introduce this function and not reuse i=
t
in net/sched/cls_cgroup.c

You told me it needs a separate patch, I dont think so.
Just make it non static and EXPORTed



> +	rcu_read_lock();
> +	classid =3D task_cls_state(current)->classid;
> +	rcu_read_unlock();
> +



