From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC vlan 03/03]: propagate transmission state
Date: Tue, 09 Jun 2009 18:37:22 +0200
Message-ID: <4A2E8FC2.2030100@trash.net>
References: <20090609161658.6730.59754.sendpatchset@x2.localnet> <20090609161702.6730.72574.sendpatchset@x2.localnet> <4A2E8F27.3040202@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34118 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757508AbZFIQhX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 12:37:23 -0400
In-Reply-To: <4A2E8F27.3040202@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Patrick McHardy a =E9crit :
>>  static int vlan_dev_hwaccel_hard_start_xmit(struct sk_buff *skb,
>>  					    struct net_device *dev)
>>  {
>>  	struct netdev_queue *txq =3D netdev_get_tx_queue(dev, 0);
>> +	unsigned int len;
>>  	u16 vlan_tci;
>> +	int err;
>> =20
>>  	vlan_tci =3D vlan_dev_info(dev)->vlan_id;
>>  	vlan_tci |=3D vlan_dev_get_egress_qos_mask(dev, skb);
>> @@ -339,8 +347,15 @@ static int vlan_dev_hwaccel_hard_start_xmit(str=
uct sk_buff *skb,
>>  	txq->tx_bytes +=3D skb->len;
>=20
> It seems you forgot to delete previous txq->tx_bytes +=3D skb->len; &=
& txq->tx_packets++; ?

Indeed, thanks, I've fixed it in my tree.
