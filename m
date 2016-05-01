From: Julia Lawall <Julia.Lawall-L2FTfq7BK8M@public.gmane.org>
Subject: [PATCH] i40e: constify i40e_client_ops structure
Date: Sun,  1 May 2016 14:07:23 +0200
Message-ID: <1462104443-30724-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Tatyana Nikolova <tatyana.e.nikolova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Shiraz Saleem <shiraz.saleem-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Mustafa Ismail <mustafa.ismail-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Chien Tin Tung <chien.tin.tung-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Faisal Latif <faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Jesse Brandeburg <jesse.brandeburg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Shannon Nelson <shannon.nelson-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Carolyn Wyborny <carolyn.wyborny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Don Skidmore <donald.c.skidmore-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Bruce Allan <bruce.w.allan-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	John Ronciak <john.ronciak-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Mitch Williams <mitch.a.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	intel-wired-lan-qjLDD68F18P21nG7glBr7A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The i40e_client_ops structure is never modified, so declare it as const.

Done with the help of Coccinelle.

Signed-off-by: Julia Lawall <Julia.Lawall-L2FTfq7BK8M@public.gmane.org>

---
 drivers/infiniband/hw/i40iw/i40iw_main.c      |    2 +-
 drivers/net/ethernet/intel/i40e/i40e_client.h |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/hw/i40iw/i40iw_main.c b/drivers/infiniband/hw/i40iw/i40iw_main.c
index 90e5af2..e41fae24 100644
--- a/drivers/infiniband/hw/i40iw/i40iw_main.c
+++ b/drivers/infiniband/hw/i40iw/i40iw_main.c
@@ -1863,7 +1863,7 @@ static enum i40iw_status_code i40iw_virtchnl_send(struct i40iw_sc_dev *dev,
 }
 
 /* client interface functions */
-static struct i40e_client_ops i40e_ops = {
+static const struct i40e_client_ops i40e_ops = {
 	.open = i40iw_open,
 	.close = i40iw_close,
 	.l2_param_change = i40iw_l2param_change,
diff --git a/drivers/net/ethernet/intel/i40e/i40e_client.h b/drivers/net/ethernet/intel/i40e/i40e_client.h
index bf6b453..a4601d9 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_client.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_client.h
@@ -217,7 +217,7 @@ struct i40e_client {
 #define I40E_CLIENT_FLAGS_LAUNCH_ON_PROBE	BIT(0)
 #define I40E_TX_FLAGS_NOTIFY_OTHER_EVENTS	BIT(2)
 	enum i40e_client_type type;
-	struct i40e_client_ops *ops;	/* client ops provided by the client */
+	const struct i40e_client_ops *ops; /* client ops provided by the client */
 };
 
 static inline bool i40e_client_is_registered(struct i40e_client *client)

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
