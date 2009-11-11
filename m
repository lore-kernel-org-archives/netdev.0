From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: [PATCH 06/13] pcmcia: Pass struct pcmcia_device to pcmcia_map_mem_page()
Date: Wed, 11 Nov 2009 21:38:12 +0100
Message-ID: <1257971899-9274-6-git-send-email-linux@dominikbrodowski.net>
References: <20091111203303.GA7939@comet.dominikbrodowski.net>
Cc: Magnus Damm <damm@opensource.se>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, linux-scsi@vger.kernel.org,
	Jiri Kosina <jkosina@suse.cz>,
	Karsten Keil <isdn@linux-pingi.de>,
	Dominik Brodowski <linux@dominikbrodowski.net>
To: <linux-pcmcia@lists.infradead.org>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20091111203303.GA7939@comet.dominikbrodowski.net>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Magnus Damm <damm@opensource.se>

No logic changes, just pass struct pcmcia_device to pcmcia_map_mem_page()

[linux@dominikbrodowski.net: update to 2.6.31]
CC: netdev@vger.kernel.org
CC: linux-wireless@vger.kernel.org
CC: linux-scsi@vger.kernel.org
CC: Jiri Kosina <jkosina@suse.cz>
CC: Karsten Keil <isdn@linux-pingi.de>
Signed-off-by: Magnus Damm <damm@opensource.se>
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
 drivers/pcmcia/pcmcia_resource.c              |    5 ++++-
 drivers/scsi/pcmcia/nsp_cs.c                  |    2 +-
 drivers/staging/comedi/drivers/ni_daq_700.c   |    2 +-
 drivers/staging/comedi/drivers/ni_daq_dio24.c |    2 +-
 drivers/staging/comedi/drivers/ni_labpc_cs.c  |    2 +-
 include/pcmcia/ds.h                           |    3 ++-
 19 files changed, 29 insertions(+), 25 deletions(-)

