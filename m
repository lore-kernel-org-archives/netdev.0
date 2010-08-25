From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: RE: [PATCH 01/14] mlx4_en: Fixed incorrect unmapping on RX flow.
Date: Wed, 25 Aug 2010 11:55:55 +0300
Message-ID: <E113D394D7C5DB4F8FF691FA7EE9DB443B56826877@MTLMAIL.mtl.com>
References: <4C73CCE1.6050609@mellanox.co.il>
	<20100824.150746.232758581.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eugenia Emantayev" <eugenia@mellanox.co.il>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:55984 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752749Ab0HYI4E convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 04:56:04 -0400
In-Reply-To: <20100824.150746.232758581.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> All 14 patches applied, but patches #12 and #13 had a lot of conflicts because the LRO options were already deleted by the patch I applied last week from Amerigo Wang:

> I fixed up the conflicts but please generate your patches against
> the correct tree in the future.

Apologize for this, I generated the patches against tree that was pulled a week ago.

> 
> I also had to add the following build warning fix after applying your
> patches, do you look at the build output at allwhen you make changes
> to this driver?

I suspect that these warnings were caused by the merge with the patch you mentioned,
The patches I sent remove this label:

@@ -312,28 +300,8 @@ int mlx4_en_create_rx_ring(struct mlx4_en_priv *priv,
        }
        ring->buf = ring->wqres.buf.direct.buf;

-       /* Configure lro mngr */
-       memset(&ring->lro, 0, sizeof(struct net_lro_mgr));
-       ring->lro.dev = priv->dev;
-       ring->lro.features = LRO_F_NAPI;
-       ring->lro.frag_align_pad = NET_IP_ALIGN;
-       ring->lro.ip_summed = CHECKSUM_UNNECESSARY;
-       ring->lro.ip_summed_aggr = CHECKSUM_UNNECESSARY;
-       ring->lro.max_desc = mdev->profile.num_lro;
-       ring->lro.max_aggr = MAX_SKB_FRAGS;
-       ring->lro.lro_arr = kzalloc(mdev->profile.num_lro *
-                                   sizeof(struct net_lro_desc),
-                                   GFP_KERNEL);
-       if (!ring->lro.lro_arr) {
-               en_err(priv, "Failed to allocate lro array\n");
-               goto err_map;
-       }
-       ring->lro.get_frag_header = mlx4_en_get_frag_header;
-
        return 0;

-err_map:
-       mlx4_en_unmap_buffer(&ring->wqres.buf);
 err_hwq:
        mlx4_free_hwq_res(mdev->dev, &ring->wqres, ring->buf_size);
 err_ring:


Thanks,
Yevgeny
