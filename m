From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/3] af_key: locking change
Date: Sat, 20 Feb 2010 05:07:30 +0100
Message-ID: <1266638850.2839.6.camel@edumazet-laptop>
References: <20100219215913.819285957@vyatta.com>
	 <20100219220111.868268353@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
	Andrew Morton <akpm@linux-foundation.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Peter Oberparleiter <oberpar@linux.vnet.ibm.com>,
	Miklos Szeredi <mszeredi@suse.cz>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jpirko@redhat.com>, Jiri Olsa <jolsa@redhat.com>,
	Ingo Molnar <mingo@elte.hu>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Jamal Hadi Salim <hadi@cyberus.ca>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:56683 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755326Ab0BTEHg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2010 23:07:36 -0500
Received: by bwz1 with SMTP id 1so566588bwz.21
        for <netdev@vger.kernel.org>; Fri, 19 Feb 2010 20:07:35 -0800 (PST)
In-Reply-To: <20100219220111.868268353@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 19 f=C3=A9vrier 2010 =C3=A0 13:59 -0800, Stephen Hemminger =
a =C3=A9crit :
> pi=C3=A8ce jointe document texte brut (pfkey-rcu.patch)
> Get rid of custom locking that was using wait queue, lock, and atomic
> to basically build a queued mutex.  Use RCU for read side.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Excellent

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

I dont know why you used synchronize_sched() instead of
synchronize_rcu().

I prefer _rcu() variant because its all about rcu after all, and fact i=
t
is mapped to synchronize_sched() is an implementation detail.

(I am not saying implementation doesnt matter, Paul :) )

>  }
> =20
>  static struct proto key_proto =3D {
> @@ -223,6 +177,7 @@ static int pfkey_release(struct socket *
>  	sock_orphan(sk);
>  	sock->sk =3D NULL;
>  	skb_queue_purge(&sk->sk_write_queue);
> +	synchronize_sched();
>  	sock_put(sk);
> =20
>  	return 0;


