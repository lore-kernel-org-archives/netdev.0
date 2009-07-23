From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] be2net: Adding support for 802.1ad (q-in-q mode)
Date: Thu, 23 Jul 2009 11:48:23 +0200
Message-ID: <4A6831E7.3020302@trash.net>
References: <20090723082552.GA602@serverengines.com> <4A6823B5.7050608@trash.net> <20090723090216.GA1761@serverengines.com> <4A68284B.8020100@trash.net> <20090723092036.GB1761@serverengines.com> <4A682CA1.8030706@trash.net> <20090723094501.GA3172@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64511 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753444AbZGWJsY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2009 05:48:24 -0400
In-Reply-To: <20090723094501.GA3172@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sarveshwar Bandi wrote:
> On 23/07/09 11:25 +0200, Patrick McHardy wrote:
>> Sarveshwar Bandi wrote:
>>> On 23/07/09 11:07 +0200, Patrick McHardy wrote:
>>>>> Patch has code to check if the controller is in q-in-q mode. When the packet
>>>>> has two vids, only the inner vid is passed onto the stack. The stack is never
>>>>> made aware of the outer vid.
>>>> But you're still using the outer VLAN group when passing the packet to
>>>> the VLAN code, so the association to the correct VLAN device can't work.
>>> In the case where packet comes with two vlan ids, the rx descriptor contains
>>> the inner vlan id and qnq is set to 1, the driver indicates this vid to the
>>> stack.
>>> In the case where packet comes with single vlan id, the rx descriptor
>>> contains the outer vlan id and qnq is set to 0, the driver indicates this
>>> packet as a non-vlan packet to the stack by calling netif_receive_skb.
>> I understand that. But the driver does:
>>
>> 	if (vtp) {
>> 		if (!adapter->vlan_grp || adapter->num_vlans == 0) {
>> 			kfree_skb(skb);
>> 			return;
>> 		}
>> 		vid = AMAP_GET_BITS(struct amap_eth_rx_compl, vlan_tag, rxcp);
>> 		vid = be16_to_cpu(vid);
>> 		vlan_hwaccel_receive_skb(skb, adapter->vlan_grp, vid);
>> 	}
>>
>> adapter->vlan_grp will always be the VLAN group associated directly with
>> the device, which is the group for the outer tag, not the inner one. So
>> this can't properly associate packets with the correct VLAN device.
>>
> In this case, vid is the inner vlan id in the packet. This is also the
> vlan id configured by vconfig. 

So where does the outer tag come from then? Please provide an example
how to configure this using Q-in-Q.

> In the other case where packet had a single vlan tag, the following code
> will set vlanf to 0 (vtp now renamed to vlanf in the patch) and will be
> indicated as a non-vlan packet.
>        if (adapter->qnq && !qnq)
>                vlanf = 0;

