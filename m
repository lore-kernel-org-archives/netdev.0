From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4] net: Introduce realloc_netdev_mq()
Date: Fri, 04 Dec 2009 00:04:42 +0100
Message-ID: <4B18440A.2080507@gmail.com>
References: <4B17EFE3.4080301@gmail.com> <20091203202937.GA11436@ami.dom.local> <4B182DC6.5030800@gmail.com> <20091203.133108.254093305.davem@davemloft.net> <4B1832DD.1070805@gmail.com> <20091203224742.GA16646@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, mchan@broadcom.com,
	kaber@trash.net, netdev@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:39714 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750765AbZLCXEo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 18:04:44 -0500
In-Reply-To: <20091203224742.GA16646@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski a =E9crit :
> On Thu, Dec 03, 2009 at 10:51:25PM +0100, Eric Dumazet wrote:
>> David Miller a =E9crit :
>>> From: Eric Dumazet <eric.dumazet@gmail.com>
>>> Date: Thu, 03 Dec 2009 22:29:42 +0100
>>>
>>>> Nice patch, thanks :)
>>>>
>>>> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
>>> I like it too, but please resubmit once we have at least
>>> one example user submitted.
>>>
>> I successfully tested following patch.
>=20
> Great! But, I see, checking if realloc_netdev_mq() use is always lega=
l
> (before register_netdev()) is not trivial in this driver. (I have som=
e
> suspicions around ixgbe_resume().) I wonder, if there should be added
> some debugging for this.

Yes, probably

Or even better, allowing realloc_netdev_mq() to be called even after
register_netdev() :)

bnx2 for example could not be patched easily, following patch doesnt wo=
rk.

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 4cae2a8..8bd5d0d 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -6177,6 +6177,7 @@ bnx2_setup_int_mode(struct bnx2 *bp, int dis_msi)
=20
 	bp->num_tx_rings =3D rounddown_pow_of_two(bp->irq_nvecs);
-	bp->dev->real_num_tx_queues =3D bp->num_tx_rings;
+	realloc_netdev_mq(bp->dev, bp->num_tx_rings);
=20
 	bp->num_rx_rings =3D bp->irq_nvecs;
 }

