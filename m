From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] skge: add byte queue limit support
Date: Sun, 22 Jan 2012 14:25:01 -0500 (EST)
Message-ID: <20120122.142501.1342631979051946828.davem@davemloft.net>
References: <20120119164354.78ea63d6@nehalam.linuxnetplumber.net>
	<1327040624.4826.10.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48977 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752393Ab2AVTZE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2012 14:25:04 -0500
In-Reply-To: <1327040624.4826.10.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 20 Jan 2012 07:23:44 +0100

> Le jeudi 19 janvier 2012 =E0 16:43 -0800, Stephen Hemminger a =E9crit=
 :
>> This also changes the cleanup logic slightly to aggregate
>> completed notifications for multiple packets.
>>=20
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>>=20
>> --- a/drivers/net/ethernet/marvell/skge.c	2012-01-19 16:12:19.000000=
000 -0800
>> +++ b/drivers/net/ethernet/marvell/skge.c	2012-01-19 16:42:17.675908=
798 -0800
>> @@ -2831,6 +2831,7 @@ static netdev_tx_t skge_xmit_frame(struc
>>  		netif_stop_queue(dev);
>>  	}
>> =20
>> +	netdev_sent_queue(dev, skb->len);
>=20
>=20
> I doubt this is safe, as skb might already be freed by tx completion
> handler from another cpu.

Oops, I'll not apply this for now then.
