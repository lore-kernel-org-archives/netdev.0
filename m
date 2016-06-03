From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net/mlx4_en: mlx4_en_netpoll() should schedule TX,
 not RX
Date: Fri, 03 Jun 2016 11:52:49 -0700
Message-ID: <1464979969.5939.200.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1464195039-5098-1-git-send-email-edumazet@google.com>
	 <1464195039-5098-5-git-send-email-edumazet@google.com>
	 <6320ccdc-d369-c08c-c959-6c8ed9b88d10@gmail.com>
	 <1464267580.5939.83.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Willem de Bruijn <willemb@google.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: Tariq Toukan <ttoukan.linux@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:33342 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932188AbcFCSwy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 14:52:54 -0400
Received: by mail-pa0-f66.google.com with SMTP id di3so6539736pab.0
        for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 11:52:53 -0700 (PDT)
In-Reply-To: <1464267580.5939.83.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <edumazet@google.com>

I am not sure mlx4_en_netpoll() is doing anything useful right now.

mlx4 has different NAPI structures for RX and TX, and netpoll only want=
s
to drain TX queues.

Lets schedule NAPI polls on TX, not RX.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Maciej =C5=BBenczykowski <maze@google.com>
Cc: Eric W. Biederman <ebiederm@xmission.com>
---
Totally untested patch, I would appreciate some feedback before merge,
thanks !

 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/n=
et/ethernet/mellanox/mlx4/en_netdev.c
index 19ceced6736c..973391bfe286 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1197,8 +1197,8 @@ static void mlx4_en_netpoll(struct net_device *de=
v)
 	struct mlx4_en_cq *cq;
 	int i;
=20
-	for (i =3D 0; i < priv->rx_ring_num; i++) {
-		cq =3D priv->rx_cq[i];
+	for (i =3D 0; i < priv->tx_ring_num; i++) {
+		cq =3D priv->tx_cq[i];
 		napi_schedule(&cq->napi);
 	}
 }
