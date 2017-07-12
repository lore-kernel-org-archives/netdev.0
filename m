From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [PATCH net] nfp: freeing the wrong variable
Date: Wed, 12 Jul 2017 10:42:06 +0300
Message-ID: <20170712074206.otviyjx2qhuz3snt@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Simon Horman <simon.horman@netronome.com>,
        oss-drivers@netronome.com, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        Pieter Jansen van Vuuren
        <pieter.jansenvanvuuren@netronome.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We accidentally free a NULL pointer and leak the pointer we want to
free.  Also you can tell from the label name what was intended.  :)

Fixes: abfcdc1de9bf ("nfp: add a stats handler for flower offloads")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/netronome/nfp/flower/metadata.c b/drivers/net/ethernet/netronome/nfp/flower/metadata.c
index fec0ff2ca94f..3226ddc55f99 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/metadata.c
+++ b/drivers/net/ethernet/netronome/nfp/flower/metadata.c
@@ -419,7 +419,7 @@ int nfp_flower_metadata_init(struct nfp_app *app)
 	return 0;
 
 err_free_last_used:
-	kfree(priv->stats_ids.free_list.buf);
+	kfree(priv->mask_ids.last_used);
 err_free_mask_id:
 	kfree(priv->mask_ids.mask_id_free_list.buf);
 	return -ENOMEM;
