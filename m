From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] macvlan: add multiqueue capability
Date: Thu, 03 Sep 2009 20:08:52 +0200
Message-ID: <4AA00634.7050103@gmail.com>
References: <4A9F9661.7020301@gmail.com> <4AA002BC.3050507@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:41964 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754006AbZICSIx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 14:08:53 -0400
In-Reply-To: <4AA002BC.3050507@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy a =E9crit :
> Eric Dumazet wrote:
>> macvlan devices are currently not multi-queue capable.
>>
>> We can do that defining rtnl_link_ops method,
>> get_tx_queues(), called from rtnl_create_link()
>>
>> This new method gets num_tx_queues/real_num_tx_queues
>> from lower device.
>>
>> macvlan_get_tx_queues() is a copy of vlan_get_tx_queues().
>>
>> Because macvlan_start_xmit() has to update netdev_queue
>> stats only (and not dev->stats), I chose to change
>> tx_errors/tx_aborted_errors accounting to tx_dropped,
>> since netdev_queue structure doesnt define tx_errors /
>> tx_aborted_errors.
>=20
> The patch looks fine, but it just occured to me that this won't
> have any effect since both VLAN and macvlan use a tx_queue_len of 0,
> so they will by default have queueing disabled. In fact this
> will increase costs for the default case since we're now hashing
> every packet.

Good point !

We'll have to hash the packet later when hitting the lowerdevice,
which is multiqueue. No ?

Also, what's wrong with

ip link add link eth0 eth0.103 txqueuelen 100 type vlan id 103

;)


