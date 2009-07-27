From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: shrink struct net_device by #ifdef-ing protocol-specific
 members
Date: Mon, 27 Jul 2009 16:28:16 +0200
Message-ID: <4A6DB980.8010503@gmail.com>
References: <4A6DADCF.8010801@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Lucian Adrian Grijincu <lgrijincu@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:48474 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751524AbZG0O20 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2009 10:28:26 -0400
In-Reply-To: <4A6DADCF.8010801@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lucian Adrian Grijincu a =E9crit :
> Some members of net_device are used only by some protocols.
>=20
> If those protocols are not compiled (as modules or linked in) they
> should not take up space in the structure.
>=20
> These members are also used in inline functions defined in headers no=
t
> protected by the protocol-specific CONFIG_ guards. Adding #ifdef CONF=
IG_*
> guards header wide is against the current style and more invasive tha=
n
> guarding only the definitions.
>=20
> Signed-off-by: Lucian Adrian Grijincu <lgrijincu@ixiacom.com>
> ---
>  include/linux/inetdevice.h |    2 ++
>  include/linux/netdevice.h  |   14 ++++++++++++++
>  include/net/ax25.h         |    2 ++
>  net/core/dev.c             |    6 ++++++
>  4 files changed, 24 insertions(+), 0 deletions(-)
>=20
> diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
> index acef2a7..88132ff 100644
> --- a/include/linux/inetdevice.h
> +++ b/include/linux/inetdevice.h
> @@ -166,6 +166,7 @@ static __inline__ int bad_mask(__be32 mask, __be3=
2 addr)
>=20
>  #define endfor_ifa(in_dev) }
>=20
> +#ifdef CONFIG_INET
>  static inline struct in_device *__in_dev_get_rcu(const struct
> net_device *dev)
>  {
>  	struct in_device *in_dev =3D dev->ip_ptr;
> @@ -192,6 +193,7 @@ __in_dev_get_rtnl(const struct net_device *dev)
>  {
>  	return (struct in_device*)dev->ip_ptr;
>  }
> +#endif /* CONFIG_INET */
>=20
>  extern void in_dev_finish_destroy(struct in_device *idev);
>=20
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 5a96a1a..d175bb9 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -762,14 +762,28 @@ struct net_device
>  #ifdef CONFIG_NET_DSA
>  	void			*dsa_ptr;	/* dsa specific data */
>  #endif
> +#ifdef CONFIG_ATALK
>  	void 			*atalk_ptr;	/* AppleTalk link 	*/
> +#endif
> +#ifdef CONFIG_INET
>  	void			*ip_ptr;	/* IPv4 specific data	*/
> +#endif
> +#ifdef CONFIG_DECNET
>  	void                    *dn_ptr;        /* DECnet specific data */
> +#endif
> +#ifdef CONFIG_IPV6

I dont know if your patch will please that much.

=46or example, IPV6 can be a module, so you cannot only test=20
ifdef CONFIG_IPV6

#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)


