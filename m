From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: fix softnet_stat
Date: Sun, 02 May 2010 22:29:25 -0700 (PDT)
Message-ID: <20100502.222925.171497866.davem@davemloft.net>
References: <1272814936-4902-1-git-send-email-xiaosuo@gmail.com>
	<1272818607.2173.133.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xiaosuo@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59602
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751773Ab0ECF3T convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 May 2010 01:29:19 -0400
In-Reply-To: <1272818607.2173.133.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 02 May 2010 18:43:27 +0200

> Le dimanche 02 mai 2010 =E0 23:42 +0800, Changli Gao a =E9crit :
>> fix softnet_stat
>>=20
>> Per cpu variable softnet_data.total was shared between IRQ and SoftI=
RQ context
>> without any protection. And enqueue_to_backlog should update the net=
dev_rx_stat
>> of the target CPU.
>>=20
>> This patch renames softnet_data.total to softnet_data.processed: the=
 number of
>> packets processed in uppper levels(IP stacks).
>>=20
>> softnet_stat data is moved into softnet_data.
>>=20
>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
>=20
> Thats a fine patch, thanks Changli.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied thanks.

I applied this follow-on patch to take the opportunity to clean up
something that has been bugging me for a long time, but never had the
energy to take care of :-)

net: Use explicit "unsigned int" instead of plain "unsigned" in netdevi=
ce.h

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/netdevice.h |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index c39938f..98112fb 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -878,7 +878,7 @@ struct net_device {
 	unsigned char		operstate; /* RFC2863 operstate */
 	unsigned char		link_mode; /* mapping policy to operstate */
=20
-	unsigned		mtu;	/* interface MTU value		*/
+	unsigned int		mtu;	/* interface MTU value		*/
 	unsigned short		type;	/* interface hardware type	*/
 	unsigned short		hard_header_len;	/* hardware hdr length	*/
=20
@@ -1381,10 +1381,10 @@ struct softnet_data {
 	struct sk_buff_head	process_queue;
=20
 	/* stats */
-	unsigned		processed;
-	unsigned		time_squeeze;
-	unsigned		cpu_collision;
-	unsigned		received_rps;
+	unsigned int		processed;
+	unsigned int		time_squeeze;
+	unsigned int		cpu_collision;
+	unsigned int		received_rps;
=20
 #ifdef CONFIG_RPS
 	struct softnet_data	*rps_ipi_list;
--=20
1.7.0.4