diff --git a/drivers/char/pcmcia/ipwireless/main.c b/drivers/char/pcmcia/ipwireless/main.c
index 91ca23d..10af1c0 100644
--- a/drivers/char/pcmcia/ipwireless/main.c
+++ b/drivers/char/pcmcia/ipwireless/main.c
@@ -125,7 +125,7 @@ static int ipwireless_probe(struct pcmcia_device *p_dev,
 	memreq_common_memory.CardOffset = cfg->mem.win[0].card_addr;
 	memreq_common_memory.Page = 0;
 
-	ret = pcmcia_map_mem_page(ipw->handle_common_memory,
+	ret = pcmcia_map_mem_page(p_dev, ipw->handle_common_memory,
 				&memreq_common_memory);
 
 	if (ret != 0)
@@ -154,7 +154,7 @@ static int ipwireless_probe(struct pcmcia_device *p_dev,
 	memreq_attr_memory.CardOffset = 0;
 	memreq_attr_memory.Page = 0;
 
-	ret = pcmcia_map_mem_page(ipw->handle_attr_memory,
+	ret = pcmcia_map_mem_page(p_dev, ipw->handle_attr_memory,
 				&memreq_attr_memory);
 
 	if (ret != 0)
diff --git a/drivers/isdn/hisax/sedlbauer_cs.c b/drivers/isdn/hisax/sedlbauer_cs.c
index 33d7530..598e17a 100644
--- a/drivers/isdn/hisax/sedlbauer_cs.c
+++ b/drivers/isdn/hisax/sedlbauer_cs.c
@@ -276,7 +276,7 @@ static int sedlbauer_config_check(struct pcmcia_device *p_dev,
 			return -ENODEV;
 		map.Page = 0;
 		map.CardOffset = mem->win[0].card_addr;
-		if (pcmcia_map_mem_page(p_dev->win, &map) != 0)
+		if (pcmcia_map_mem_page(p_dev, p_dev->win, &map) != 0)
 			return -ENODEV;
 	}
 	return 0;
diff --git a/drivers/mtd/maps/pcmciamtd.c b/drivers/mtd/maps/pcmciamtd.c
index 16d9985..80b9005 100644
--- a/drivers/mtd/maps/pcmciamtd.c
+++ b/drivers/mtd/maps/pcmciamtd.c
@@ -118,7 +118,7 @@ static caddr_t remap_window(struct map_info *map, unsigned long to)
 		DEBUG(2, "Remapping window from 0x%8.8x to 0x%8.8x",
 		      dev->offset, mrq.CardOffset);
 		mrq.Page = 0;
-		ret = pcmcia_map_mem_page(win, &mrq);
+		ret = pcmcia_map_mem_page(dev->p_dev, win, &mrq);
 		if (ret != 0)
 			return NULL;
 		dev->offset = mrq.CardOffset;
diff --git a/drivers/net/pcmcia/fmvj18x_cs.c b/drivers/net/pcmcia/fmvj18x_cs.c
index 61726c8..6b9c79e 100644
--- a/drivers/net/pcmcia/fmvj18x_cs.c
+++ b/drivers/net/pcmcia/fmvj18x_cs.c
@@ -574,7 +574,7 @@ static int fmvj18x_get_hwinfo(struct pcmcia_device *link, u_char *node_id)
     base = ioremap(req.Base, req.Size);
     mem.Page = 0;
     mem.CardOffset = 0;
-    pcmcia_map_mem_page(link->win, &mem);
+    pcmcia_map_mem_page(link, link->win, &mem);
 
     /*
      *  MBH10304 CISTPL_FUNCE_LAN_NODE_ID format
@@ -630,7 +630,7 @@ static int fmvj18x_setup_mfc(struct pcmcia_device *link)
 
     mem.Page = 0;
     mem.CardOffset = 0;
-    i = pcmcia_map_mem_page(link->win, &mem);
+    i = pcmcia_map_mem_page(link, link->win, &mem);
     if (i != 0) {
 	iounmap(lp->base);
 	lp->base = NULL;
diff --git a/drivers/net/pcmcia/ibmtr_cs.c b/drivers/net/pcmcia/ibmtr_cs.c
index 7a985ca..6fc89eb 100644
--- a/drivers/net/pcmcia/ibmtr_cs.c
+++ b/drivers/net/pcmcia/ibmtr_cs.c
@@ -252,7 +252,7 @@ static int __devinit ibmtr_config(struct pcmcia_device *link)
 
     mem.CardOffset = mmiobase;
     mem.Page = 0;
-    ret = pcmcia_map_mem_page(link->win, &mem);
+    ret = pcmcia_map_mem_page(link, link->win, &mem);
     if (ret)
 	    goto failed;
     ti->mmio = ioremap(req.Base, req.Size);
@@ -269,7 +269,7 @@ static int __devinit ibmtr_config(struct pcmcia_device *link)
 
     mem.CardOffset = srambase;
     mem.Page = 0;
-    ret = pcmcia_map_mem_page(info->sram_win_handle, &mem);
+    ret = pcmcia_map_mem_page(link, info->sram_win_handle, &mem);
     if (ret)
 	    goto failed;
 
diff --git a/drivers/net/pcmcia/pcnet_cs.c b/drivers/net/pcmcia/pcnet_cs.c
index 4156a6c..75e6894 100644
--- a/drivers/net/pcmcia/pcnet_cs.c
+++ b/drivers/net/pcmcia/pcnet_cs.c
@@ -325,7 +325,7 @@ static hw_info_t *get_hwinfo(struct pcmcia_device *link)
     mem.Page = 0;
     for (i = 0; i < NR_INFO; i++) {
 	mem.CardOffset = hw_info[i].offset & ~(req.Size-1);
-	pcmcia_map_mem_page(link->win, &mem);
+	pcmcia_map_mem_page(link, link->win, &mem);
 	base = &virt[hw_info[i].offset & (req.Size-1)];
 	if ((readb(base+0) == hw_info[i].a0) &&
 	    (readb(base+2) == hw_info[i].a1) &&
@@ -1499,7 +1499,7 @@ static int setup_shmem_window(struct pcmcia_device *link, int start_pg,
     offset = mem.CardOffset % window_size;
     mem.CardOffset -= offset;
     mem.Page = 0;
-    ret = pcmcia_map_mem_page(link->win, &mem);
+    ret = pcmcia_map_mem_page(link, link->win, &mem);
     if (ret)
 	    goto failed;
 
diff --git a/drivers/net/pcmcia/smc91c92_cs.c b/drivers/net/pcmcia/smc91c92_cs.c
index 580ec44..4ceaa45 100644
--- a/drivers/net/pcmcia/smc91c92_cs.c
+++ b/drivers/net/pcmcia/smc91c92_cs.c
@@ -480,7 +480,7 @@ static int mhz_mfc_config(struct pcmcia_device *link)
     mem.CardOffset = mem.Page = 0;
     if (smc->manfid == MANFID_MOTOROLA)
 	mem.CardOffset = link->conf.ConfigBase;
-    i = pcmcia_map_mem_page(link->win, &mem);
+    i = pcmcia_map_mem_page(link, link->win, &mem);
 
     if ((i == 0)
 	&& (smc->manfid == MANFID_MEGAHERTZ)
diff --git a/drivers/net/pcmcia/xirc2ps_cs.c b/drivers/net/pcmcia/xirc2ps_cs.c
index fbf9265..9bc4d60 100644
--- a/drivers/net/pcmcia/xirc2ps_cs.c
+++ b/drivers/net/pcmcia/xirc2ps_cs.c
@@ -932,7 +932,7 @@ xirc2ps_config(struct pcmcia_device * link)
 	local->dingo_ccr = ioremap(req.Base,0x1000) + 0x0800;
 	mem.CardOffset = 0x0;
 	mem.Page = 0;
-	if ((err = pcmcia_map_mem_page(link->win, &mem)))
+	if ((err = pcmcia_map_mem_page(link, link->win, &mem)))
 	    goto config_error;
 
 	/* Setup the CCRs; there are no infos in the CIS about the Ethernet
diff --git a/drivers/net/wireless/airo_cs.c b/drivers/net/wireless/airo_cs.c
index a1b84fc..2aa6978 100644
--- a/drivers/net/wireless/airo_cs.c
+++ b/drivers/net/wireless/airo_cs.c
@@ -261,7 +261,7 @@ static int airo_cs_config_check(struct pcmcia_device *p_dev,
 			return -ENODEV;
 		map.Page = 0;
 		map.CardOffset = mem->win[0].card_addr;
-		if (pcmcia_map_mem_page(p_dev->win, &map) != 0)
+		if (pcmcia_map_mem_page(p_dev, p_dev->win, &map) != 0)
 			return -ENODEV;
 	}
 	/* If we got this far, we're cool! */
diff --git a/drivers/net/wireless/b43/pcmcia.c b/drivers/net/wireless/b43/pcmcia.c
index cd14b7e..c0a34bb 100644
--- a/drivers/net/wireless/b43/pcmcia.c
+++ b/drivers/net/wireless/b43/pcmcia.c
@@ -93,7 +93,7 @@ static int __devinit b43_pcmcia_probe(struct pcmcia_device *dev)
 
 	mem.CardOffset = 0;
 	mem.Page = 0;
-	res = pcmcia_map_mem_page(dev->win, &mem);
+	res = pcmcia_map_mem_page(dev, dev->win, &mem);
 	if (res != 0)
 		goto err_disable;
 
diff --git a/drivers/net/wireless/netwave_cs.c b/drivers/net/wireless/netwave_cs.c
index cbd85de..4a8c621 100644
--- a/drivers/net/wireless/netwave_cs.c
+++ b/drivers/net/wireless/netwave_cs.c
@@ -763,7 +763,7 @@ static int netwave_pcmcia_config(struct pcmcia_device *link) {
     if (ret)
 	    goto failed;
     mem.CardOffset = 0x20000; mem.Page = 0; 
-    ret = pcmcia_map_mem_page(link->win, &mem);
+    ret = pcmcia_map_mem_page(link, link->win, &mem);
     if (ret)
 	    goto failed;
 
diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
index ed32875..f719ffc 100644
--- a/drivers/net/wireless/ray_cs.c
+++ b/drivers/net/wireless/ray_cs.c
@@ -443,7 +443,7 @@ static int ray_config(struct pcmcia_device *link)
 		goto failed;
 	mem.CardOffset = 0x0000;
 	mem.Page = 0;
-	ret = pcmcia_map_mem_page(link->win, &mem);
+	ret = pcmcia_map_mem_page(link, link->win, &mem);
 	if (ret)
 		goto failed;
 	local->sram = ioremap(req.Base, req.Size);
@@ -459,7 +459,7 @@ static int ray_config(struct pcmcia_device *link)
 		goto failed;
 	mem.CardOffset = 0x8000;
 	mem.Page = 0;
-	ret = pcmcia_map_mem_page(local->rmem_handle, &mem);
+	ret = pcmcia_map_mem_page(link, local->rmem_handle, &mem);
 	if (ret)
 		goto failed;
 	local->rmem = ioremap(req.Base, req.Size);
@@ -475,7 +475,7 @@ static int ray_config(struct pcmcia_device *link)
 		goto failed;
 	mem.CardOffset = 0x0000;
 	mem.Page = 0;
-	ret = pcmcia_map_mem_page(local->amem_handle, &mem);
+	ret = pcmcia_map_mem_page(link, local->amem_handle, &mem);
 	if (ret)
 		goto failed;
 	local->amem = ioremap(req.Base, req.Size);
diff --git a/drivers/net/wireless/wavelan_cs.c b/drivers/net/wireless/wavelan_cs.c
index 2fad4ac..d4df25d 100644
--- a/drivers/net/wireless/wavelan_cs.c
+++ b/drivers/net/wireless/wavelan_cs.c
@@ -3885,7 +3885,7 @@ wv_pcmcia_config(struct pcmcia_device *	link)
       dev->mem_end = dev->mem_start + req.Size;
 
       mem.CardOffset = 0; mem.Page = 0;
-      i = pcmcia_map_mem_page(link->win, &mem);
+      i = pcmcia_map_mem_page(link, link->win, &mem);
       if (i != 0)
 	  break;
 
diff --git a/drivers/pcmcia/pcmcia_resource.c b/drivers/pcmcia/pcmcia_resource.c
index 820a6e5..b60952a 100644
--- a/drivers/pcmcia/pcmcia_resource.c
+++ b/drivers/pcmcia/pcmcia_resource.c
@@ -234,9 +234,12 @@ int pcmcia_get_mem_page(window_handle_t win, memreq_t *req)
 EXPORT_SYMBOL(pcmcia_get_mem_page);
 
 
-int pcmcia_map_mem_page(window_handle_t win, memreq_t *req)
+int pcmcia_map_mem_page(struct pcmcia_device *p_dev, window_handle_t wh,
+			memreq_t *req)
 {
 	struct pcmcia_socket *s;
+	window_handle_t win = wh;
+
 	if ((win == NULL) || (win->magic != WINDOW_MAGIC))
 		return -EINVAL;
 	s = win->sock;
diff --git a/drivers/scsi/pcmcia/nsp_cs.c b/drivers/scsi/pcmcia/nsp_cs.c
index e32c344..c54108f 100644
--- a/drivers/scsi/pcmcia/nsp_cs.c
+++ b/drivers/scsi/pcmcia/nsp_cs.c
@@ -1687,7 +1687,7 @@ static int nsp_cs_config_check(struct pcmcia_device *p_dev,
 			if (pcmcia_request_window(&p_dev, &cfg_mem->req, &p_dev->win) != 0)
 				goto next_entry;
 			map.Page = 0; map.CardOffset = mem->win[0].card_addr;
-			if (pcmcia_map_mem_page(p_dev->win, &map) != 0)
+			if (pcmcia_map_mem_page(p_dev, p_dev->win, &map) != 0)
 				goto next_entry;
 
 			cfg_mem->data->MmioAddress = (unsigned long) ioremap_nocache(cfg_mem->req.Base, cfg_mem->req.Size);
diff --git a/drivers/staging/comedi/drivers/ni_daq_700.c b/drivers/staging/comedi/drivers/ni_daq_700.c
index e06d5b2..aeb85b3 100644
--- a/drivers/staging/comedi/drivers/ni_daq_700.c
+++ b/drivers/staging/comedi/drivers/ni_daq_700.c
@@ -616,7 +616,7 @@ static int dio700_pcmcia_config_loop(struct pcmcia_device *p_dev,
 			return -ENODEV;
 		map.Page = 0;
 		map.CardOffset = mem->win[0].card_addr;
-		if (pcmcia_map_mem_page(p_dev->win, &map))
+		if (pcmcia_map_mem_page(p_dev, p_dev->win, &map))
 			return -ENODEV;
 	}
 	/* If we got this far, we're cool! */
diff --git a/drivers/staging/comedi/drivers/ni_daq_dio24.c b/drivers/staging/comedi/drivers/ni_daq_dio24.c
index 9257a42..0968a67 100644
--- a/drivers/staging/comedi/drivers/ni_daq_dio24.c
+++ b/drivers/staging/comedi/drivers/ni_daq_dio24.c
@@ -367,7 +367,7 @@ static int dio24_pcmcia_config_loop(struct pcmcia_device *p_dev,
 			return -ENODEV;
 		map.Page = 0;
 		map.CardOffset = mem->win[0].card_addr;
-		if (pcmcia_map_mem_page(p_dev->win, &map))
+		if (pcmcia_map_mem_page(p_dev, p_dev->win, &map))
 			return -ENODEV;
 	}
 	/* If we got this far, we're cool! */
diff --git a/drivers/staging/comedi/drivers/ni_labpc_cs.c b/drivers/staging/comedi/drivers/ni_labpc_cs.c
index 28ff4a6..b4c7dfa 100644
--- a/drivers/staging/comedi/drivers/ni_labpc_cs.c
+++ b/drivers/staging/comedi/drivers/ni_labpc_cs.c
@@ -346,7 +346,7 @@ static int labpc_pcmcia_config_loop(struct pcmcia_device *p_dev,
 			return -ENODEV;
 		map.Page = 0;
 		map.CardOffset = mem->win[0].card_addr;
-		if (pcmcia_map_mem_page(p_dev->win, &map))
+		if (pcmcia_map_mem_page(p_dev, p_dev->win, &map))
 			return -ENODEV;
 	}
 	/* If we got this far, we're cool! */
diff --git a/include/pcmcia/ds.h b/include/pcmcia/ds.h
index 40b098d..f240bfa 100644
--- a/include/pcmcia/ds.h
+++ b/include/pcmcia/ds.h
@@ -204,7 +204,8 @@ int pcmcia_request_window(struct pcmcia_device **p_dev, win_req_t *req,
 int pcmcia_release_window(struct pcmcia_device *p_dev, window_handle_t win);
 
 int pcmcia_get_mem_page(window_handle_t win, memreq_t *req);
-int pcmcia_map_mem_page(window_handle_t win, memreq_t *req);
+int pcmcia_map_mem_page(struct pcmcia_device *p_dev, window_handle_t win,
+			memreq_t *req);
 
 int pcmcia_modify_configuration(struct pcmcia_device *p_dev, modconf_t *mod);
 void pcmcia_disable_device(struct pcmcia_device *p_dev);
-- 
1.6.0.4

