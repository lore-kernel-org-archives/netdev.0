From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [patch net-next-2.6] net: reinject arps into bonding slave	instead
 of master
Date: Thu, 10 Mar 2011 21:44:53 +0100
Message-ID: <4D793845.1060702@gmail.com>
References: <20110307224338.GU11864@gospo.rdu.redhat.com> <20110308071350.GA2826@psychotron.redhat.com> <20110308134247.GW11864@gospo.rdu.redhat.com> <4D76A345.9040200@gmail.com> <20110309074547.GA2808@psychotron.redhat.com> <4D77938D.3080408@gmail.com> <20110309150939.GA9013@psychotron.brq.redhat.com> <4D779CA2.1050302@gmail.com> <20110309171100.GA2842@psychotron.redhat.com> <4D77FCC1.5050904@gmail.com> <20110310064829.GA3261@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:64298 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751774Ab1CJUo6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2011 15:44:58 -0500
Received: by wwa36 with SMTP id 36so2423862wwa.1
        for <netdev@vger.kernel.org>; Thu, 10 Mar 2011 12:44:57 -0800 (PST)
In-Reply-To: <20110310064829.GA3261@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 10/03/2011 07:48, Jiri Pirko a =E9crit :
>> But for all others setups, where there exist some net_devices before
>> the "untagging" one, you would face some troubles. For example, with
>> eth0+eth1 ->  br0 ->  br0.100, you cannot untag before entering
>> __netif_receive_skb. If you do so, the bridge would receive untagged
>> frame and if the frame is not for the local host, the bridge would
>> forward an untagged frame while it is expected to forward a tagged
>> one. Even if the bridge is in a position to know the frame *was*
>> tagged, we cannot expect the bridge to do special processing to
>> handle this situation. Doing so would break layering.
>
> I disagree.
> eth0 ->  untag on early __netif_receive_skb (sets up skb->vlan_tci)
>             ->rx_handler of bridge
> ->br0 ->  tag is detected by vlan_tx_tag_present()
>             ->  reinject to __netif_receive_skb with skb->dev =3D=3D =
br0.100

=46or local delivery, is should work.

But if the bridge must forward the frame to another host (bridges are d=
esigned for such things :-)),=20
it will have to insert the vlan header back into the frame. I don't und=
erstand how it could work=20
automagically in this situation.

> This way the flow would be very similar to vlan-hw-accel, am I right?

So your point is to remove any 802.1Q header in any ingres frame, whate=
ver the local interface=20
setup. Right?

How would this support nested vlan headers?

eth0 -> eth0.100 -> eth0.100.200 -> eth0.100.200.300.

Who will choose eth0.100.200.300 as the last skb->dev?

> I have following patch in mind. Note it's raw DRAFT.

I need to take some time to review your patch.

In the mean time, what is the status of the whole patch series? Can we =
expect an ACK from someone?

	Nicolas.
