From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [v4 PATCH 1/2] NETFILTER module xt_hmark, new target for HASH
 based fwmark
Date: Fri, 25 Nov 2011 15:43:52 +0100
Message-ID: <1322232232.2403.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1322213787-25796-1-git-send-email-hans@schillstrom.com>
	 <1322213787-25796-2-git-send-email-hans@schillstrom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kaber@trash.net, pablo@netfilter.org, jengelh@medozas.de,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	hans.schillstrom@ericsson.com
To: Hans Schillstrom <hans@schillstrom.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1322213787-25796-2-git-send-email-hans@schillstrom.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 25 novembre 2011 =C3=A0 10:36 +0100, Hans Schillstrom a =C3=
=A9crit :
> From: Hans Schillstrom <hans.schillstrom@ericsson.com>
>=20
> The target allows you to create rules in the "raw" and "mangle" table=
s
> which alter the netfilter mark (nfmark) field within a given range.
> First a 32 bit hash value is generated then modulus by <limit> and
> finally an offset is added before it's written to nfmark.
> Prior to routing, the nfmark can influence the routing method (see
> "Use netfilter MARK value as routing key") and can also be used by
> other subsystems to change their behavior.
>=20


Oh well, yet another duplicated flow dissector ...

> +/*
> + * Calc hash value, special casre is taken on icmp and fragmented me=
ssages
> + * i.e. fragmented messages don't use ports.
> + */
> +__u32 hmark_v6(struct sk_buff *skb, const struct xt_action_param *pa=
r)
> +{
> +	struct xt_hmark_info *info =3D (struct xt_hmark_info *)par->targinf=
o;



> +no6ports:
> +	nexthdr &=3D info->prmask;
> +	/* get a consistent hash (same value on both flow directions) */
> +	if (addr2 < addr1)
> +		swap(addr1, addr2);
> +	hash =3D jhash_3words(addr1, addr2, ports.v32, info->hashrnd) ^ nex=
thdr;

whats the point computing hash, if info->hmod is null, since we dont se=
t
skb->mark ?

> +	if (info->hmod)
> +		skb->mark =3D (hash % info->hmod) + info->hoffs;
> +
> +	return XT_CONTINUE;
> +}
> +#endif
> +


Same problem/question on hmark_v4()


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
