From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Fix IP_MULTICAST_IF
Date: Tue, 20 Oct 2009 06:16:02 +0200
Message-ID: <4ADD3982.2040100@gmail.com>
References: <4ADC96D6.4000909@gmail.com> <20091019.205948.193706797.davem@davemloft.net> <4ADD3794.8030906@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:54254 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750795AbZJTEQB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 00:16:01 -0400
In-Reply-To: <4ADD3794.8030906@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> David Miller a =E9crit :
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Mon, 19 Oct 2009 18:41:58 +0200
>>
>>> ipv4/ipv6 setsockopt(IP_MULTICAST_IF) have dubious __dev_get_by_ind=
ex() calls.
>> Dubious, how so?
>>
>> Yes, I know RTNL/dev_base_lock, but it's not using what it gets
>> back at all.
>>
>> It's testing existence, a boolean, it doesn't dereference the
>> 'dev' it gets back at all.
>>
>> This code is intentional and perfectly fine.
>=20
> If this was intentional, something changed and made the prereq false.
>=20
> Final target might be fine, but an element in the chain, before targe=
t
> could be deleted while reader scans hash chain.
>=20

BTW, even an insertion can crash a lockless reader, since reader could =
see a corrupt
 n->next (hlist_add_head() has no barrier between n->next =3D first and=
 h->first =3D n;)

static inline void hlist_add_head(struct hlist_node *n, struct hlist_he=
ad *h)
{
        struct hlist_node *first =3D h->first;
        n->next =3D first;
        if (first)
                first->pprev =3D &n->next;
        h->first =3D n;
        n->pprev =3D &h->first;
}

