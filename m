From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: [PATCH 11/13] pcmcia: pcmcia_request_window() doesn't need a pointer to a pointer
Date: Wed, 11 Nov 2009 21:38:17 +0100
Message-ID: <1257971899-9274-11-git-send-email-linux@dominikbrodowski.net>
References: <20091111203303.GA7939@comet.dominikbrodowski.net>
Cc: Dominik Brodowski <linux@dominikbrodowski.net>,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-scsi@vger.kernel.org, Jiri Kosina <jkosina@suse.cz>,
	Karsten Keil <isdn@linux-pingi.de>
To: <linux-pcmcia@lists.infradead.org>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20091111203303.GA7939@comet.dominikbrodowski.net>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pcmcia_request_window() only needs a pointer to struct pcmcia_device, not
a pointer to a pointer.

CC: netdev@vger.kernel.org
CC: linux-wireless@vger.kernel.org
CC: linux-scsi@vger.kernel.org
CC: Jiri Kosina <jkosina@suse.cz>
CC: Karsten Keil <isdn@linux-pingi.de>
Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
---
 drivers/char/pcmcia/ipwireless/main.c         |    4 ++--
 drivers/isdn/hisax/sedlbauer_cs.c             |    2 +-
 drivers/mtd/maps/pcmciamtd.c                  |    2 +-
 drivers/net/pcmcia/fmvj18x_cs.c               |    4 ++--
 drivers/net/pcmcia/ibmtr_cs.c                 |    4 ++--
 drivers/net/pcmcia/pcnet_cs.c                 |    4 ++--
 drivers/net/pcmcia/smc91c92_cs.c              |    2 +-
 drivers/net/pcmcia/xirc2ps_cs.c               |    2 +-
 drivers/net/wireless/airo_cs.c                |    2 +-
 drivers/net/wireless/b43/pcmcia.c             |    2 +-
 drivers/net/wireless/netwave_cs.c             |    2 +-
 drivers/net/wireless/ray_cs.c                 |    6 +++---
 drivers/net/wireless/wavelan_cs.c             |    2 +-
 drivers/pcmcia/pcmcia_resource.c              |    6 +++---
 drivers/scsi/pcmcia/nsp_cs.c                  |    2 +-
 drivers/staging/comedi/drivers/ni_daq_700.c   |    2 +-
 drivers/staging/comedi/drivers/ni_daq_dio24.c |    2 +-
 drivers/staging/comedi/drivers/ni_labpc_cs.c  |    2 +-
 include/pcmcia/ds.h                           |    2 +-
 19 files changed, 27 insertions(+), 27 deletions(-)

