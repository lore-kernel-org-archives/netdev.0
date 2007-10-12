From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH 1/2] NFS: change the ip_map cache code to handle IPv6
 addresses
Date: Fri, 12 Oct 2007 12:07:46 -0400
Message-ID: <470F9BD2.3070204@hp.com>
References: <470F3AF2.8000706@ext.bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mailing list NFSv4 <nfsv4@linux-nfs.org>,
	netdev ML <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Aur=E9lien_Charbon?= <aurelien.charbon@ext.bull.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:56967 "EHLO atlrel8.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760304AbXJLQIT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Oct 2007 12:08:19 -0400
In-Reply-To: <470F3AF2.8000706@ext.bull.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Aurelien,

There were some of my comments you haven't addressed yet, comments in-l=
ine.

Aur=E9lien Charbon wrote:
> Here is a patch for the ip_map caching code part in nfs server.

> +    for (i =3D 0; i < ncp->cl_naddr; i++) {
> +        /* Mapping address */
> +        ipv6_addr_v4map(ncp->cl_addrlist[i], addr6);

ipv6_addr_set(&addr6, 0, 0, htonl(0x0000FFFF), ncp->cl_addrlist[i]);

> +    /* IPv6 address mapping */
> +    ipv6_addr_v4map(sin->sin_addr, in6);

ipv6_addr_set(&in6, 0, 0, htonl(0x0000FFFF), sin->sin_addr);

> +    /* IPv6 address mapping */
> +    ipv6_addr_v4map(sin->sin_addr, in6);

ipv6_addr_set(&in6, 0, 0, htonl(0x0000FFFF), sin->sin_addr);

> +#define IS_ADDR_MAPPED(a) \
> +    (((uint32_t *) (a))[0] =3D=3D 0            \
> +    && ((uint32_t *) (a))[1] =3D=3D 0            \
> +    && (((uint32_t *) (a))[2] =3D=3D 0            \
> +    || ((uint32_t *) (a))[2] =3D=3D htonl(0xffff)))

This is unused, can go away.

> +static inline void ipv6_addr_v4map(const struct in_addr a1, struct=20
> in6_addr a2)
> +{
> +    a2.s6_addr32[0] =3D 0;
> +    a2.s6_addr32[1] =3D 0;
> +    a2.s6_addr32[2] =3D htonl(0xffff);
> +    a2.s6_addr32[3] =3D (uint32_t)a1.s_addr;
> +}

If you use ipv6_addr_set() everywhere you don't need this.

> static inline int ipv6_addr_v4mapped(const struct in6_addr *a)
> {
>     return ((a->s6_addr32[0] | a->s6_addr32[1]) =3D=3D 0 &&
> -         a->s6_addr32[2] =3D=3D htonl(0x0000ffff));
> +        a->s6_addr32[2] =3D=3D htonl(0x0000ffff));
> }

Guessing you changed a tab to a space, unnecessary.

> -static struct ip_map *ip_map_lookup(char *class, struct in_addr addr=
);
> +static struct ip_map *ip_map_lookup(char *class, struct in6_addr add=
r);

I still think you should pass a pointer here.

> -int auth_unix_add_addr(struct in_addr addr, struct auth_domain *dom)
> +int auth_unix_add_addr(struct in6_addr addr, struct auth_domain *dom=
)

And here.

> -struct auth_domain *auth_unix_lookup(struct in_addr addr)
> +struct auth_domain *auth_unix_lookup(struct in6_addr addr)

And here.

-Brian
