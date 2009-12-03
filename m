From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4] net: Introduce realloc_netdev_mq()
Date: Thu, 03 Dec 2009 22:51:25 +0100
Message-ID: <4B1832DD.1070805@gmail.com>
References: <4B17EFE3.4080301@gmail.com>	<20091203202937.GA11436@ami.dom.local>	<4B182DC6.5030800@gmail.com> <20091203.133108.254093305.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jarkao2@gmail.com, mchan@broadcom.com, kaber@trash.net,
	netdev@vger.kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:34077 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750765AbZLCVva (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 16:51:30 -0500
In-Reply-To: <20091203.133108.254093305.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 03 Dec 2009 22:29:42 +0100
>=20
>> Nice patch, thanks :)
>>
>> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> I like it too, but please resubmit once we have at least
> one example user submitted.
>=20

I successfully tested following patch.

Thanks !

[PATCH] ixgbe: Use realloc_netdev_mq() helper

Instead of 128 tx queues, we can cap the tx queue number to what driver=
 really uses.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_m=
ain.c
index 9ba506f..e524d0d 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3306,7 +3306,7 @@ static void ixgbe_set_num_queues(struct ixgbe_ada=
pter *adapter)
=20
 done:
 	/* Notify the stack of the (possibly) reduced Tx Queue count. */
-	adapter->netdev->real_num_tx_queues =3D adapter->num_tx_queues;
+	realloc_netdev_mq(adapter->netdev, adapter->num_tx_queues);
 }
=20
 static void ixgbe_acquire_msix_vectors(struct ixgbe_adapter *adapter,

