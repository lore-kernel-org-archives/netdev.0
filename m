From: Shirley Ma <mashirle@us.ibm.com>
Subject: [PATCH next-next-2.6 v2] virtio_net: missing sg_init_table
Date: Mon, 29 Mar 2010 18:19:15 -0700
Message-ID: <1269911955.14013.4.camel@localhost.localdomain>
References: <1269887518.13277.13.camel@localhost.localdomain>
	 <4BB10010.5060505@mathtm.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas =?ISO-8859-1?Q?M=FCller?= <thomas@mathtm.de>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:40957 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754540Ab0C3BTT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Mar 2010 21:19:19 -0400
In-Reply-To: <4BB10010.5060505@mathtm.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add missing sg_init_table for sg_set_buf in virtio_net which
induced in defer skb patch.

Reported-by: Thomas M=C3=BCller <thomas@mathtm.de>
Tested-by: Thomas M=C3=BCller <thomas@mathtm.de>
Signed-off-by: Shirley Ma <xma@us.ibm.com>

---
 drivers/net/virtio_net.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 25dc77c..3f5be35 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -326,6 +326,7 @@ static int add_recvbuf_small(struct virtnet_info *v=
i, gfp_t gfp)
 	struct scatterlist sg[2];
 	int err;
=20
+	sg_init_table(sg, 2);
 	skb =3D netdev_alloc_skb_ip_align(vi->dev, MAX_PACKET_LEN);
 	if (unlikely(!skb))
 		return -ENOMEM;
@@ -351,6 +352,7 @@ static int add_recvbuf_big(struct virtnet_info *vi,=
 gfp_t gfp)
 	char *p;
 	int i, err, offset;
=20
+	sg_init_table(sg, MAX_SKB_FRAGS + 2);
 	/* page in sg[MAX_SKB_FRAGS + 1] is list tail */
 	for (i =3D MAX_SKB_FRAGS + 1; i > 1; --i) {
 		first =3D get_a_page(vi, gfp);


