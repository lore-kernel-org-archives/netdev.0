From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netlink: Fix kfree NULL pointer
Date: Wed, 08 Sep 2010 07:19:45 +0200
Message-ID: <1283923185.2634.772.camel@edumazet-laptop>
References: <AANLkTikp0m8cQYfEBHP_E8XpGZqdMj6Cr4M=aWCnei=X@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes.berg@intel.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Alexey Dobriyan <adobriyan@openvz.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: jovi zhang <bookjovi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:38471 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751122Ab0IHFTv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 01:19:51 -0400
In-Reply-To: <AANLkTikp0m8cQYfEBHP_E8XpGZqdMj6Cr4M=aWCnei=X@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 08 septembre 2010 =C3=A0 13:13 +0800, jovi zhang a =C3=A9cr=
it :
> It will kfree NULL pointer if listeners is NULL. fix it.
>=20
> Signed-off-by: bookjovi@gmail.com
> net/netlink/af_netlink.c |    5 +++--
> 1 files changed, 3 insertions(+), 2 deletions(-)
>=20
> diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
> index 980fe4a..1c7bf48 100644
> --- a/net/netlink/af_netlink.c
> +++ b/net/netlink/af_netlink.c
> @@ -1532,8 +1532,10 @@ netlink_kernel_create(struct net *net, int
> unit, unsigned int groups,
>        if (input)
>                nlk_sk(sk)->netlink_rcv =3D input;
>=20
> -       if (netlink_insert(sk, net, 0))
> +       if (netlink_insert(sk, net, 0)) {
> +               kfree(listeners);
>                goto out_sock_release;
> +       }
>=20
>        nlk =3D nlk_sk(sk);
>        nlk->flags |=3D NETLINK_KERNEL_SOCKET;
> @@ -1553,7 +1555,6 @@ netlink_kernel_create(struct net *net, int unit=
,
> unsigned int groups,
>        return sk;
>=20
> out_sock_release:
> -       kfree(listeners);
>        netlink_kernel_release(sk);
>        return NULL;


This patch is not needed

kfree(NULL) is legal



