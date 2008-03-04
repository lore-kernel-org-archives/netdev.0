From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [IPV4]: Add an 'rtable' field in struct sk_buff to alias 'dst'
 field and avoid casts
Date: Tue, 04 Mar 2008 08:36:43 +0100
Message-ID: <47CCFC0B.7060801@cosmosbay.com>
References: <47CCF71D.2030800@cosmosbay.com> <20080303.232342.221759327.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from neuf-infra-smtp-out-sp604007av.neufgp.fr ([84.96.92.120]:57393
	"EHLO neuf-infra-smtp-out-sp604007av.neufgp.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1763991AbYCDHgr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 02:36:47 -0500
In-Reply-To: <20080303.232342.221759327.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Tue, 04 Mar 2008 08:15:41 +0100
>=20
>> @@ -223,7 +223,7 @@ static int br_nf_pre_routing_finish_ipv6(struct =
sk_buff *skb)
>>  	}
>>  	nf_bridge->mask ^=3D BRNF_NF_BRIDGE_PREROUTING;
>> =20
>> -	skb->dst =3D (struct dst_entry *)&__fake_rtable;
>> +	skb->dst =3D &__fake_rtable.u.dst;
>>  	dst_hold(skb->dst);
>> =20
>>  	skb->dev =3D nf_bridge->physindev;
>=20
> Any reason this case (and the next 3 hunks) can't simply
> use just plain "&__fake_rtable"?  That would probably
> look nicer and match the rest of this patch.
>=20
>=20
>=20

Yes, I had this idea, but felt that it was better in this case to have =
a=20
dst_hold() that refers to the above affectation.

skb->dst =3D &__fake_rtable.u.dst;
dst_hold(skb->dst);

instead of

skb->rtable =3D &__fake_rtable;
dst_hold(skb->dst);

Do you prefer the later ?

