From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [patch net-next-2.6 V3] net: convert bonding to use rx_handler
Date: Sun, 27 Feb 2011 21:59:24 +0100
Message-ID: <4D6ABB2C.4070504@gmail.com>
References: <1298039252.6201.66.camel@edumazet-laptop> <4D5E8655.5070304@trash.net> <20110218145850.GF2939@psychotron.redhat.com> <20110218.120656.104048936.davem@davemloft.net> <20110218205832.GE2602@psychotron.redhat.com> <20110223190541.GB2783@psychotron.redhat.com> <4D6A5CDD.4020009@gmail.com> <20110227200628.GA2984@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, fubar@us.ibm.com,
	andy@greyhouse.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:59969 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751078Ab1B0U71 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Feb 2011 15:59:27 -0500
Received: by fxm17 with SMTP id 17so3176420fxm.19
        for <netdev@vger.kernel.org>; Sun, 27 Feb 2011 12:59:26 -0800 (PST)
In-Reply-To: <20110227200628.GA2984@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 27/02/2011 21:06, Jiri Pirko a =E9crit :
> Sun, Feb 27, 2011 at 03:17:01PM CET, nicolas.2p.debian@gmail.com wrot=
e:

>>> +	if (bond_should_deliver_exact_match(skb, slave_dev, bond_dev)) {
>>> +		skb->deliver_no_wcard =3D 1;
>>> +		return skb;
>>
>> Shouldn't we return NULL here ?
>
> No we shouldn't. We need sbk to be delivered to exact match.

So, if I understand properly:

- If skb->dev changed, loop,
- else, if skb->deliver_no_wcard, do exact match delivery only,
- Else, if !skb, drop the frame, without ever exact match delivery,
- Else, do normal delivery.

Right?

>> The vlan_on_bond case used to be cost effective. Now, we clone the s=
kb and call netif_rx...
>
> This should not cost too much overhead considering only few packets a=
re
> going thru this. This hook shouldn't have exited in the fisrt place. =
I
> think introducing this functionality was a big mistake.

What would you have proposed instead?

Anyway, I think the feature is broken, because it wouldn't provide the =
expected effect on the=20
following configuration:

eth0/eth1 -> bond0 -> br0 -> br0.100.

We probably need a more general way to fix this, after your patch have =
been accepted.

[snip]

>> I would instead consider NULL as meaning exact-match-delivery-only.
>> (The same effect as dev_bond_should_drop() returning true).
>
> we can change the behaviour later on.

Agreed.

	Nicolas.
