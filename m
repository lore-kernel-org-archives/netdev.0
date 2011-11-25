From: "Hans Schillstrom" <hans@schillstrom.com>
Subject: Re[2]:  [v4 PATCH 1/2] NETFILTER module xt_hmark, new target
	for HASH based fwmark
Date: Fri, 25 Nov 2011 15:53:40 +0100 (CET)
Message-ID: <g4pkas2.7c43881d3274cf7d84682b2c41f04688@obelix.schillstrom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kaber@trash.net, pablo@netfilter.org, jengelh@medozas.de,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	hans.schillstrom@ericsson.com
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>---- Original Message ----
>From: Eric Dumazet <eric.dumazet@gmail.com>
>To: "Hans Schillstrom" <hans@schillstrom.com>
>Cc: kaber@trash.net, pablo@netfilter.org, jengelh@medozas.de, netfilte=
r-devel@vger.kernel.org, netdev@vger.kernel.org, hans.schillstrom@erics=
son.com
>Sent: Fri, Nov 25, 2011, 3:43 PM
>Subject: Re: [v4 PATCH 1/2] NETFILTER module xt_hmark, new target for =
HASH based fwmark
>
>Le vendredi 25 novembre 2011 =C3=A0 10:36 +0100, Hans Schillstrom a =C3=
=A9crit :
>> From: Hans Schillstrom <hans.schillstrom@ericsson.com>
>>=20
>> The target allows you to create rules in the "raw" and "mangle" tabl=
es
>> which alter the netfilter mark (nfmark) field within a given range.
>> First a 32 bit hash value is generated then modulus by <limit> and
>> finally an offset is added before it's written to nfmark.
>> Prior to routing, the nfmark can influence the routing method (see
>> "Use netfilter MARK value as routing key") and can also be used by
>> other subsystems to change their behavior.
>>=20
>
>
>Oh well, yet another duplicated flow dissector ...
>
>> +/*
>> + * Calc hash value, special casre is taken on icmp and fragmented m=
essages
>> + * i.e. fragmented messages don't use ports.
>> + */
>> +__u32 hmark_v6(struct sk_buff *skb, const struct xt_action_param *p=
ar)
>> +{
>> +	struct xt_hmark_info *info =3D (struct xt_hmark_info *)par->targin=
fo;
>
>
>
>> +no6ports:
>> +	nexthdr &=3D info->prmask;
>> +	/* get a consistent hash (same value on both flow directions) */
>> +	if (addr2 < addr1)
>> +		swap(addr1, addr2);
>> +	hash =3D jhash_3words(addr1, addr2, ports.v32, info->hashrnd) ^ ne=
xthdr;
>
>whats the point computing hash, if info->hmod is null, since we dont s=
et
>skb->mark ?

No point at all :-)
I'll rearange that

>
>> +	if (info->hmod)
>> +		skb->mark =3D (hash % info->hmod) + info->hoffs;
>> +
>> +	return XT_CONTINUE;
>> +}
>> +#endif
>> +
>
>
>Same problem/question on hmark_v4()

Thanks
Hans

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
