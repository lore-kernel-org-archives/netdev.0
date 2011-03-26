From: =?ISO-8859-2?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [Bonding-devel] bonding inside a bridge does not work when using
 arp monitoring
Date: Sat, 26 Mar 2011 21:32:53 +0100
Message-ID: <4D8E4D75.1020206@gmail.com>
References: <1300302933.1462.5.camel@bordalnx> <4D8121EF.3030200@free.fr> <1300914794.32252.68.camel@bordalnx> <4D8DDA06.4040704@gmail.com> <20110326140115.GA2882@psychotron.redhat.com> <AANLkTimkVqHaU=Ye96xK4Zs7XyzcL3Xgh5ouz5m2KXur@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jpirko@redhat.com>,
	=?ISO-8859-2?Q?Nicolas_de_Peslo=FC?= =?ISO-8859-2?Q?an?=
	<nicolas.2p.debian@free.fr>,
	Bridge <bridge@lists.linux-foundation.org>,
	bonding-devel@lists.sourceforge.net,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>,
	Leonardo Borda <leonardo.borda@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:63159 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753985Ab1CZUc6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Mar 2011 16:32:58 -0400
Received: by wya21 with SMTP id 21so1920908wya.19
        for <netdev@vger.kernel.org>; Sat, 26 Mar 2011 13:32:56 -0700 (PDT)
In-Reply-To: <AANLkTimkVqHaU=Ye96xK4Zs7XyzcL3Xgh5ouz5m2KXur@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 26/03/2011 16:42, Micha=B3 Miros=B3aw a =E9crit :
> 2011/3/26 Jiri Pirko<jpirko@redhat.com>:
>> Sat, Mar 26, 2011 at 01:20:22PM CET, nicolas.2p.debian@gmail.com wro=
te:
>>> Le 23/03/2011 22:13, Leonardo Borda a =E9crit :
>>>> Thank you for answering my question.
>>>> Actually this is what I want to achieve:
>>>>
>>>> eth0----+               +----bond0.100----br0-100---{+virtual mach=
ines
>>>>            |             |
>>>>            +----bond0----+----br0---(LAN)
>>>>            |             |
>>>> eth1----+               +----bond0.200----br0-200---{+virtual mach=
ines
>>>
>>> Hi Leonardo,
>>>
>>> I'm not sure recent kernels allow for a given interface to be a por=
t
>>> for a bridge and the base interface for vlan interfaces at the same
>>> time. This might be particularly true for 2.6.38 or 2.6.38+, becaus=
e
>>> of the new rx_handler usage.
>>
>> This topology is not legit and should/will be prohibited.
>>
>> Only consider that you have + br0.100 device on top of br0. Where sh=
ould
>> the packet go?
>>
>> I suggest to consider topology change.
>
> It should be possible to have bridge for untagged (or 802.1p only)
> packets independent of 802.1q tagged packets. I wonder if tag 0
> devices should be expanded to have a flag that will enable handling
> untagged packets by it.

Isn't the BROUTING chain of the broute table of ebtables designed exact=
ly for that?

I think DROPing in this chain should allow delivery to VLAN:

In br_input.c :

                 rhook =3D rcu_dereference(br_should_route_hook);
                 if (rhook) {
                         if ((*rhook)(skb)) {
                                 *pskb =3D skb;
                                 return RX_HANDLER_PASS;
                         }

RX_HANDLER_PASS causes the skb to be normally delivered in __netif_rece=
ive_skb.

Leonardo, would you please try to DROP vlan tagged packets in the BROUT=
ING chain of the broute table=20
of ebtables?

	Nicolas.
