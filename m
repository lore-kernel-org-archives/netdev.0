From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6] net: reinject arps into bonding slave
	instead of master
Date: Thu, 10 Mar 2011 21:52:37 +0100
Message-ID: <20110310205237.GE2837@psychotron.redhat.com>
References: <20110308134247.GW11864@gospo.rdu.redhat.com>
 <4D76A345.9040200@gmail.com>
 <20110309074547.GA2808@psychotron.redhat.com>
 <4D77938D.3080408@gmail.com>
 <20110309150939.GA9013@psychotron.brq.redhat.com>
 <4D779CA2.1050302@gmail.com>
 <20110309171100.GA2842@psychotron.redhat.com>
 <4D77FCC1.5050904@gmail.com>
 <20110310064829.GA3261@psychotron.redhat.com>
 <4D793845.1060702@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com
To: Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50492 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751125Ab1CJUws (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Mar 2011 15:52:48 -0500
Content-Disposition: inline
In-Reply-To: <4D793845.1060702@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Mar 10, 2011 at 09:44:53PM CET, nicolas.2p.debian@gmail.com wrote:
>Le 10/03/2011 07:48, Jiri Pirko a =E9crit :
>>>But for all others setups, where there exist some net_devices before
>>>the "untagging" one, you would face some troubles. For example, with
>>>eth0+eth1 ->  br0 ->  br0.100, you cannot untag before entering
>>>__netif_receive_skb. If you do so, the bridge would receive untagged
>>>frame and if the frame is not for the local host, the bridge would
>>>forward an untagged frame while it is expected to forward a tagged
>>>one. Even if the bridge is in a position to know the frame *was*
>>>tagged, we cannot expect the bridge to do special processing to
>>>handle this situation. Doing so would break layering.
>>
>>I disagree.
>>eth0 ->  untag on early __netif_receive_skb (sets up skb->vlan_tci)
>>            ->rx_handler of bridge
>>->br0 ->  tag is detected by vlan_tx_tag_present()
>>            ->  reinject to __netif_receive_skb with skb->dev =3D=3D =
br0.100
>
>For local delivery, is should work.
>
>But if the bridge must forward the frame to another host (bridges are
>designed for such things :-)), it will have to insert the vlan header
>back into the frame. I don't understand how it could work
>automagically in this situation.

This works for hw_accel path. Would look the same.

>
>>This way the flow would be very similar to vlan-hw-accel, am I right?
>
>So your point is to remove any 802.1Q header in any ingres frame,
>whatever the local interface setup. Right?
>
>How would this support nested vlan headers?
>
>eth0 -> eth0.100 -> eth0.100.200 -> eth0.100.200.300.
>
>Who will choose eth0.100.200.300 as the last skb->dev?

Hate to think about this more, that's for sure.

>
>>I have following patch in mind. Note it's raw DRAFT.
>
>I need to take some time to review your patch.
>
>In the mean time, what is the status of the whole patch series? Can we=
 expect an ACK from someone?

It was posponed by davem. I plan to solve vlans first, then repost the
whole series (so that bond recv_probe would see vlan arps)
>
>	Nicolas.
