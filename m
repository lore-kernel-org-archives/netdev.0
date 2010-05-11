From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 72/84] netfilter: xtables: inclusion of xt_TEE
Date: Tue, 11 May 2010 13:42:02 +0200
Message-ID: <4BE9428A.5090402@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>	 <1273522735-24672-73-git-send-email-kaber@trash.net> <1273524779.2590.236.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1273524779.2590.236.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> Le lundi 10 mai 2010 =E0 22:18 +0200, kaber@trash.net a =E9crit :
>> From: Jan Engelhardt <jengelh@medozas.de>
>>
>> xt_TEE can be used to clone and reroute a packet. This can for
>> example be used to copy traffic at a router for logging purposes
>> to another dedicated machine.
>>
>> References: http://www.gossamer-threads.com/lists/iptables/devel/687=
81
>> Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
>> Signed-off-by: Patrick McHardy <kaber@trash.net>
>> ---
>=20
>> +static bool tee_tg_route_oif(struct flowi *f, struct net *net,
>> +			     const struct xt_tee_tginfo *info)
>> +{
>> +	const struct net_device *dev;
>> +
>> +	if (*info->oif !=3D '\0')
>> +		return true;
>> +	dev =3D dev_get_by_name(net, info->oif);
>> +	if (dev =3D=3D NULL)
>> +		return false;
>> +	f->oif =3D dev->ifindex;
>> +	return true;
>> +}
>> +
>=20
> This leaks a refcount on device.
>=20
> But I see patch 76/84 replaces the whole thing, so this is probably
> harmless.

Correct, that patch replaces the per-packet lookup and uses
netdevice notifiers to store the ifindex of the output device,
without keeping a reference at all.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