diff --git a/drivers/char/pcmcia/ipwireless/main.c b/drivers/char/pcmcia/ipwireless/main.c
index 10af1c0..082146a 100644
--- a/drivers/char/pcmcia/ipwireless/main.c
+++ b/drivers/char/pcmcia/ipwireless/main.c
@@ -116,7 +116,7 @@ static int ipwireless_probe(struct pcmcia_device *p_dev,
 		ipw->request_common_memory.Size = 0x1000;
 	ipw->request_common_memory.AccessSpeed = 0;
 
-	ret = pcmcia_request_window(&p_dev, &ipw->request_common_memory,
+	ret = pcmcia_request_window(p_dev, &ipw->request_common_memory,
 				&ipw->handle_common_memory);
 
 	if (ret != 0)
@@ -145,7 +145,7 @@ static int ipwireless_probe(struct pcmcia_device *p_dev,
 	ipw->request_attr_memory.Size = 0;	/* this used to be 0x1000 */
 	ipw->request_attr_memory.AccessSpeed = 0;
 
-	ret = pcmcia_request_window(&p_dev, &ipw->request_attr_memory,
+	ret = pcmcia_request_window(p_dev, &ipw->request_attr_memory,
 				&ipw->handle_attr_memory);
 
 	if (ret != 0)
diff --git a/drivers/isdn/hisax/sedlbauer_cs.c b/drivers/isdn/hisax/sedlbauer_cs.c
index 598e17a..331716f 100644
--- a/drivers/isdn/hisax/sedlbauer_cs.c
+++ b/drivers/isdn/hisax/sedlbauer_cs.c
@@ -272,7 +272,7 @@ static int sedlbauer_config_check(struct pcmcia_device *p_dev,
 		req->Base = mem->win[0].host_addr;
 		req->Size = mem->win[0].len;
 		req->AccessSpeed = 0;
-		if (pcmcia_request_window(&p_dev, req, &p_dev->win) != 0)
+		if (pcmcia_request_window(p_dev, req, &p_dev->win) != 0)
 			return -ENODEV;
 		map.Page = 0;
 		map.CardOffset = mem->win[0].card_addr;
diff --git a/drivers/mtd/maps/pcmciamtd.c b/drivers/mtd/maps/pcmciamtd.c
index 80b9005..689d6a7 100644
--- a/drivers/mtd/maps/pcmciamtd.c
+++ b/drivers/mtd/maps/pcmciamtd.c
@@ -530,7 +530,7 @@ static int pcmciamtd_config(struct pcmcia_device *link)
 		int ret;
 		DEBUG(2, "requesting window with size = %dKiB memspeed = %d",
 		      req.Size >> 10, req.AccessSpeed);
-		ret = pcmcia_request_window(&link, &req, &link->win);
+		ret = pcmcia_request_window(link, &req, &link->win);
 		DEBUG(2, "ret = %d dev->win_size = %d", ret, dev->win_size);
 		if(ret) {
 			req.Size >>= 1;
diff --git a/drivers/net/pcmcia/fmvj18x_cs.c b/drivers/net/pcmcia/fmvj18x_cs.c
index 6b9c79e..85f7c45 100644
--- a/drivers/net/pcmcia/fmvj18x_cs.c
+++ b/drivers/net/pcmcia/fmvj18x_cs.c
@@ -567,7 +567,7 @@ static int fmvj18x_get_hwinfo(struct pcmcia_device *link, u_char *node_id)
     req.Attributes = WIN_DATA_WIDTH_8|WIN_MEMORY_TYPE_AM|WIN_ENABLE;
     req.Base = 0; req.Size = 0;
     req.AccessSpeed = 0;
-    i = pcmcia_request_window(&link, &req, &link->win);
+    i = pcmcia_request_window(link, &req, &link->win);
     if (i != 0)
 	return -1;
 
@@ -618,7 +618,7 @@ static int fmvj18x_setup_mfc(struct pcmcia_device *link)
     req.Attributes = WIN_DATA_WIDTH_8|WIN_MEMORY_TYPE_AM|WIN_ENABLE;
     req.Base = 0; req.Size = 0;
     req.AccessSpeed = 0;
-    i = pcmcia_request_window(&link, &req, &link->win);
+    i = pcmcia_request_window(link, &req, &link->win);
     if (i != 0)
 	return -1;
 
diff --git a/drivers/net/pcmcia/ibmtr_cs.c b/drivers/net/pcmcia/ibmtr_cs.c
index 6fc89eb..14fe5fa 100644
--- a/drivers/net/pcmcia/ibmtr_cs.c
+++ b/drivers/net/pcmcia/ibmtr_cs.c
@@ -246,7 +246,7 @@ static int __devinit ibmtr_config(struct pcmcia_device *link)
     req.Base = 0; 
     req.Size = 0x2000;
     req.AccessSpeed = 250;
-    ret = pcmcia_request_window(&link, &req, &link->win);
+    ret = pcmcia_request_window(link, &req, &link->win);
     if (ret)
 	    goto failed;
 
@@ -263,7 +263,7 @@ static int __devinit ibmtr_config(struct pcmcia_device *link)
     req.Base = 0;
     req.Size = sramsize * 1024;
     req.AccessSpeed = 250;
-    ret = pcmcia_request_window(&link, &req, &info->sram_win_handle);
+    ret = pcmcia_request_window(link, &req, &info->sram_win_handle);
     if (ret)
 	    goto failed;
 
diff --git a/drivers/net/pcmcia/pcnet_cs.c b/drivers/net/pcmcia/pcnet_cs.c
index 518b094..d06a0ce 100644
--- a/drivers/net/pcmcia/pcnet_cs.c
+++ b/drivers/net/pcmcia/pcnet_cs.c
@@ -317,7 +317,7 @@ static hw_info_t *get_hwinfo(struct pcmcia_device *link)
     req.Attributes = WIN_DATA_WIDTH_8|WIN_MEMORY_TYPE_AM|WIN_ENABLE;
     req.Base = 0; req.Size = 0;
     req.AccessSpeed = 0;
-    i = pcmcia_request_window(&link, &req, &link->win);
+    i = pcmcia_request_window(link, &req, &link->win);
     if (i != 0)
 	return NULL;
 
@@ -1491,7 +1491,7 @@ static int setup_shmem_window(struct pcmcia_device *link, int start_pg,
     req.Attributes |= WIN_USE_WAIT;
     req.Base = 0; req.Size = window_size;
     req.AccessSpeed = mem_speed;
-    ret = pcmcia_request_window(&link, &req, &link->win);
+    ret = pcmcia_request_window(link, &req, &link->win);
     if (ret)
 	    goto failed;
 
diff --git a/drivers/net/pcmcia/smc91c92_cs.c b/drivers/net/pcmcia/smc91c92_cs.c
index 4ceaa45..c6ca376 100644
--- a/drivers/net/pcmcia/smc91c92_cs.c
+++ b/drivers/net/pcmcia/smc91c92_cs.c
@@ -472,7 +472,7 @@ static int mhz_mfc_config(struct pcmcia_device *link)
     req.Attributes = WIN_DATA_WIDTH_8|WIN_MEMORY_TYPE_AM|WIN_ENABLE;
     req.Base = req.Size = 0;
     req.AccessSpeed = 0;
-    i = pcmcia_request_window(&link, &req, &link->win);
+    i = pcmcia_request_window(link, &req, &link->win);
     if (i != 0)
 	    return -ENODEV;
 
diff --git a/drivers/net/pcmcia/xirc2ps_cs.c b/drivers/net/pcmcia/xirc2ps_cs.c
index 9bc4d60..265852a 100644
--- a/drivers/net/pcmcia/xirc2ps_cs.c
+++ b/drivers/net/pcmcia/xirc2ps_cs.c
@@ -926,7 +926,7 @@ xirc2ps_config(struct pcmcia_device * link)
 	req.Attributes = WIN_DATA_WIDTH_8|WIN_MEMORY_TYPE_AM|WIN_ENABLE;
 	req.Base = req.Size = 0;
 	req.AccessSpeed = 0;
-	if ((err = pcmcia_request_window(&link, &req, &link->win)))
+	if ((err = pcmcia_request_window(link, &req, &link->win)))
 	    goto config_error;
 
 	local->dingo_ccr = ioremap(req.Base,0x1000) + 0x0800;
diff --git a/drivers/net/wireless/airo_cs.c b/drivers/net/wireless/airo_cs.c
index 2aa6978..34d775c 100644
--- a/drivers/net/wireless/airo_cs.c
+++ b/drivers/net/wireless/airo_cs.c
@@ -257,7 +257,7 @@ static int airo_cs_config_check(struct pcmcia_device *p_dev,
 		req->Base = mem->win[0].host_addr;
 		req->Size = mem->win[0].len;
 		req->AccessSpeed = 0;
-		if (pcmcia_request_window(&p_dev, req, &p_dev->win) != 0)
+		if (pcmcia_request_window(p_dev, req, &p_dev->win) != 0)
 			return -ENODEV;
 		map.Page = 0;
 		map.CardOffset = mem->win[0].card_addr;
diff --git a/drivers/net/wireless/b43/pcmcia.c b/drivers/net/wireless/b43/pcmcia.c
index c0a34bb..2588358 100644
--- a/drivers/net/wireless/b43/pcmcia.c
+++ b/drivers/net/wireless/b43/pcmcia.c
@@ -87,7 +87,7 @@ static int __devinit b43_pcmcia_probe(struct pcmcia_device *dev)
 	win.Base = 0;
 	win.Size = SSB_CORE_SIZE;
 	win.AccessSpeed = 250;
-	res = pcmcia_request_window(&dev, &win, &dev->win);
+	res = pcmcia_request_window(dev, &win, &dev->win);
 	if (res != 0)
 		goto err_kfree_ssb;
 
diff --git a/drivers/net/wireless/netwave_cs.c b/drivers/net/wireless/netwave_cs.c
index 4a8c621..bd4eff7 100644
--- a/drivers/net/wireless/netwave_cs.c
+++ b/drivers/net/wireless/netwave_cs.c
@@ -759,7 +759,7 @@ static int netwave_pcmcia_config(struct pcmcia_device *link) {
     req.Attributes = WIN_DATA_WIDTH_8|WIN_MEMORY_TYPE_CM|WIN_ENABLE;
     req.Base = 0; req.Size = 0x8000;
     req.AccessSpeed = mem_speed;
-    ret = pcmcia_request_window(&link, &req, &link->win);
+    ret = pcmcia_request_window(link, &req, &link->win);
     if (ret)
 	    goto failed;
     mem.CardOffset = 0x20000; mem.Page = 0; 
diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
index f719ffc..66e2d10 100644
--- a/drivers/net/wireless/ray_cs.c
+++ b/drivers/net/wireless/ray_cs.c
@@ -438,7 +438,7 @@ static int ray_config(struct pcmcia_device *link)
 	req.Base = 0;
 	req.Size = 0x8000;
 	req.AccessSpeed = ray_mem_speed;
-	ret = pcmcia_request_window(&link, &req, &link->win);
+	ret = pcmcia_request_window(link, &req, &link->win);
 	if (ret)
 		goto failed;
 	mem.CardOffset = 0x0000;
@@ -454,7 +454,7 @@ static int ray_config(struct pcmcia_device *link)
 	req.Base = 0;
 	req.Size = 0x4000;
 	req.AccessSpeed = ray_mem_speed;
-	ret = pcmcia_request_window(&link, &req, &local->rmem_handle);
+	ret = pcmcia_request_window(link, &req, &local->rmem_handle);
 	if (ret)
 		goto failed;
 	mem.CardOffset = 0x8000;
@@ -470,7 +470,7 @@ static int ray_config(struct pcmcia_device *link)
 	req.Base = 0;
 	req.Size = 0x1000;
 	req.AccessSpeed = ray_mem_speed;
-	ret = pcmcia_request_window(&link, &req, &local->amem_handle);
+	ret = pcmcia_request_window(link, &req, &local->amem_handle);
 	if (ret)
 		goto failed;
 	mem.CardOffset = 0x0000;
diff --git a/drivers/net/wireless/wavelan_cs.c b/drivers/net/wireless/wavelan_cs.c
index d4df25d..f8c5166 100644
--- a/drivers/net/wireless/wavelan_cs.c
+++ b/drivers/net/wireless/wavelan_cs.c
@@ -3876,7 +3876,7 @@ wv_pcmcia_config(struct pcmcia_device *	link)
       req.Attributes = WIN_DATA_WIDTH_8|WIN_MEMORY_TYPE_AM|WIN_ENABLE;
       req.Base = req.Size = 0;
       req.AccessSpeed = mem_speed;
-      i = pcmcia_request_window(&link, &req, &link->win);
+      i = pcmcia_request_window(link, &req, &link->win);
       if (i != 0)
 	  break;
 
diff --git a/drivers/pcmcia/pcmcia_resource.c b/drivers/pcmcia/pcmcia_resource.c
index fd20b1a..1f33ed6 100644
--- a/drivers/pcmcia/pcmcia_resource.c
+++ b/drivers/pcmcia/pcmcia_resource.c
@@ -752,9 +752,9 @@ EXPORT_SYMBOL(pcmcia_request_irq);
  * Request_window() establishes a mapping between card memory space
  * and system memory space.
  */
-int pcmcia_request_window(struct pcmcia_device **p_dev, win_req_t *req, window_handle_t *wh)
+int pcmcia_request_window(struct pcmcia_device *p_dev, win_req_t *req, window_handle_t *wh)
 {
-	struct pcmcia_socket *s = (*p_dev)->socket;
+	struct pcmcia_socket *s = p_dev->socket;
 	pccard_mem_map *win;
 	u_long align;
 	int w;
@@ -804,7 +804,7 @@ int pcmcia_request_window(struct pcmcia_device **p_dev, win_req_t *req, window_h
 			return -EINVAL;
 		}
 	}
-	(*p_dev)->_win |= CLIENT_WIN_REQ(w);
+	p_dev->_win |= CLIENT_WIN_REQ(w);
 
 	/* Configure the socket controller */
 	win->map = w+1;
diff --git a/drivers/scsi/pcmcia/nsp_cs.c b/drivers/scsi/pcmcia/nsp_cs.c
index c54108f..9dfd6f5 100644
--- a/drivers/scsi/pcmcia/nsp_cs.c
+++ b/drivers/scsi/pcmcia/nsp_cs.c
@@ -1684,7 +1684,7 @@ static int nsp_cs_config_check(struct pcmcia_device *p_dev,
 			if (cfg_mem->req.Size < 0x1000)
 				cfg_mem->req.Size = 0x1000;
 			cfg_mem->req.AccessSpeed = 0;
-			if (pcmcia_request_window(&p_dev, &cfg_mem->req, &p_dev->win) != 0)
+			if (pcmcia_request_window(p_dev, &cfg_mem->req, &p_dev->win) != 0)
 				goto next_entry;
 			map.Page = 0; map.CardOffset = mem->win[0].card_addr;
 			if (pcmcia_map_mem_page(p_dev, p_dev->win, &map) != 0)
diff --git a/drivers/staging/comedi/drivers/ni_daq_700.c b/drivers/staging/comedi/drivers/ni_daq_700.c
index aeb85b3..7328a84 100644
--- a/drivers/staging/comedi/drivers/ni_daq_700.c
+++ b/drivers/staging/comedi/drivers/ni_daq_700.c
@@ -612,7 +612,7 @@ static int dio700_pcmcia_config_loop(struct pcmcia_device *p_dev,
 		if (req->Size < 0x1000)
 			req->Size = 0x1000;
 		req->AccessSpeed = 0;
-		if (pcmcia_request_window(&p_dev, req, &p_dev->win))
+		if (pcmcia_request_window(p_dev, req, &p_dev->win))
 			return -ENODEV;
 		map.Page = 0;
 		map.CardOffset = mem->win[0].card_addr;
diff --git a/drivers/staging/comedi/drivers/ni_daq_dio24.c b/drivers/staging/comedi/drivers/ni_daq_dio24.c
index 0968a67..5056315 100644
--- a/drivers/staging/comedi/drivers/ni_daq_dio24.c
+++ b/drivers/staging/comedi/drivers/ni_daq_dio24.c
@@ -363,7 +363,7 @@ static int dio24_pcmcia_config_loop(struct pcmcia_device *p_dev,
 		if (req->Size < 0x1000)
 			req->Size = 0x1000;
 		req->AccessSpeed = 0;
-		if (pcmcia_request_window(&p_dev, req, &p_dev->win))
+		if (pcmcia_request_window(p_dev, req, &p_dev->win))
 			return -ENODEV;
 		map.Page = 0;
 		map.CardOffset = mem->win[0].card_addr;
diff --git a/drivers/staging/comedi/drivers/ni_labpc_cs.c b/drivers/staging/comedi/drivers/ni_labpc_cs.c
index b4c7dfa..7fb5058 100644
--- a/drivers/staging/comedi/drivers/ni_labpc_cs.c
+++ b/drivers/staging/comedi/drivers/ni_labpc_cs.c
@@ -342,7 +342,7 @@ static int labpc_pcmcia_config_loop(struct pcmcia_device *p_dev,
 		if (req->Size < 0x1000)
 			req->Size = 0x1000;
 		req->AccessSpeed = 0;
-		if (pcmcia_request_window(&p_dev, req, &p_dev->win))
+		if (pcmcia_request_window(p_dev, req, &p_dev->win))
 			return -ENODEV;
 		map.Page = 0;
 		map.CardOffset = mem->win[0].card_addr;
diff --git a/include/pcmcia/ds.h b/include/pcmcia/ds.h
index cbf5f05..d6c55fd 100644
--- a/include/pcmcia/ds.h
+++ b/include/pcmcia/ds.h
@@ -199,7 +199,7 @@ int pcmcia_request_irq(struct pcmcia_device *p_dev, irq_req_t *req);
 int pcmcia_request_configuration(struct pcmcia_device *p_dev,
 				 config_req_t *req);
 
-int pcmcia_request_window(struct pcmcia_device **p_dev, win_req_t *req,
+int pcmcia_request_window(struct pcmcia_device *p_dev, win_req_t *req,
 			  window_handle_t *wh);
 int pcmcia_release_window(struct pcmcia_device *p_dev, window_handle_t win);
 int pcmcia_map_mem_page(struct pcmcia_device *p_dev, window_handle_t win,
-- 
1.6.0.4

