From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] xt_quota: don't copy quota back to userspace
Date: Fri, 23 Jul 2010 07:40:33 +0200
Message-ID: <1279863633.2482.22.camel@edumazet-laptop>
References: <1279860845-7177-1-git-send-email-xiaosuo@gmail.com>
	 <1279862843.2482.16.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1279862843.2482.16.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 23 juillet 2010 =C3=A0 07:27 +0200, Eric Dumazet a =C3=A9cr=
it :
> Le vendredi 23 juillet 2010 =C3=A0 12:54 +0800, Changli Gao a =C3=A9c=
rit :
> > This patch should be applied after my another patch:
> > http://patchwork.ozlabs.org/patch/59729/
> >=20
> > xt_quota: don't copy quota back to userspace
> >=20
> > In nowadays, table entries are per-cpu variables, so it don't make =
any sense to
> > copy quota back to one of the variable instances. To keep things si=
mple, this
> > patch undo the copy.
> >=20
> > Signed-off-by: Changli Gao <xiaosuo@gmail.com>
>=20
> This looks the wrong way to fix this problem.
>=20
> Also Changli, could you please _not_ include the title of your patche=
s
> inside the Changelog ? This is useless.
>=20

Reading again your patch, I understand only the Changelog is wrong.

We want to copy quota back to userspace, as specified when rule was
setup (so that iptables-save works)

The real thing you are doing is that we dont change the initial quota
during packet processing, only the private quota, shared by all cpus.

Before the patch , iptables -nvL could report an old and not accurate
quota value.

After the patch, iptables -nvL reports the initial quota value, not the
actual value.



--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
