From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] fib_rules: fix unresolved_rules counting
Date: Tue, 18 Oct 2011 05:47:31 +0200
Message-ID: <1318909651.2571.41.camel@edumazet-laptop>
References: <4E9CD45C.9050608@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: "Yan, Zheng" <zheng.z.yan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:55715 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757314Ab1JRDrl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2011 23:47:41 -0400
Received: by wwe6 with SMTP id 6so246891wwe.1
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2011 20:47:40 -0700 (PDT)
In-Reply-To: <4E9CD45C.9050608@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 18 octobre 2011 =C3=A0 09:20 +0800, Yan, Zheng a =C3=A9crit :
> we should decrease ops->unresolved_rules when deleting a unresolved r=
ule.
>=20
> Signed-off-by: Zheng Yan <zheng.z.yan@intel.com>
> ---
> diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
> index 3231b46..27071ee 100644
> --- a/net/core/fib_rules.c
> +++ b/net/core/fib_rules.c
> @@ -475,8 +475,11 @@ static int fib_nl_delrule(struct sk_buff *skb, s=
truct nlmsghdr* nlh, void *arg)
> =20
>  		list_del_rcu(&rule->list);
> =20
> -		if (rule->action =3D=3D FR_ACT_GOTO)
> +		if (rule->action =3D=3D FR_ACT_GOTO) {
>  			ops->nr_goto_rules--;
> +			if (rtnl_dereference(rule->ctarget) =3D=3D NULL)
> +				ops->unresolved_rules--;
> +		}
> =20
>  		/*
>  		 * Check if this rule is a target to any of them. If so,

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
