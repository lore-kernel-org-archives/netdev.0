From: =?iso-8859-1?Q?Fran=E7ois-Xavier_Le_Bail?= <fx.lebail@yahoo.com>
Subject: Re: [PATCH net-next v4] IPv6: use anycast addresses as source addresses in echo reply
Date: Mon, 6 Jan 2014 13:53:49 -0800 (PST)
Message-ID: <1389045229.42277.YahooMailBasic@web125505.mail.ne1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: hannes@stressinduktion.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm40.bullet.mail.ne1.yahoo.com ([98.138.229.33]:28541 "HELO
	nm40.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756099AbaAFV4d convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jan 2014 16:56:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 1/6/14, David Miller <davem@davemloft.net> wrote:

> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Mon, 6 Jan 2014 00:05:05 +0100

>> On Fri, Jan 03, 2014 at 05:43:31PM +0100, Francois-Xavier Le Bail wr=
ote:
>>> diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
>>> index 5d42009..65c8619 100644
>>> --- a/net/ipv6/icmp.c
>>> +++ b/net/ipv6/icmp.c
>>> @@ -556,7 +556,9 @@ static void icmpv6_echo_reply(struct sk_buff *s=
kb)
>>>=A0=20
>>>=A0 =A0=A0=A0 saddr =3D &ipv6_hdr(skb)->daddr;
>>>=A0=20
>>> -=A0=A0=A0 if (!ipv6_unicast_destination(skb))
>>> +=A0=A0=A0 if (!ipv6_unicast_destination(skb) &&
>>> +=A0=A0=A0 =A0 =A0 !(net->ipv6.anycast_src_echo_reply &&
>>> +=A0=A0=A0 =A0 =A0 =A0 ipv6_chk_acast_addr(net, NULL, saddr)))
>>>=A0 =A0=A0=A0 =A0=A0=A0 saddr =3D NULL;
>>=20
>> I am not sure why you left out the device at ipv6_chk_acast_addr?
>>=20
>> IMHO this logic is a bit more complex, we can pass NULL for ipv6 add=
resses of
>> scope global but need to check the interface for scope link.
>>=20
>> It is already possible via setsockopt JOIN_ANYCAST that an ll addres=
s is
>> anycast on another interface which may not be checked here.

> I think we should pass a valid device in unless it breaks something
> obvious.

The problem is that "saddr" is not necessarily an address on "skb->dev"
in icmpv6_echo_reply(). It may be an address on another interface.

If dev arg is NULL, ipv6_chk_acast_addr() searches all devices for "sad=
dr", that what we need.

It works for global scope and link-local anycast address.

So passing a valid device to ipv6_chk_acast_addr() breaks the goal of t=
he patch.

Thanks.
