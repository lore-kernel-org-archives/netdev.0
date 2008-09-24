From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 1/3] Phonet: Netlink factorization and cleanup
Date: Wed, 24 Sep 2008 13:25:07 -0300
Message-ID: <20080924162507.GA13760@ghostprotocols.net>
References: <1222272700-28232-1-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:51434 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750988AbYIXQZj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2008 12:25:39 -0400
Content-Disposition: inline
In-Reply-To: <1222272700-28232-1-git-send-email-remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Wed, Sep 24, 2008 at 07:11:38PM +0300, Remi Denis-Courmont escreveu:
> From: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
>=20
> Signed-off-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
> ---
>  net/phonet/pn_netlink.c |   91 ++++++++++++++++++-------------------=
----------
>  1 files changed, 35 insertions(+), 56 deletions(-)
>=20
> diff --git a/net/phonet/pn_netlink.c b/net/phonet/pn_netlink.c
> index b1ea19a..b1770d6 100644
> --- a/net/phonet/pn_netlink.c
> +++ b/net/phonet/pn_netlink.c
> @@ -54,11 +54,16 @@ errout:
>  		rtnl_set_sk_err(dev_net(dev), RTNLGRP_PHONET_IFADDR, err);
>  }
> =20
> -static int newaddr_doit(struct sk_buff *skb, struct nlmsghdr *nlm, v=
oid *attr)
> +static const struct nla_policy ifa_phonet_policy[IFA_MAX+1] =3D {

since you are changing the above line, please use [IFA_MAX + 1] for con=
sistency

> +	[IFA_LOCAL] =3D { .type =3D NLA_U8 },
> +};
> +
> +static int addr_doit(struct sk_buff *skb, struct nlmsghdr *nlh, void=
 *attr)
>  {
> -	struct rtattr **rta =3D attr;
> -	struct ifaddrmsg *ifm =3D NLMSG_DATA(nlm);
> +	struct net *net =3D sock_net(skb->sk);
> +	struct nlattr *tb[IFA_MAX+1];

Ditto

>  	struct net_device *dev;
> +	struct ifaddrmsg *ifm;
>  	int err;
>  	u8 pnaddr;
> =20
> @@ -67,52 +72,28 @@ static int newaddr_doit(struct sk_buff *skb, stru=
ct nlmsghdr *nlm, void *attr)
> =20
