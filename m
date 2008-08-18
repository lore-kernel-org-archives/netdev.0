From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: [PATCH 21/39] pcmcia: deprecate CS_SUCCESS
Date: Mon, 18 Aug 2008 20:53:12 +0200
Message-ID: <1219085610-12289-21-git-send-email-linux@dominikbrodowski.net>
References: <20080818185025.GA11647@comet.dominikbrodowski.net>
Cc: Dominik Brodowski <linux@dominikbrodowski.net>,
	netdev@vger.kernel.org
To: <linux-pcmcia@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isilmar.linta.de ([213.133.102.198]:35947 "EHLO linta.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1760837AbYHRSyN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Aug 2008 14:54:13 -0400
In-Reply-To: <20080818185025.GA11647@comet.dominikbrodowski.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of using own error or success codes, the PCMCIA code should rely on
the generic return values. Therefore, replace all occurrences of CS_SUCCESS
with 0.

CC: netdev@vger.kernel.org
Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
---
 drivers/bluetooth/bluecard_cs.c         |    8 ++--
 drivers/bluetooth/bt3c_cs.c             |    4 +-
 drivers/bluetooth/btuart_cs.c           |    4 +-
 drivers/bluetooth/dtl1_cs.c             |    4 +-
 drivers/char/pcmcia/cm4040_cs.c         |    3 +-
 drivers/char/pcmcia/ipwireless/main.c   |   36 ++++++++--------
 drivers/isdn/hardware/avm/avm_cs.c      |    4 +-
 drivers/isdn/hisax/avma1_cs.c           |    4 +-
 drivers/isdn/hisax/elsa_cs.c            |    6 +-
 drivers/isdn/hisax/teles_cs.c           |    6 +-
 drivers/mtd/maps/pcmciamtd.c            |   14 +++---
 drivers/net/pcmcia/3c574_cs.c           |    6 +-
 drivers/net/pcmcia/3c589_cs.c           |    6 +-
 drivers/net/pcmcia/axnet_cs.c           |    4 +-
 drivers/net/pcmcia/com20020_cs.c        |    8 ++--
 drivers/net/pcmcia/fmvj18x_cs.c         |   18 ++++----
 drivers/net/pcmcia/ibmtr_cs.c           |    2 +-
 drivers/net/pcmcia/pcnet_cs.c           |    6 +-
 drivers/net/pcmcia/smc91c92_cs.c        |   36 ++++++++--------
 drivers/net/wireless/b43/pcmcia.c       |   14 +++---
 drivers/net/wireless/hostap/hostap_cs.c |   22 +++++-----
 drivers/net/wireless/netwave_cs.c       |    4 +-
 drivers/net/wireless/ray_cs.c           |    4 +-
 drivers/net/wireless/wavelan_cs.c       |   16 ++++----
 drivers/net/wireless/wl3501_cs.c        |    4 +-
 drivers/pcmcia/cardbus.c                |    2 +-
 drivers/pcmcia/cistpl.c                 |   70 +++++++++++++++---------------
 drivers/pcmcia/cs.c                     |   14 +++---
 drivers/pcmcia/ds.c                     |    2 +-
 drivers/pcmcia/ds_internal.h            |    2 +-
 drivers/pcmcia/pcmcia_ioctl.c           |   14 +++---
 drivers/pcmcia/pcmcia_resource.c        |   26 ++++++------
 drivers/pcmcia/rsrc_nonstatic.c         |    4 +-
 drivers/serial/serial_cs.c              |   16 ++++----
 drivers/ssb/pcmcia.c                    |   20 ++++----
 35 files changed, 206 insertions(+), 207 deletions(-)

diff --git a/drivers/bluetooth/bluecard_cs.c b/drivers/bluetooth/bluecard_cs.c
index bcf5792..e6ee21d 100644
--- a/drivers/bluetooth/bluecard_cs.c
+++ b/drivers/bluetooth/bluecard_cs.c
@@ -901,23 +901,23 @@ static int bluecard_config(struct pcmcia_device *link)
 	for (n = 0; n < 0x400; n += 0x40) {
 		link->io.BasePort1 = n ^ 0x300;
 		i = pcmcia_request_io(link, &link->io);
-		if (i == CS_SUCCESS)
+		if (i == 0)
 			break;
 	}
 
-	if (i != CS_SUCCESS) {
+	if (i != 0) {
 		cs_error(link, RequestIO, i);
 		goto failed;
 	}
 
 	i = pcmcia_request_irq(link, &link->irq);
-	if (i != CS_SUCCESS) {
+	if (i != 0) {
 		cs_error(link, RequestIRQ, i);
 		link->irq.AssignedIRQ = 0;
 	}
 
 	i = pcmcia_request_configuration(link, &link->conf);
-	if (i != CS_SUCCESS) {
+	if (i != 0) {
 		cs_error(link, RequestConfiguration, i);
 		goto failed;
 	}
diff --git a/drivers/bluetooth/bt3c_cs.c b/drivers/bluetooth/bt3c_cs.c
index 1aeab04..df7b8fe 100644
--- a/drivers/bluetooth/bt3c_cs.c
+++ b/drivers/bluetooth/bt3c_cs.c
@@ -741,13 +741,13 @@ static int bt3c_config(struct pcmcia_device *link)
 
 found_port:
 	i = pcmcia_request_irq(link, &link->irq);
-	if (i != CS_SUCCESS) {
+	if (i != 0) {
 		cs_error(link, RequestIRQ, i);
 		link->irq.AssignedIRQ = 0;
 	}
 
 	i = pcmcia_request_configuration(link, &link->conf);
-	if (i != CS_SUCCESS) {
+	if (i != 0) {
 		cs_error(link, RequestConfiguration, i);
 		goto failed;
 	}
diff --git a/drivers/bluetooth/btuart_cs.c b/drivers/bluetooth/btuart_cs.c
index 19d9391..41ccbfd 100644
--- a/drivers/bluetooth/btuart_cs.c
+++ b/drivers/bluetooth/btuart_cs.c
@@ -670,13 +670,13 @@ static int btuart_config(struct pcmcia_device *link)
 
 found_port:
 	i = pcmcia_request_irq(link, &link->irq);
-	if (i != CS_SUCCESS) {
+	if (i != 0) {
 		cs_error(link, RequestIRQ, i);
 		link->irq.AssignedIRQ = 0;
 	}
 
 	i = pcmcia_request_configuration(link, &link->conf);
-	if (i != CS_SUCCESS) {
+	if (i != 0) {
 		cs_error(link, RequestConfiguration, i);
 		goto failed;
 	}
diff --git a/drivers/bluetooth/dtl1_cs.c b/drivers/bluetooth/dtl1_cs.c
index ec12560..e6e6b03 100644
--- a/drivers/bluetooth/dtl1_cs.c
+++ b/drivers/bluetooth/dtl1_cs.c
@@ -617,13 +617,13 @@ static int dtl1_config(struct pcmcia_device *link)
 		goto failed;
 
 	i = pcmcia_request_irq(link, &link->irq);
-	if (i != CS_SUCCESS) {
+	if (i != 0) {
 		cs_error(link, RequestIRQ, i);
 		link->irq.AssignedIRQ = 0;
 	}
 
 	i = pcmcia_request_configuration(link, &link->conf);
-	if (i != CS_SUCCESS) {
+	if (i != 0) {
 		cs_error(link, RequestConfiguration, i);
 		goto failed;
 	}
diff --git a/drivers/char/pcmcia/cm4040_cs.c b/drivers/char/pcmcia/cm4040_cs.c
index e047bac..72b7feb 100644
--- a/drivers/char/pcmcia/cm4040_cs.c
+++ b/drivers/char/pcmcia/cm4040_cs.c
@@ -567,8 +567,7 @@ static int reader_config(struct pcmcia_device *link, int devno)
 
 	link->conf.IntType = 00000002;
 
-	if ((fail_rc = pcmcia_request_configuration(link,&link->conf))
-								!=CS_SUCCESS) {
+	if ((fail_rc = pcmcia_request_configuration(link,&link->conf)) != 0) {
 		dev_printk(KERN_INFO, &handle_to_dev(link),
 			   "pcmcia_request_configuration failed 0x%x\n",
 			   fail_rc);
diff --git a/drivers/char/pcmcia/ipwireless/main.c b/drivers/char/pcmcia/ipwireless/main.c
index 1f520e5..24ffe03 100644
--- a/drivers/char/pcmcia/ipwireless/main.c
+++ b/drivers/char/pcmcia/ipwireless/main.c
@@ -67,7 +67,7 @@ static void signalled_reboot_work(struct work_struct *work_reboot)
 	struct pcmcia_device *link = ipw->link;
 	int ret = pccard_reset_card(link->socket);
 
-	if (ret != CS_SUCCESS)
+	if (ret != 0)
 		cs_error(link, ResetCard, ret);
 }
 
@@ -104,7 +104,7 @@ static int config_ipwireless(struct ipw_dev *ipw)
 	while (ret == 0) {
 		ret = pcmcia_get_tuple_data(link, &tuple);
 
-		if (ret != CS_SUCCESS) {
+		if (ret != 0) {
 			cs_error(link, GetTupleData, ret);
 			goto exit0;
 		}
@@ -115,21 +115,21 @@ static int config_ipwireless(struct ipw_dev *ipw)
 
 	ret = pcmcia_get_first_tuple(link, &tuple);
 
-	if (ret != CS_SUCCESS) {
+	if (ret != 0) {
 		cs_error(link, GetFirstTuple, ret);
 		goto exit0;
 	}
 
 	ret = pcmcia_get_tuple_data(link, &tuple);
 
-	if (ret != CS_SUCCESS) {
+	if (ret != 0) {
 		cs_error(link, GetTupleData, ret);
 		goto exit0;
 	}
 
 	ret = pcmcia_parse_tuple(link, &tuple, &parse);
 
-	if (ret != CS_SUCCESS) {
+	if (ret != 0) {
 		cs_error(link, ParseTuple, ret);
 		goto exit0;
 	}
@@ -151,21 +151,21 @@ static int config_ipwireless(struct ipw_dev *ipw)
 
 	ret = pcmcia_get_first_tuple(link, &tuple);
 
-	if (ret != CS_SUCCESS) {
+	if (ret != 0) {
 		cs_error(link, GetFirstTuple, ret);
 		goto exit0;
 	}
 
 	ret = pcmcia_get_tuple_data(link, &tuple);
 
-	if (ret != CS_SUCCESS) {
+	if (ret != 0) {
 		cs_error(link, GetTupleData, ret);
 		goto exit0;
 	}
 
 	ret = pcmcia_parse_tuple(link, &tuple, &parse);
 
-	if (ret != CS_SUCCESS) {
+	if (ret != 0) {
 		cs_error(link, GetTupleData, ret);
 		goto exit0;
 	}
@@ -180,7 +180,7 @@ static int config_ipwireless(struct ipw_dev *ipw)
 
 	ret = pcmcia_request_io(link, &link->io);
 
-	if (ret != CS_SUCCESS) {
+	if (ret != 0) {
 		cs_error(link, RequestIO, ret);
 		goto exit0;
 	}
@@ -194,21 +194,21 @@ static int config_ipwireless(struct ipw_dev *ipw)
 
 	ret = pcmcia_get_first_tuple(link, &tuple);
 
-	if (ret != CS_SUCCESS) {
+	if (ret != 0) {
 		cs_error(link, GetFirstTuple, ret);
 		goto exit1;
 	}
 
 	ret = pcmcia_get_tuple_data(link, &tuple);
 
-	if (ret != CS_SUCCESS) {
+	if (ret != 0) {
 		cs_error(link, GetTupleData, ret);
 		goto exit1;
 	}
 
 	ret = pcmcia_parse_tuple(link, &tuple, &parse);
 
-	if (ret != CS_SUCCESS) {
+	if (ret != 0) {
 		cs_error(link, ParseTuple, ret);
 		goto exit1;
 	}
@@ -226,7 +226,7 @@ static int config_ipwireless(struct ipw_dev *ipw)
 		ret = pcmcia_request_window(&link, &ipw->request_common_memory,
 				&ipw->handle_common_memory);
 
-		if (ret != CS_SUCCESS) {
+		if (ret != 0) {
 			cs_error(link, RequestWindow, ret);
 			goto exit1;
 		}
@@ -238,7 +238,7 @@ static int config_ipwireless(struct ipw_dev *ipw)
 		ret = pcmcia_map_mem_page(ipw->handle_common_memory,
 				&memreq_common_memory);
 
-		if (ret != CS_SUCCESS) {
+		if (ret != 0) {
 			cs_error(link, MapMemPage, ret);
 			goto exit1;
 		}
@@ -260,7 +260,7 @@ static int config_ipwireless(struct ipw_dev *ipw)
 		ret = pcmcia_request_window(&link, &ipw->request_attr_memory,
 				&ipw->handle_attr_memory);
 
-		if (ret != CS_SUCCESS) {
+		if (ret != 0) {
 			cs_error(link, RequestWindow, ret);
 			goto exit2;
 		}
@@ -271,7 +271,7 @@ static int config_ipwireless(struct ipw_dev *ipw)
 		ret = pcmcia_map_mem_page(ipw->handle_attr_memory,
 				&memreq_attr_memory);
 
-		if (ret != CS_SUCCESS) {
+		if (ret != 0) {
 			cs_error(link, MapMemPage, ret);
 			goto exit2;
 		}
@@ -291,7 +291,7 @@ static int config_ipwireless(struct ipw_dev *ipw)
 
 	ret = pcmcia_request_irq(link, &link->irq);
 
-	if (ret != CS_SUCCESS) {
+	if (ret != 0) {
 		cs_error(link, RequestIRQ, ret);
 		goto exit3;
 	}
@@ -331,7 +331,7 @@ static int config_ipwireless(struct ipw_dev *ipw)
 	 */
 	ret = pcmcia_request_configuration(link, &link->conf);
 
-	if (ret != CS_SUCCESS) {
+	if (ret != 0) {
 		cs_error(link, RequestConfiguration, ret);
 		goto exit4;
 	}
diff --git a/drivers/isdn/hardware/avm/avm_cs.c b/drivers/isdn/hardware/avm/avm_cs.c
index 3880465..c725655 100644
--- a/drivers/isdn/hardware/avm/avm_cs.c
+++ b/drivers/isdn/hardware/avm/avm_cs.c
@@ -197,7 +197,7 @@ static int avmcs_config(struct pcmcia_device *link)
 	 * allocate an interrupt line
 	 */
 	i = pcmcia_request_irq(link, &link->irq);
-	if (i != CS_SUCCESS) {
+	if (i != 0) {
 	    cs_error(link, RequestIRQ, i);
 	    /* undo */
 	    pcmcia_disable_device(link);
@@ -208,7 +208,7 @@ static int avmcs_config(struct pcmcia_device *link)
          * configure the PCMCIA socket
 	  */
 	i = pcmcia_request_configuration(link, &link->conf);
-	if (i != CS_SUCCESS) {
+	if (i != 0) {
 	    cs_error(link, RequestConfiguration, i);
 	    pcmcia_disable_device(link);
 	    break;
diff --git a/drivers/isdn/hisax/avma1_cs.c b/drivers/isdn/hisax/avma1_cs.c
index 8fd3ca0..23560c8 100644
--- a/drivers/isdn/hisax/avma1_cs.c
+++ b/drivers/isdn/hisax/avma1_cs.c
@@ -217,7 +217,7 @@ static int avma1cs_config(struct pcmcia_device *link)
 	 * allocate an interrupt line
 	 */
 	i = pcmcia_request_irq(link, &link->irq);
-	if (i != CS_SUCCESS) {
+	if (i != 0) {
 	    cs_error(link, RequestIRQ, i);
 	    /* undo */
 	    pcmcia_disable_device(link);
@@ -228,7 +228,7 @@ static int avma1cs_config(struct pcmcia_device *link)
 	 * configure the PCMCIA socket
 	 */
 	i = pcmcia_request_configuration(link, &link->conf);
-	if (i != CS_SUCCESS) {
+	if (i != 0) {
 	    cs_error(link, RequestConfiguration, i);
 	    pcmcia_disable_device(link);
 	    break;
diff --git a/drivers/isdn/hisax/elsa_cs.c b/drivers/isdn/hisax/elsa_cs.c
index 90e8e02..8198e1d 100644
--- a/drivers/isdn/hisax/elsa_cs.c
+++ b/drivers/isdn/hisax/elsa_cs.c
@@ -238,20 +238,20 @@ static int elsa_cs_config(struct pcmcia_device *link)
     dev = link->priv;
 
     i = pcmcia_loop_config(link, elsa_cs_configcheck, NULL);
-    if (i != CS_SUCCESS) {
+    if (i != 0) {
 	last_fn = RequestIO;
 	goto cs_failed;
     }
 
     i = pcmcia_request_irq(link, &link->irq);
-    if (i != CS_SUCCESS) {
+    if (i != 0) {
         link->irq.AssignedIRQ = 0;
 	last_fn = RequestIRQ;
         goto cs_failed;
     }
 
     i = pcmcia_request_configuration(link, &link->conf);
-    if (i != CS_SUCCESS) {
+    if (i != 0) {
       last_fn = RequestConfiguration;
       goto cs_failed;
     }
diff --git a/drivers/isdn/hisax/teles_cs.c b/drivers/isdn/hisax/teles_cs.c
index 85c7344..bafd18f 100644
--- a/drivers/isdn/hisax/teles_cs.c
+++ b/drivers/isdn/hisax/teles_cs.c
@@ -228,20 +228,20 @@ static int teles_cs_config(struct pcmcia_device *link)
     dev = link->priv;
 
     i = pcmcia_loop_config(link, teles_cs_configcheck, NULL);
-    if (i != CS_SUCCESS) {
+    if (i != 0) {
 	last_fn = RequestIO;
 	goto cs_failed;
     }
 
     i = pcmcia_request_irq(link, &link->irq);
-    if (i != CS_SUCCESS) {
+    if (i != 0) {
         link->irq.AssignedIRQ = 0;
 	last_fn = RequestIRQ;
         goto cs_failed;
     }
 
     i = pcmcia_request_configuration(link, &link->conf);
-    if (i != CS_SUCCESS) {
+    if (i != 0) {
       last_fn = RequestConfiguration;
       goto cs_failed;
     }
diff --git a/drivers/mtd/maps/pcmciamtd.c b/drivers/mtd/maps/pcmciamtd.c
index 8861ca4..b102f24 100644
--- a/drivers/mtd/maps/pcmciamtd.c
+++ b/drivers/mtd/maps/pcmciamtd.c
@@ -118,7 +118,7 @@ static caddr_t remap_window(struct map_info *map, unsigned long to)
 		DEBUG(2, "Remapping window from 0x%8.8x to 0x%8.8x",
 		      dev->offset, mrq.CardOffset);
 		mrq.Page = 0;
-		if( (ret = pcmcia_map_mem_page(win, &mrq)) != CS_SUCCESS) {
+		if( (ret = pcmcia_map_mem_page(win, &mrq)) != 0) {
 			cs_error(dev->p_dev, MapMemPage, ret);
 			return NULL;
 		}
@@ -326,7 +326,7 @@ static void pcmciamtd_set_vpp(struct map_info *map, int on)
 
 	DEBUG(2, "dev = %p on = %d vpp = %d\n", dev, on, dev->vpp);
 	ret = pcmcia_modify_configuration(link, &mod);
-	if(ret != CS_SUCCESS) {
+	if(ret != 0) {
 		cs_error(link, ModifyConfiguration, ret);
 	}
 }
@@ -368,14 +368,14 @@ static void card_settings(struct pcmciamtd_dev *dev, struct pcmcia_device *link,
 	tuple.DesiredTuple = RETURN_FIRST_TUPLE;
 
 	rc = pcmcia_get_first_tuple(link, &tuple);
-	while(rc == CS_SUCCESS) {
+	while(rc == 0) {
 		rc = pcmcia_get_tuple_data(link, &tuple);
-		if(rc != CS_SUCCESS) {
+		if(rc != 0) {
 			cs_error(link, GetTupleData, rc);
 			break;
 		}
 		rc = pcmcia_parse_tuple(link, &tuple, &parse);
-		if(rc != CS_SUCCESS) {
+		if(rc != 0) {
 			cs_error(link, ParseTuple, rc);
 			break;
 		}
@@ -500,7 +500,7 @@ static int pcmciamtd_config(struct pcmcia_device *link)
 
 	DEBUG(2, "Validating CIS");
 	ret = pcmcia_validate_cis(link, NULL);
-	if(ret != CS_SUCCESS) {
+	if(ret != 0) {
 		cs_error(link, GetTupleData, ret);
 	}
 
@@ -582,7 +582,7 @@ static int pcmciamtd_config(struct pcmcia_device *link)
 	link->conf.ConfigIndex = 0;
 	DEBUG(2, "Setting Configuration");
 	ret = pcmcia_request_configuration(link, &link->conf);
-	if(ret != CS_SUCCESS) {
+	if(ret != 0) {
 		cs_error(link, RequestConfiguration, ret);
 		if (dev->win_base) {
 			iounmap(dev->win_base);
diff --git a/drivers/net/pcmcia/3c574_cs.c b/drivers/net/pcmcia/3c574_cs.c
index 7112fd5..d089b6f 100644
--- a/drivers/net/pcmcia/3c574_cs.c
+++ b/drivers/net/pcmcia/3c574_cs.c
@@ -355,9 +355,9 @@ static int tc574_config(struct pcmcia_device *link)
 	for (i = j = 0; j < 0x400; j += 0x20) {
 		link->io.BasePort1 = j ^ 0x300;
 		i = pcmcia_request_io(link, &link->io);
-		if (i == CS_SUCCESS) break;
+		if (i == 0) break;
 	}
-	if (i != CS_SUCCESS) {
+	if (i != 0) {
 		cs_error(link, RequestIO, i);
 		goto failed;
 	}
@@ -377,7 +377,7 @@ static int tc574_config(struct pcmcia_device *link)
 	tuple.TupleDataMax = 64;
 	tuple.TupleOffset = 0;
 	tuple.DesiredTuple = 0x88;
-	if (pcmcia_get_first_tuple(link, &tuple) == CS_SUCCESS) {
+	if (pcmcia_get_first_tuple(link, &tuple) == 0) {
 		pcmcia_get_tuple_data(link, &tuple);
 		for (i = 0; i < 3; i++)
 			phys_addr[i] = htons(le16_to_cpu(buf[i]));
diff --git a/drivers/net/pcmcia/3c589_cs.c b/drivers/net/pcmcia/3c589_cs.c
index 549a645..8bf051b 100644
--- a/drivers/net/pcmcia/3c589_cs.c
+++ b/drivers/net/pcmcia/3c589_cs.c
@@ -278,9 +278,9 @@ static int tc589_config(struct pcmcia_device *link)
 	if (multi && (j & 0x80)) continue;
 	link->io.BasePort1 = j ^ 0x300;
 	i = pcmcia_request_io(link, &link->io);
-	if (i == CS_SUCCESS) break;
+	if (i == 0) break;
     }
-    if (i != CS_SUCCESS) {
+    if (i != 0) {
 	cs_error(link, RequestIO, i);
 	goto failed;
     }
@@ -295,7 +295,7 @@ static int tc589_config(struct pcmcia_device *link)
     /* The 3c589 has an extra EEPROM for configuration info, including
        the hardware address.  The 3c562 puts the address in the CIS. */
     tuple.DesiredTuple = 0x88;
-    if (pcmcia_get_first_tuple(link, &tuple) == CS_SUCCESS) {
+    if (pcmcia_get_first_tuple(link, &tuple) == 0) {
 	pcmcia_get_tuple_data(link, &tuple);
 	for (i = 0; i < 3; i++)
 	    phys_addr[i] = htons(le16_to_cpu(buf[i]));
diff --git a/drivers/net/pcmcia/axnet_cs.c b/drivers/net/pcmcia/axnet_cs.c
index 061d889..0d48629 100644
--- a/drivers/net/pcmcia/axnet_cs.c
+++ b/drivers/net/pcmcia/axnet_cs.c
@@ -276,7 +276,7 @@ static int try_io_port(struct pcmcia_device *link)
 	    link->io.BasePort1 = j ^ 0x300;
 	    link->io.BasePort2 = (j ^ 0x300) + 0x10;
 	    ret = pcmcia_request_io(link, &link->io);
-	    if (ret == CS_SUCCESS) return ret;
+	    if (ret == 0) return ret;
 	}
 	return ret;
     } else {
@@ -327,7 +327,7 @@ static int axnet_config(struct pcmcia_device *link)
     /* don't trust the CIS on this; Linksys got it wrong */
     link->conf.Present = 0x63;
     last_ret = pcmcia_loop_config(link, axnet_configcheck, NULL);
-    if (last_ret != CS_SUCCESS) {
+    if (last_ret != 0) {
 	cs_error(link, RequestIO, last_ret);
 	goto failed;
     }
diff --git a/drivers/net/pcmcia/com20020_cs.c b/drivers/net/pcmcia/com20020_cs.c
index ea9414c..831090c 100644
--- a/drivers/net/pcmcia/com20020_cs.c
+++ b/drivers/net/pcmcia/com20020_cs.c
@@ -260,21 +260,21 @@ static int com20020_config(struct pcmcia_device *link)
     DEBUG(0, "com20020_config(0x%p)\n", link);
 
     DEBUG(1,"arcnet: baseport1 is %Xh\n", link->io.BasePort1);
-    i = !CS_SUCCESS;
+    i = -ENODEV;
     if (!link->io.BasePort1)
     {
 	for (ioaddr = 0x100; ioaddr < 0x400; ioaddr += 0x10)
 	{
 	    link->io.BasePort1 = ioaddr;
 	    i = pcmcia_request_io(link, &link->io);
-	    if (i == CS_SUCCESS)
+	    if (i == 0)
 		break;
 	}
     }
     else
 	i = pcmcia_request_io(link, &link->io);
     
-    if (i != CS_SUCCESS)
+    if (i != 0)
     {
 	DEBUG(1,"arcnet: requestIO failed totally!\n");
 	goto failed;
@@ -287,7 +287,7 @@ static int com20020_config(struct pcmcia_device *link)
 	   link->irq.AssignedIRQ,
 	   link->irq.IRQInfo1, link->irq.IRQInfo2);
     i = pcmcia_request_irq(link, &link->irq);
-    if (i != CS_SUCCESS)
+    if (i != 0)
     {
 	DEBUG(1,"arcnet: requestIRQ failed totally!\n");
 	goto failed;
diff --git a/drivers/net/pcmcia/fmvj18x_cs.c b/drivers/net/pcmcia/fmvj18x_cs.c
index a550c9b..7c966eb 100644
--- a/drivers/net/pcmcia/fmvj18x_cs.c
+++ b/drivers/net/pcmcia/fmvj18x_cs.c
@@ -309,7 +309,7 @@ static int mfc_try_io_port(struct pcmcia_device *link)
 	    printk(KERN_NOTICE "fmvj18x_cs: out of resource for serial\n");
 	}
 	ret = pcmcia_request_io(link, &link->io);
-	if (ret == CS_SUCCESS) return ret;
+	if (ret == 0) return ret;
     }
     return ret;
 }
@@ -325,7 +325,7 @@ static int ungermann_try_io_port(struct pcmcia_device *link)
     for (ioaddr = 0x300; ioaddr < 0x3e0; ioaddr += 0x20) {
 	link->io.BasePort1 = ioaddr;
 	ret = pcmcia_request_io(link, &link->io);
-	if (ret == CS_SUCCESS) {
+	if (ret == 0) {
 	    /* calculate ConfigIndex value */
 	    link->conf.ConfigIndex = 
 		((link->io.BasePort1 & 0x0f0) >> 3) | 0x22;
@@ -356,7 +356,7 @@ static int fmvj18x_config(struct pcmcia_device *link)
     tuple.TupleOffset = 0;
     tuple.DesiredTuple = CISTPL_FUNCE;
     tuple.TupleOffset = 0;
-    if (pcmcia_get_first_tuple(link, &tuple) == CS_SUCCESS) {
+    if (pcmcia_get_first_tuple(link, &tuple) == 0) {
 	/* Yes, I have CISTPL_FUNCE. Let's check CISTPL_MANFID */
 	tuple.DesiredTuple = CISTPL_CFTABLE_ENTRY;
 	CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link, &tuple));
@@ -430,10 +430,10 @@ static int fmvj18x_config(struct pcmcia_device *link)
     	link->irq.Attributes =
 		IRQ_TYPE_DYNAMIC_SHARING|IRQ_FIRST_SHARED|IRQ_HANDLE_PRESENT;
 	ret = mfc_try_io_port(link);
-	if (ret != CS_SUCCESS) goto cs_failed;
+	if (ret != 0) goto cs_failed;
     } else if (cardtype == UNGERMANN) {
 	ret = ungermann_try_io_port(link);
-	if (ret != CS_SUCCESS) goto cs_failed;
+	if (ret != 0) goto cs_failed;
     } else { 
 	CS_CHECK(RequestIO, pcmcia_request_io(link, &link->io));
     }
@@ -565,7 +565,7 @@ static int fmvj18x_get_hwinfo(struct pcmcia_device *link, u_char *node_id)
     req.Base = 0; req.Size = 0;
     req.AccessSpeed = 0;
     i = pcmcia_request_window(&link, &req, &link->win);
-    if (i != CS_SUCCESS) {
+    if (i != 0) {
 	cs_error(link, RequestWindow, i);
 	return -1;
     }
@@ -599,7 +599,7 @@ static int fmvj18x_get_hwinfo(struct pcmcia_device *link, u_char *node_id)
 
     iounmap(base);
     j = pcmcia_release_window(link->win);
-    if (j != CS_SUCCESS)
+    if (j != 0)
 	cs_error(link, ReleaseWindow, j);
     return (i != 0x200) ? 0 : -1;
 
@@ -620,7 +620,7 @@ static int fmvj18x_setup_mfc(struct pcmcia_device *link)
     req.Base = 0; req.Size = 0;
     req.AccessSpeed = 0;
     i = pcmcia_request_window(&link, &req, &link->win);
-    if (i != CS_SUCCESS) {
+    if (i != 0) {
 	cs_error(link, RequestWindow, i);
 	return -1;
     }
@@ -642,7 +642,7 @@ static int fmvj18x_setup_mfc(struct pcmcia_device *link)
 
     iounmap(base);
     j = pcmcia_release_window(link->win);
-    if (j != CS_SUCCESS)
+    if (j != 0)
 	cs_error(link, ReleaseWindow, j);
     return 0;
 
diff --git a/drivers/net/pcmcia/ibmtr_cs.c b/drivers/net/pcmcia/ibmtr_cs.c
index 4eafa4f..cf3cca4 100644
--- a/drivers/net/pcmcia/ibmtr_cs.c
+++ b/drivers/net/pcmcia/ibmtr_cs.c
@@ -238,7 +238,7 @@ static int __devinit ibmtr_config(struct pcmcia_device *link)
     /* Try PRIMARY card at 0xA20-0xA23 */
     link->io.BasePort1 = 0xA20;
     i = pcmcia_request_io(link, &link->io);
-    if (i != CS_SUCCESS) {
+    if (i != 0) {
 	/* Couldn't get 0xA20-0xA23.  Try ALTERNATE at 0xA24-0xA27. */
 	link->io.BasePort1 = 0xA24;
 	CS_CHECK(RequestIO, pcmcia_request_io(link, &link->io));
diff --git a/drivers/net/pcmcia/pcnet_cs.c b/drivers/net/pcmcia/pcnet_cs.c
index aa17434..480c194 100644
--- a/drivers/net/pcmcia/pcnet_cs.c
+++ b/drivers/net/pcmcia/pcnet_cs.c
@@ -310,7 +310,7 @@ static hw_info_t *get_hwinfo(struct pcmcia_device *link)
     req.Base = 0; req.Size = 0;
     req.AccessSpeed = 0;
     i = pcmcia_request_window(&link, &req, &link->win);
-    if (i != CS_SUCCESS) {
+    if (i != 0) {
 	cs_error(link, RequestWindow, i);
 	return NULL;
     }
@@ -333,7 +333,7 @@ static hw_info_t *get_hwinfo(struct pcmcia_device *link)
 
     iounmap(virt);
     j = pcmcia_release_window(link->win);
-    if (j != CS_SUCCESS)
+    if (j != 0)
 	cs_error(link, ReleaseWindow, j);
     return (i < NR_INFO) ? hw_info+i : NULL;
 } /* get_hwinfo */
@@ -504,7 +504,7 @@ static int try_io_port(struct pcmcia_device *link)
 	    link->io.BasePort1 = j ^ 0x300;
 	    link->io.BasePort2 = (j ^ 0x300) + 0x10;
 	    ret = pcmcia_request_io(link, &link->io);
-	    if (ret == CS_SUCCESS) return ret;
+	    if (ret == 0) return ret;
 	}
 	return ret;
     } else {
diff --git a/drivers/net/pcmcia/smc91c92_cs.c b/drivers/net/pcmcia/smc91c92_cs.c
index b3f2085..e508b47 100644
--- a/drivers/net/pcmcia/smc91c92_cs.c
+++ b/drivers/net/pcmcia/smc91c92_cs.c
@@ -409,8 +409,8 @@ static int first_tuple(struct pcmcia_device *handle, tuple_t *tuple,
 {
 	int i;
 
-	if ((i = pcmcia_get_first_tuple(handle, tuple)) != CS_SUCCESS ||
-			(i = pcmcia_get_tuple_data(handle, tuple)) != CS_SUCCESS)
+	if ((i = pcmcia_get_first_tuple(handle, tuple)) != 0 ||
+			(i = pcmcia_get_tuple_data(handle, tuple)) != 0)
 		return i;
 	return pcmcia_parse_tuple(handle, tuple, parse);
 }
@@ -420,8 +420,8 @@ static int next_tuple(struct pcmcia_device *handle, tuple_t *tuple,
 {
 	int i;
 
-	if ((i = pcmcia_get_next_tuple(handle, tuple)) != CS_SUCCESS ||
-			(i = pcmcia_get_tuple_data(handle, tuple)) != CS_SUCCESS)
+	if ((i = pcmcia_get_next_tuple(handle, tuple)) != 0 ||
+			(i = pcmcia_get_tuple_data(handle, tuple)) != 0)
 		return i;
 	return pcmcia_parse_tuple(handle, tuple, parse);
 }
@@ -509,7 +509,7 @@ static int mhz_mfc_config(struct pcmcia_device *link)
     req.Base = req.Size = 0;
     req.AccessSpeed = 0;
     i = pcmcia_request_window(&link, &req, &link->win);
-    if (i != CS_SUCCESS)
+    if (i != 0)
 	goto free_cfg_mem;
     smc->base = ioremap(req.Base, req.Size);
     mem.CardOffset = mem.Page = 0;
@@ -517,7 +517,7 @@ static int mhz_mfc_config(struct pcmcia_device *link)
 	mem.CardOffset = link->conf.ConfigBase;
     i = pcmcia_map_mem_page(link->win, &mem);
 
-    if ((i == CS_SUCCESS)
+    if ((i == 0)
 	&& (smc->manfid == MANFID_MEGAHERTZ)
 	&& (smc->cardid == PRODID_MEGAHERTZ_EM3288))
 	mhz_3288_power(link);
@@ -551,12 +551,12 @@ static int mhz_setup(struct pcmcia_device *link)
     /* Read the station address from the CIS.  It is stored as the last
        (fourth) string in the Version 1 Version/ID tuple. */
     tuple->DesiredTuple = CISTPL_VERS_1;
-    if (first_tuple(link, tuple, parse) != CS_SUCCESS) {
+    if (first_tuple(link, tuple, parse) != 0) {
 	rc = -1;
 	goto free_cfg_mem;
     }
     /* Ugh -- the EM1144 card has two VERS_1 tuples!?! */
-    if (next_tuple(link, tuple, parse) != CS_SUCCESS)
+    if (next_tuple(link, tuple, parse) != 0)
 	first_tuple(link, tuple, parse);
     if (parse->version_1.ns > 3) {
 	station_addr = parse->version_1.str + parse->version_1.ofs[3];
@@ -568,11 +568,11 @@ static int mhz_setup(struct pcmcia_device *link)
 
     /* Another possibility: for the EM3288, in a special tuple */
     tuple->DesiredTuple = 0x81;
-    if (pcmcia_get_first_tuple(link, tuple) != CS_SUCCESS) {
+    if (pcmcia_get_first_tuple(link, tuple) != 0) {
 	rc = -1;
 	goto free_cfg_mem;
     }
-    if (pcmcia_get_tuple_data(link, tuple) != CS_SUCCESS) {
+    if (pcmcia_get_tuple_data(link, tuple) != 0) {
 	rc = -1;
 	goto free_cfg_mem;
     }
@@ -700,12 +700,12 @@ static int smc_setup(struct pcmcia_device *link)
     /* Check for a LAN function extension tuple */
     tuple->DesiredTuple = CISTPL_FUNCE;
     i = first_tuple(link, tuple, parse);
-    while (i == CS_SUCCESS) {
+    while (i == 0) {
 	if (parse->funce.type == CISTPL_FUNCE_LAN_NODE_ID)
 	    break;
 	i = next_tuple(link, tuple, parse);
     }
-    if (i == CS_SUCCESS) {
+    if (i == 0) {
 	node_id = (cistpl_lan_node_id_t *)parse->funce.data;
 	if (node_id->nb == 6) {
 	    for (i = 0; i < 6; i++)
@@ -752,9 +752,9 @@ static int osi_config(struct pcmcia_device *link)
     for (i = j = 0; j < 4; j++) {
 	link->io.BasePort2 = com[j];
 	i = pcmcia_request_io(link, &link->io);
-	if (i == CS_SUCCESS) break;
+	if (i == 0) break;
     }
-    if (i != CS_SUCCESS) {
+    if (i != 0) {
 	/* Fallback: turn off hard decode */
 	link->conf.ConfigIndex = 0x03;
 	link->io.NumPorts2 = 0;
@@ -787,13 +787,13 @@ static int osi_setup(struct pcmcia_device *link, u_short manfid, u_short cardid)
     /* Read the station address from tuple 0x90, subtuple 0x04 */
     tuple->DesiredTuple = 0x90;
     i = pcmcia_get_first_tuple(link, tuple);
-    while (i == CS_SUCCESS) {
+    while (i == 0) {
 	i = pcmcia_get_tuple_data(link, tuple);
-	if ((i != CS_SUCCESS) || (buf[0] == 0x04))
+	if ((i != 0) || (buf[0] == 0x04))
 	    break;
 	i = pcmcia_get_next_tuple(link, tuple);
     }
-    if (i != CS_SUCCESS) {
+    if (i != 0) {
 	rc = -1;
 	goto free_cfg_mem;
     }
@@ -932,7 +932,7 @@ static int check_sig(struct pcmcia_device *link)
 ======================================================================*/
 
 #define CS_EXIT_TEST(ret, svc, label) \
-if (ret != CS_SUCCESS) { cs_error(link, svc, ret); goto label; }
+if (ret != 0) { cs_error(link, svc, ret); goto label; }
 
 static int smc91c92_config(struct pcmcia_device *link)
 {
diff --git a/drivers/net/wireless/b43/pcmcia.c b/drivers/net/wireless/b43/pcmcia.c
index b8aa163..ab42fb6 100644
--- a/drivers/net/wireless/b43/pcmcia.c
+++ b/drivers/net/wireless/b43/pcmcia.c
@@ -82,13 +82,13 @@ static int __devinit b43_pcmcia_probe(struct pcmcia_device *dev)
 	tuple.TupleOffset = 0;
 
 	res = pcmcia_get_first_tuple(dev, &tuple);
-	if (res != CS_SUCCESS)
+	if (res != 0)
 		goto err_kfree_ssb;
 	res = pcmcia_get_tuple_data(dev, &tuple);
-	if (res != CS_SUCCESS)
+	if (res != 0)
 		goto err_kfree_ssb;
 	res = pcmcia_parse_tuple(dev, &tuple, &parse);
-	if (res != CS_SUCCESS)
+	if (res != 0)
 		goto err_kfree_ssb;
 
 	dev->conf.ConfigBase = parse.config.base;
@@ -107,13 +107,13 @@ static int __devinit b43_pcmcia_probe(struct pcmcia_device *dev)
 	win.Size = SSB_CORE_SIZE;
 	win.AccessSpeed = 250;
 	res = pcmcia_request_window(&dev, &win, &dev->win);
-	if (res != CS_SUCCESS)
+	if (res != 0)
 		goto err_kfree_ssb;
 
 	mem.CardOffset = 0;
 	mem.Page = 0;
 	res = pcmcia_map_mem_page(dev->win, &mem);
-	if (res != CS_SUCCESS)
+	if (res != 0)
 		goto err_disable;
 
 	dev->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
@@ -121,11 +121,11 @@ static int __devinit b43_pcmcia_probe(struct pcmcia_device *dev)
 	dev->irq.Handler = NULL; /* The handler is registered later. */
 	dev->irq.Instance = NULL;
 	res = pcmcia_request_irq(dev, &dev->irq);
-	if (res != CS_SUCCESS)
+	if (res != 0)
 		goto err_disable;
 
 	res = pcmcia_request_configuration(dev, &dev->conf);
-	if (res != CS_SUCCESS)
+	if (res != 0)
 		goto err_disable;
 
 	err = ssb_bus_pcmciabus_register(ssb, dev, win.Base);
diff --git a/drivers/net/wireless/hostap/hostap_cs.c b/drivers/net/wireless/hostap/hostap_cs.c
index 6a0a3c1..39dded7 100644
--- a/drivers/net/wireless/hostap/hostap_cs.c
+++ b/drivers/net/wireless/hostap/hostap_cs.c
@@ -234,7 +234,7 @@ static void sandisk_set_iobase(local_info_t *local)
 	reg.Value = hw_priv->link->io.BasePort1 & 0x00ff;
 	res = pcmcia_access_configuration_register(hw_priv->link,
 						   &reg);
-	if (res != CS_SUCCESS) {
+	if (res != 0) {
 		printk(KERN_DEBUG "Prism3 SanDisk - failed to set I/O base 0 -"
 		       " res=%d\n", res);
 	}
@@ -246,7 +246,7 @@ static void sandisk_set_iobase(local_info_t *local)
 	reg.Value = (hw_priv->link->io.BasePort1 & 0xff00) >> 8;
 	res = pcmcia_access_configuration_register(hw_priv->link,
 						   &reg);
-	if (res != CS_SUCCESS) {
+	if (res != 0) {
 		printk(KERN_DEBUG "Prism3 SanDisk - failed to set I/O base 1 -"
 		       " res=%d\n", res);
 	}
@@ -322,7 +322,7 @@ static int sandisk_enable_wireless(struct net_device *dev)
 	reg.Value = COR_SOFT_RESET;
 	res = pcmcia_access_configuration_register(hw_priv->link,
 						   &reg);
-	if (res != CS_SUCCESS) {
+	if (res != 0) {
 		printk(KERN_DEBUG "%s: SanDisk - COR sreset failed (%d)\n",
 		       dev->name, res);
 		goto done;
@@ -339,7 +339,7 @@ static int sandisk_enable_wireless(struct net_device *dev)
 	reg.Value = COR_LEVEL_REQ | 0x8 | COR_ADDR_DECODE | COR_FUNC_ENA;
 	res = pcmcia_access_configuration_register(hw_priv->link,
 						   &reg);
-	if (res != CS_SUCCESS) {
+	if (res != 0) {
 		printk(KERN_DEBUG "%s: SanDisk - COR sreset failed (%d)\n",
 		       dev->name, res);
 		goto done;
@@ -374,7 +374,7 @@ static void prism2_pccard_cor_sreset(local_info_t *local)
 	reg.Value = 0;
 	res = pcmcia_access_configuration_register(hw_priv->link,
 						   &reg);
-	if (res != CS_SUCCESS) {
+	if (res != 0) {
 		printk(KERN_DEBUG "prism2_pccard_cor_sreset failed 1 (%d)\n",
 		       res);
 		return;
@@ -386,7 +386,7 @@ static void prism2_pccard_cor_sreset(local_info_t *local)
 	reg.Value |= COR_SOFT_RESET;
 	res = pcmcia_access_configuration_register(hw_priv->link,
 						   &reg);
-	if (res != CS_SUCCESS) {
+	if (res != 0) {
 		printk(KERN_DEBUG "prism2_pccard_cor_sreset failed 2 (%d)\n",
 		       res);
 		return;
@@ -399,7 +399,7 @@ static void prism2_pccard_cor_sreset(local_info_t *local)
 		reg.Value |= COR_IREQ_ENA;
 	res = pcmcia_access_configuration_register(hw_priv->link,
 						   &reg);
-	if (res != CS_SUCCESS) {
+	if (res != 0) {
 		printk(KERN_DEBUG "prism2_pccard_cor_sreset failed 3 (%d)\n",
 		       res);
 		return;
@@ -433,7 +433,7 @@ static void prism2_pccard_genesis_reset(local_info_t *local, int hcr)
 	reg.Value = 0;
 	res = pcmcia_access_configuration_register(hw_priv->link,
 						   &reg);
-	if (res != CS_SUCCESS) {
+	if (res != 0) {
 		printk(KERN_DEBUG "prism2_pccard_genesis_sreset failed 1 "
 		       "(%d)\n", res);
 		return;
@@ -446,7 +446,7 @@ static void prism2_pccard_genesis_reset(local_info_t *local, int hcr)
 	reg.Value |= COR_SOFT_RESET;
 	res = pcmcia_access_configuration_register(hw_priv->link,
 						   &reg);
-	if (res != CS_SUCCESS) {
+	if (res != 0) {
 		printk(KERN_DEBUG "prism2_pccard_genesis_sreset failed 2 "
 		       "(%d)\n", res);
 		return;
@@ -460,7 +460,7 @@ static void prism2_pccard_genesis_reset(local_info_t *local, int hcr)
 	reg.Offset = CISREG_CCSR;
 	res = pcmcia_access_configuration_register(hw_priv->link,
 						   &reg);
-	if (res != CS_SUCCESS) {
+	if (res != 0) {
 		printk(KERN_DEBUG "prism2_pccard_genesis_sreset failed 3 "
 		       "(%d)\n", res);
 		return;
@@ -472,7 +472,7 @@ static void prism2_pccard_genesis_reset(local_info_t *local, int hcr)
 	reg.Value = old_cor & ~COR_SOFT_RESET;
 	res = pcmcia_access_configuration_register(hw_priv->link,
 						   &reg);
-	if (res != CS_SUCCESS) {
+	if (res != 0) {
 		printk(KERN_DEBUG "prism2_pccard_genesis_sreset failed 4 "
 		       "(%d)\n", res);
 		return;
diff --git a/drivers/net/wireless/netwave_cs.c b/drivers/net/wireless/netwave_cs.c
index f479c1a..375686d 100644
--- a/drivers/net/wireless/netwave_cs.c
+++ b/drivers/net/wireless/netwave_cs.c
@@ -749,9 +749,9 @@ static int netwave_pcmcia_config(struct pcmcia_device *link) {
     for (i = j = 0x0; j < 0x400; j += 0x20) {
 	link->io.BasePort1 = j ^ 0x300;
 	i = pcmcia_request_io(link, &link->io);
-	if (i == CS_SUCCESS) break;
+	if (i == 0) break;
     }
-    if (i != CS_SUCCESS) {
+    if (i != 0) {
 	cs_error(link, RequestIO, i);
 	goto failed;
     }
diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
index 963960d..99c7c8b 100644
--- a/drivers/net/wireless/ray_cs.c
+++ b/drivers/net/wireless/ray_cs.c
@@ -798,9 +798,9 @@ static void ray_release(struct pcmcia_device *link)
     iounmap(local->amem);
     /* Do bother checking to see if these succeed or not */
     i = pcmcia_release_window(local->amem_handle);
-    if ( i != CS_SUCCESS ) DEBUG(0,"ReleaseWindow(local->amem) ret = %x\n",i);
+    if ( i != 0 ) DEBUG(0,"ReleaseWindow(local->amem) ret = %x\n",i);
     i = pcmcia_release_window(local->rmem_handle);
-    if ( i != CS_SUCCESS ) DEBUG(0,"ReleaseWindow(local->rmem) ret = %x\n",i);
+    if ( i != 0 ) DEBUG(0,"ReleaseWindow(local->rmem) ret = %x\n",i);
     pcmcia_disable_device(link);
 
     DEBUG(2,"ray_release ending\n");
diff --git a/drivers/net/wireless/wavelan_cs.c b/drivers/net/wireless/wavelan_cs.c
index b584c0e..b37a956 100644
--- a/drivers/net/wireless/wavelan_cs.c
+++ b/drivers/net/wireless/wavelan_cs.c
@@ -3708,7 +3708,7 @@ wv_pcmcia_reset(struct net_device *	dev)
 #endif
 
   i = pcmcia_access_configuration_register(link, &reg);
-  if(i != CS_SUCCESS)
+  if(i != 0)
     {
       cs_error(link, AccessConfigurationRegister, i);
       return FALSE;
@@ -3722,7 +3722,7 @@ wv_pcmcia_reset(struct net_device *	dev)
   reg.Action = CS_WRITE;
   reg.Value = reg.Value | COR_SW_RESET;
   i = pcmcia_access_configuration_register(link, &reg);
-  if(i != CS_SUCCESS)
+  if(i != 0)
     {
       cs_error(link, AccessConfigurationRegister, i);
       return FALSE;
@@ -3731,7 +3731,7 @@ wv_pcmcia_reset(struct net_device *	dev)
   reg.Action = CS_WRITE;
   reg.Value = COR_LEVEL_IRQ | COR_CONFIG;
   i = pcmcia_access_configuration_register(link, &reg);
-  if(i != CS_SUCCESS)
+  if(i != 0)
     {
       cs_error(link, AccessConfigurationRegister, i);
       return FALSE;
@@ -3909,7 +3909,7 @@ wv_pcmcia_config(struct pcmcia_device *	link)
   do
     {
       i = pcmcia_request_io(link, &link->io);
-      if(i != CS_SUCCESS)
+      if(i != 0)
 	{
 	  cs_error(link, RequestIO, i);
 	  break;
@@ -3920,7 +3920,7 @@ wv_pcmcia_config(struct pcmcia_device *	link)
        * actually assign a handler to the interrupt.
        */
       i = pcmcia_request_irq(link, &link->irq);
-      if(i != CS_SUCCESS)
+      if(i != 0)
 	{
 	  cs_error(link, RequestIRQ, i);
 	  break;
@@ -3932,7 +3932,7 @@ wv_pcmcia_config(struct pcmcia_device *	link)
        */
       link->conf.ConfigIndex = 1;
       i = pcmcia_request_configuration(link, &link->conf);
-      if(i != CS_SUCCESS)
+      if(i != 0)
 	{
 	  cs_error(link, RequestConfiguration, i);
 	  break;
@@ -3948,7 +3948,7 @@ wv_pcmcia_config(struct pcmcia_device *	link)
       req.Base = req.Size = 0;
       req.AccessSpeed = mem_speed;
       i = pcmcia_request_window(&link, &req, &link->win);
-      if(i != CS_SUCCESS)
+      if(i != 0)
 	{
 	  cs_error(link, RequestWindow, i);
 	  break;
@@ -3960,7 +3960,7 @@ wv_pcmcia_config(struct pcmcia_device *	link)
 
       mem.CardOffset = 0; mem.Page = 0;
       i = pcmcia_map_mem_page(link->win, &mem);
-      if(i != CS_SUCCESS)
+      if(i != 0)
 	{
 	  cs_error(link, MapMemPage, i);
 	  break;
diff --git a/drivers/net/wireless/wl3501_cs.c b/drivers/net/wireless/wl3501_cs.c
index 3771419..969f53f 100644
--- a/drivers/net/wireless/wl3501_cs.c
+++ b/drivers/net/wireless/wl3501_cs.c
@@ -1977,10 +1977,10 @@ static int wl3501_config(struct pcmcia_device *link)
 		link->io.BasePort1 = j;
 		link->io.BasePort2 = link->io.BasePort1 + 0x10;
 		i = pcmcia_request_io(link, &link->io);
-		if (i == CS_SUCCESS)
+		if (i == 0)
 			break;
 	}
-	if (i != CS_SUCCESS) {
+	if (i != 0) {
 		cs_error(link, RequestIO, i);
 		goto failed;
 	}
diff --git a/drivers/pcmcia/cardbus.c b/drivers/pcmcia/cardbus.c
index 911ca0e..db77e1f 100644
--- a/drivers/pcmcia/cardbus.c
+++ b/drivers/pcmcia/cardbus.c
@@ -238,7 +238,7 @@ int __ref cb_alloc(struct pcmcia_socket * s)
 	pci_bus_add_devices(bus);
 
 	s->irq.AssignedIRQ = s->pci_irq;
-	return CS_SUCCESS;
+	return 0;
 }
 
 void cb_free(struct pcmcia_socket * s)
diff --git a/drivers/pcmcia/cistpl.c b/drivers/pcmcia/cistpl.c
index fe789e0..eb182c6 100644
--- a/drivers/pcmcia/cistpl.c
+++ b/drivers/pcmcia/cistpl.c
@@ -392,7 +392,7 @@ int pcmcia_replace_cis(struct pcmcia_socket *s,
 	return CS_OUT_OF_RESOURCE;
     s->fake_cis_len = len;
     memcpy(s->fake_cis, data, len);
-    return CS_SUCCESS;
+    return 0;
 }
 EXPORT_SYMBOL(pcmcia_replace_cis);
 
@@ -441,9 +441,9 @@ int pccard_get_first_tuple(struct pcmcia_socket *s, unsigned int function, tuple
 	!(tuple->Attributes & TUPLE_RETURN_COMMON)) {
 	cisdata_t req = tuple->DesiredTuple;
 	tuple->DesiredTuple = CISTPL_LONGLINK_MFC;
-	if (pccard_get_next_tuple(s, function, tuple) == CS_SUCCESS) {
+	if (pccard_get_next_tuple(s, function, tuple) == 0) {
 	    tuple->DesiredTuple = CISTPL_LINKTARGET;
-	    if (pccard_get_next_tuple(s, function, tuple) != CS_SUCCESS)
+	    if (pccard_get_next_tuple(s, function, tuple) != 0)
 		return CS_NO_MORE_ITEMS;
 	} else
 	    tuple->CISOffset = tuple->TupleLink = 0;
@@ -584,7 +584,7 @@ int pccard_get_next_tuple(struct pcmcia_socket *s, unsigned int function, tuple_
     tuple->TupleCode = link[0];
     tuple->TupleLink = link[1];
     tuple->CISOffset = ofs + 2;
-    return CS_SUCCESS;
+    return 0;
 }
 EXPORT_SYMBOL(pccard_get_next_tuple);
 
@@ -604,11 +604,11 @@ int pccard_get_tuple_data(struct pcmcia_socket *s, tuple_t *tuple)
     len = tuple->TupleLink - tuple->TupleOffset;
     tuple->TupleDataLen = tuple->TupleLink;
     if (len == 0)
-	return CS_SUCCESS;
+	return 0;
     read_cis_cache(s, SPACE(tuple->Flags),
 		   tuple->CISOffset + tuple->TupleOffset,
 		   _MIN(len, tuple->TupleDataMax), tuple->TupleData);
-    return CS_SUCCESS;
+    return 0;
 }
 EXPORT_SYMBOL(pccard_get_tuple_data);
 
@@ -659,7 +659,7 @@ static int parse_device(tuple_t *tuple, cistpl_device_t *device)
 	if (++p == q) break;
     }
     
-    return CS_SUCCESS;
+    return 0;
 }
 
 /*====================================================================*/
@@ -673,7 +673,7 @@ static int parse_checksum(tuple_t *tuple, cistpl_checksum_t *csum)
     csum->addr = tuple->CISOffset + get_unaligned_le16(p) - 2;
     csum->len = get_unaligned_le16(p + 2);
     csum->sum = *(p + 4);
-    return CS_SUCCESS;
+    return 0;
 }
 
 /*====================================================================*/
@@ -683,7 +683,7 @@ static int parse_longlink(tuple_t *tuple, cistpl_longlink_t *link)
     if (tuple->TupleDataLen < 4)
 	return CS_BAD_TUPLE;
     link->addr = get_unaligned_le32(tuple->TupleData);
-    return CS_SUCCESS;
+    return 0;
 }
 
 /*====================================================================*/
@@ -704,7 +704,7 @@ static int parse_longlink_mfc(tuple_t *tuple,
 	link->fn[i].addr = get_unaligned_le32(p);
 	p += 4;
     }
-    return CS_SUCCESS;
+    return 0;
 }
 
 /*====================================================================*/
@@ -729,9 +729,9 @@ static int parse_strings(u_char *p, u_char *q, int max,
     }
     if (found) {
 	*found = ns;
-	return CS_SUCCESS;
+	return 0;
     } else {
-	return (ns == max) ? CS_SUCCESS : CS_BAD_TUPLE;
+	return (ns == max) ? 0 : CS_BAD_TUPLE;
     }
 }
 
@@ -782,7 +782,7 @@ static int parse_jedec(tuple_t *tuple, cistpl_jedec_t *jedec)
 	p += 2;
     }
     jedec->nid = nid;
-    return CS_SUCCESS;
+    return 0;
 }
 
 /*====================================================================*/
@@ -793,7 +793,7 @@ static int parse_manfid(tuple_t *tuple, cistpl_manfid_t *m)
 	return CS_BAD_TUPLE;
     m->manf = get_unaligned_le16(tuple->TupleData);
     m->card = get_unaligned_le16(tuple->TupleData + 2);
-    return CS_SUCCESS;
+    return 0;
 }
 
 /*====================================================================*/
@@ -806,7 +806,7 @@ static int parse_funcid(tuple_t *tuple, cistpl_funcid_t *f)
     p = (u_char *)tuple->TupleData;
     f->func = p[0];
     f->sysinit = p[1];
-    return CS_SUCCESS;
+    return 0;
 }
 
 /*====================================================================*/
@@ -821,7 +821,7 @@ static int parse_funce(tuple_t *tuple, cistpl_funce_t *f)
     f->type = p[0];
     for (i = 1; i < tuple->TupleDataLen; i++)
 	f->data[i-1] = p[i];
-    return CS_SUCCESS;
+    return 0;
 }
 
 /*====================================================================*/
@@ -847,7 +847,7 @@ static int parse_config(tuple_t *tuple, cistpl_config_t *config)
     for (i = 0; i <= rmsz; i++)
 	config->rmask[i>>2] += p[i] << (8*(i%4));
     config->subtuples = tuple->TupleDataLen - (rasz+rmsz+4);
-    return CS_SUCCESS;
+    return 0;
 }
 
 /*======================================================================
@@ -1122,7 +1122,7 @@ static int parse_cftable_entry(tuple_t *tuple,
 
     entry->subtuples = q-p;
     
-    return CS_SUCCESS;
+    return 0;
 }
 
 /*====================================================================*/
@@ -1138,7 +1138,7 @@ static int parse_bar(tuple_t *tuple, cistpl_bar_t *bar)
     bar->attr = *p;
     p += 2;
     bar->size = get_unaligned_le32(p);
-    return CS_SUCCESS;
+    return 0;
 }
 
 static int parse_config_cb(tuple_t *tuple, cistpl_config_t *config)
@@ -1152,7 +1152,7 @@ static int parse_config_cb(tuple_t *tuple, cistpl_config_t *config)
     p++;
     config->base = get_unaligned_le32(p);
     config->subtuples = tuple->TupleDataLen - 6;
-    return CS_SUCCESS;
+    return 0;
 }
 
 static int parse_cftable_entry_cb(tuple_t *tuple,
@@ -1223,7 +1223,7 @@ static int parse_cftable_entry_cb(tuple_t *tuple,
 
     entry->subtuples = q-p;
     
-    return CS_SUCCESS;
+    return 0;
 }
 
 #endif
@@ -1249,7 +1249,7 @@ static int parse_device_geo(tuple_t *tuple, cistpl_device_geo_t *geo)
 	p += 6;
     }
     geo->ngeo = n;
-    return CS_SUCCESS;
+    return 0;
 }
 
 /*====================================================================*/
@@ -1291,7 +1291,7 @@ static int parse_org(tuple_t *tuple, cistpl_org_t *org)
 	if (*p == '\0') break;
 	if (++p == q) return CS_BAD_TUPLE;
     }
-    return CS_SUCCESS;
+    return 0;
 }
 
 /*====================================================================*/
@@ -1310,14 +1310,14 @@ static int parse_format(tuple_t *tuple, cistpl_format_t *fmt)
     fmt->offset = get_unaligned_le32(p + 2);
     fmt->length = get_unaligned_le32(p + 6);
 
-    return CS_SUCCESS;
+    return 0;
 }
 
 /*====================================================================*/
 
 int pccard_parse_tuple(tuple_t *tuple, cisparse_t *parse)
 {
-    int ret = CS_SUCCESS;
+    int ret = 0;
     
     if (tuple->TupleDataLen > tuple->TupleDataMax)
 	return CS_BAD_TUPLE;
@@ -1388,7 +1388,7 @@ int pccard_parse_tuple(tuple_t *tuple, cisparse_t *parse)
 	break;
     case CISTPL_NO_LINK:
     case CISTPL_LINKTARGET:
-	ret = CS_SUCCESS;
+	ret = 0;
 	break;
     default:
 	ret = CS_UNSUPPORTED_FUNCTION;
@@ -1416,12 +1416,12 @@ int pccard_read_tuple(struct pcmcia_socket *s, unsigned int function, cisdata_t
     tuple.DesiredTuple = code;
     tuple.Attributes = TUPLE_RETURN_COMMON;
     ret = pccard_get_first_tuple(s, function, &tuple);
-    if (ret != CS_SUCCESS) goto done;
+    if (ret != 0) goto done;
     tuple.TupleData = buf;
     tuple.TupleOffset = 0;
     tuple.TupleDataMax = 255;
     ret = pccard_get_tuple_data(s, &tuple);
-    if (ret != CS_SUCCESS) goto done;
+    if (ret != 0) goto done;
     ret = pccard_parse_tuple(&tuple, parse);
 done:
     kfree(buf);
@@ -1462,21 +1462,21 @@ int pccard_validate_cis(struct pcmcia_socket *s, unsigned int function, unsigned
     tuple->DesiredTuple = RETURN_FIRST_TUPLE;
     tuple->Attributes = TUPLE_RETURN_COMMON;
     ret = pccard_get_first_tuple(s, function, tuple);
-    if (ret != CS_SUCCESS)
+    if (ret != 0)
 	goto done;
 
     /* First tuple should be DEVICE; we should really have either that
        or a CFTABLE_ENTRY of some sort */
     if ((tuple->TupleCode == CISTPL_DEVICE) ||
-	(pccard_read_tuple(s, function, CISTPL_CFTABLE_ENTRY, p) == CS_SUCCESS) ||
-	(pccard_read_tuple(s, function, CISTPL_CFTABLE_ENTRY_CB, p) == CS_SUCCESS))
+	(pccard_read_tuple(s, function, CISTPL_CFTABLE_ENTRY, p) == 0) ||
+	(pccard_read_tuple(s, function, CISTPL_CFTABLE_ENTRY_CB, p) == 0))
 	dev_ok++;
 
     /* All cards should have a MANFID tuple, and/or a VERS_1 or VERS_2
        tuple, for card identification.  Certain old D-Link and Linksys
        cards have only a broken VERS_2 tuple; hence the bogus test. */
-    if ((pccard_read_tuple(s, function, CISTPL_MANFID, p) == CS_SUCCESS) ||
-	(pccard_read_tuple(s, function, CISTPL_VERS_1, p) == CS_SUCCESS) ||
+    if ((pccard_read_tuple(s, function, CISTPL_MANFID, p) == 0) ||
+	(pccard_read_tuple(s, function, CISTPL_VERS_1, p) == 0) ||
 	(pccard_read_tuple(s, function, CISTPL_VERS_2, p) != CS_NO_MORE_ITEMS))
 	ident_ok++;
 
@@ -1485,7 +1485,7 @@ int pccard_validate_cis(struct pcmcia_socket *s, unsigned int function, unsigned
 
     for (count = 1; count < MAX_TUPLES; count++) {
 	ret = pccard_get_next_tuple(s, function, tuple);
-	if (ret != CS_SUCCESS) break;
+	if (ret != 0) break;
 	if (((tuple->TupleCode > 0x23) && (tuple->TupleCode < 0x40)) ||
 	    ((tuple->TupleCode > 0x47) && (tuple->TupleCode < 0x80)) ||
 	    ((tuple->TupleCode > 0x90) && (tuple->TupleCode < 0xff)))
@@ -1500,6 +1500,6 @@ done:
 	    *info = count;
     kfree(tuple);
     kfree(p);
-    return CS_SUCCESS;
+    return 0;
 }
 EXPORT_SYMBOL(pccard_validate_cis);
diff --git a/drivers/pcmcia/cs.c b/drivers/pcmcia/cs.c
index ceb2b0c..b708ad6 100644
--- a/drivers/pcmcia/cs.c
+++ b/drivers/pcmcia/cs.c
@@ -370,7 +370,7 @@ static int socket_reset(struct pcmcia_socket *skt)
 			return CS_NO_CARD;
 
 		if (status & SS_READY)
-			return CS_SUCCESS;
+			return 0;
 
 		msleep(unreset_check * 10);
 	}
@@ -507,7 +507,7 @@ static int socket_insert(struct pcmcia_socket *skt)
 		return CS_NO_CARD;
 
 	ret = socket_setup(skt, setup_delay);
-	if (ret == CS_SUCCESS) {
+	if (ret == 0) {
 		skt->state |= SOCKET_PRESENT;
 
 		dev_printk(KERN_NOTICE, &skt->dev,
@@ -543,7 +543,7 @@ static int socket_suspend(struct pcmcia_socket *skt)
 		skt->ops->suspend(skt);
 	skt->state |= SOCKET_SUSPEND;
 
-	return CS_SUCCESS;
+	return 0;
 }
 
 /*
@@ -568,7 +568,7 @@ static int socket_resume(struct pcmcia_socket *skt)
 	}
 
 	ret = socket_setup(skt, resume_delay);
-	if (ret == CS_SUCCESS) {
+	if (ret == 0) {
 		/*
 		 * FIXME: need a better check here for cardbus cards.
 		 */
@@ -593,7 +593,7 @@ static int socket_resume(struct pcmcia_socket *skt)
 
 	skt->state &= ~SOCKET_SUSPEND;
 
-	return CS_SUCCESS;
+	return 0;
 }
 
 static void socket_remove(struct pcmcia_socket *skt)
@@ -778,14 +778,14 @@ int pccard_reset_card(struct pcmcia_socket *skt)
 			send_event(skt, CS_EVENT_RESET_PHYSICAL, CS_EVENT_PRI_LOW);
 			if (skt->callback)
 				skt->callback->suspend(skt);
-			if (socket_reset(skt) == CS_SUCCESS) {
+			if (socket_reset(skt) == 0) {
 				send_event(skt, CS_EVENT_CARD_RESET, CS_EVENT_PRI_LOW);
 				if (skt->callback)
 					skt->callback->resume(skt);
 			}
 		}
 
-		ret = CS_SUCCESS;
+		ret = 0;
 	} while (0);
 	mutex_unlock(&skt->skt_mutex);
 
diff --git a/drivers/pcmcia/ds.c b/drivers/pcmcia/ds.c
index 5f08915..1cff8f6 100644
--- a/drivers/pcmcia/ds.c
+++ b/drivers/pcmcia/ds.c
@@ -187,7 +187,7 @@ static int pcmcia_report_error(struct pcmcia_device *p_dev, error_info_t *err)
 	else
 		printk("%s: Unknown error code %#x\n", serv, err->retcode);
 
-	return CS_SUCCESS;
+	return 0;
 } /* report_error */
 
 /* end of code which was in cs.c before */
diff --git a/drivers/pcmcia/ds_internal.h b/drivers/pcmcia/ds_internal.h
index 3a2b25e..fc1d3dd 100644
--- a/drivers/pcmcia/ds_internal.h
+++ b/drivers/pcmcia/ds_internal.h
@@ -19,5 +19,5 @@ extern int handle_request(struct pcmcia_socket *s, event_t event);
 static inline void __init pcmcia_setup_ioctl(void) { return; }
 static inline void __exit pcmcia_cleanup_ioctl(void) { return; }
 static inline void handle_event(struct pcmcia_socket *s, event_t event) { return; }
-static inline int handle_request(struct pcmcia_socket *s, event_t event) { return CS_SUCCESS; }
+static inline int handle_request(struct pcmcia_socket *s, event_t event) { return 0; }
 #endif
diff --git a/drivers/pcmcia/pcmcia_ioctl.c b/drivers/pcmcia/pcmcia_ioctl.c
index 0717f73..5c8e4d3 100644
--- a/drivers/pcmcia/pcmcia_ioctl.c
+++ b/drivers/pcmcia/pcmcia_ioctl.c
@@ -167,7 +167,7 @@ static int adjust_irq(struct pcmcia_socket *s, adjust_t *adj)
 #else
 
 static inline int adjust_irq(struct pcmcia_socket *s, adjust_t *adj) {
-	return CS_SUCCESS;
+	return 0;
 }
 
 #endif
@@ -274,7 +274,7 @@ static int pccard_get_status(struct pcmcia_socket *s,
 			status->CardState |=
 				(reg & ESR_REQ_ATTN) ? CS_EVENT_REQUEST_ATTENTION : 0;
 		}
-		return CS_SUCCESS;
+		return 0;
 	}
 	status->CardState |=
 		(val & SS_WRPROT) ? CS_EVENT_WRITE_PROTECT : 0;
@@ -284,7 +284,7 @@ static int pccard_get_status(struct pcmcia_socket *s,
 		(val & SS_BATWARN) ? CS_EVENT_BATTERY_LOW : 0;
 	status->CardState |=
 		(val & SS_READY) ? CS_EVENT_READY_CHANGE : 0;
-	return CS_SUCCESS;
+	return 0;
 } /* pccard_get_status */
 
 int pccard_get_configuration_info(struct pcmcia_socket *s,
@@ -314,7 +314,7 @@ int pccard_get_configuration_info(struct pcmcia_socket *s,
 				config->NumPorts1 = s->io[0].res->end - config->BasePort1 + 1;
 			}
 		}
-		return CS_SUCCESS;
+		return 0;
 	}
 #endif
 
@@ -330,7 +330,7 @@ int pccard_get_configuration_info(struct pcmcia_socket *s,
 		config->Attributes = 0;
 		config->Vcc = s->socket.Vcc;
 		config->Vpp1 = config->Vpp2 = s->socket.Vpp;
-		return CS_SUCCESS;
+		return 0;
 	}
 
 	config->Attributes = c->Attributes | CONF_VALID_CLIENT;
@@ -354,7 +354,7 @@ int pccard_get_configuration_info(struct pcmcia_socket *s,
 	config->Attributes2 = c->io.Attributes2;
 	config->IOAddrLines = c->io.IOAddrLines;
 
-	return CS_SUCCESS;
+	return 0;
 } /* pccard_get_configuration_info */
 
 
@@ -960,7 +960,7 @@ static int ds_ioctl(struct inode * inode, struct file * file,
 	err = -EINVAL;
     }
 
-    if ((err == 0) && (ret != CS_SUCCESS)) {
+    if ((err == 0) && (ret != 0)) {
 	ds_dbg(2, "ds_ioctl: ret = %d\n", ret);
 	switch (ret) {
 	case CS_BAD_SOCKET: case CS_NO_CARD:
diff --git a/drivers/pcmcia/pcmcia_resource.c b/drivers/pcmcia/pcmcia_resource.c
index 35c5759..78a81e8 100644
--- a/drivers/pcmcia/pcmcia_resource.c
+++ b/drivers/pcmcia/pcmcia_resource.c
@@ -192,7 +192,7 @@ int pcmcia_access_configuration_register(struct pcmcia_device *p_dev,
 		return CS_BAD_ARGS;
 		break;
 	}
-	return CS_SUCCESS;
+	return 0;
 } /* pcmcia_access_configuration_register */
 EXPORT_SYMBOL(pcmcia_access_configuration_register);
 
@@ -226,7 +226,7 @@ int pcmcia_get_window(struct pcmcia_socket *s, window_handle_t *handle,
 	if (win->ctl.flags & MAP_USE_WAIT)
 		req->Attributes |= WIN_USE_WAIT;
 	*handle = win;
-	return CS_SUCCESS;
+	return 0;
 } /* pcmcia_get_window */
 EXPORT_SYMBOL(pcmcia_get_window);
 
@@ -241,7 +241,7 @@ int pcmcia_get_mem_page(window_handle_t win, memreq_t *req)
 		return CS_BAD_HANDLE;
 	req->Page = 0;
 	req->CardOffset = win->ctl.card_start;
-	return CS_SUCCESS;
+	return 0;
 } /* pcmcia_get_mem_page */
 EXPORT_SYMBOL(pcmcia_get_mem_page);
 
@@ -257,7 +257,7 @@ int pcmcia_map_mem_page(window_handle_t win, memreq_t *req)
 	win->ctl.card_start = req->CardOffset;
 	if (s->ops->set_mem_map(s, &win->ctl) != 0)
 		return CS_BAD_OFFSET;
-	return CS_SUCCESS;
+	return 0;
 } /* pcmcia_map_mem_page */
 EXPORT_SYMBOL(pcmcia_map_mem_page);
 
@@ -328,7 +328,7 @@ int pcmcia_modify_configuration(struct pcmcia_device *p_dev,
 		}
 	}
 
-	return CS_SUCCESS;
+	return 0;
 } /* modify_configuration */
 EXPORT_SYMBOL(pcmcia_modify_configuration);
 
@@ -363,7 +363,7 @@ int pcmcia_release_configuration(struct pcmcia_device *p_dev)
 			}
 	}
 
-	return CS_SUCCESS;
+	return 0;
 } /* pcmcia_release_configuration */
 
 
@@ -397,7 +397,7 @@ static int pcmcia_release_io(struct pcmcia_device *p_dev, io_req_t *req)
 	if (req->NumPorts2)
 		release_io_space(s, req->BasePort2, req->NumPorts2);
 
-	return CS_SUCCESS;
+	return 0;
 } /* pcmcia_release_io */
 
 
@@ -429,7 +429,7 @@ static int pcmcia_release_irq(struct pcmcia_device *p_dev, irq_req_t *req)
 	pcmcia_used_irq[req->AssignedIRQ]--;
 #endif
 
-	return CS_SUCCESS;
+	return 0;
 } /* pcmcia_release_irq */
 
 
@@ -458,7 +458,7 @@ int pcmcia_release_window(window_handle_t win)
 
 	win->magic = 0;
 
-	return CS_SUCCESS;
+	return 0;
 } /* pcmcia_release_window */
 EXPORT_SYMBOL(pcmcia_release_window);
 
@@ -573,7 +573,7 @@ int pcmcia_request_configuration(struct pcmcia_device *p_dev,
 
 	c->state |= CONFIG_LOCKED;
 	p_dev->_locked = 1;
-	return CS_SUCCESS;
+	return 0;
 } /* pcmcia_request_configuration */
 EXPORT_SYMBOL(pcmcia_request_configuration);
 
@@ -619,7 +619,7 @@ int pcmcia_request_io(struct pcmcia_device *p_dev, io_req_t *req)
 	c->io = *req;
 	c->state |= CONFIG_IO_REQ;
 	p_dev->_io = 1;
-	return CS_SUCCESS;
+	return 0;
 } /* pcmcia_request_io */
 EXPORT_SYMBOL(pcmcia_request_io);
 
@@ -738,7 +738,7 @@ int pcmcia_request_irq(struct pcmcia_device *p_dev, irq_req_t *req)
 	pcmcia_used_irq[irq]++;
 #endif
 
-	return CS_SUCCESS;
+	return 0;
 } /* pcmcia_request_irq */
 EXPORT_SYMBOL(pcmcia_request_irq);
 
@@ -819,7 +819,7 @@ int pcmcia_request_window(struct pcmcia_device **p_dev, win_req_t *req, window_h
 	}
 	*wh = win;
 
-	return CS_SUCCESS;
+	return 0;
 } /* pcmcia_request_window */
 EXPORT_SYMBOL(pcmcia_request_window);
 
diff --git a/drivers/pcmcia/rsrc_nonstatic.c b/drivers/pcmcia/rsrc_nonstatic.c
index 46da1b3..6b417e1 100644
--- a/drivers/pcmcia/rsrc_nonstatic.c
+++ b/drivers/pcmcia/rsrc_nonstatic.c
@@ -134,7 +134,7 @@ static int add_interval(struct resource_map *map, u_long base, u_long num)
     if (!q) return CS_OUT_OF_RESOURCE;
     q->base = base; q->num = num;
     q->next = p->next; p->next = q;
-    return CS_SUCCESS;
+    return 0;
 }
 
 /*====================================================================*/
@@ -174,7 +174,7 @@ static int sub_interval(struct resource_map *map, u_long base, u_long num)
 	    }
 	}
     }
-    return CS_SUCCESS;
+    return 0;
 }
 
 /*======================================================================
diff --git a/drivers/serial/serial_cs.c b/drivers/serial/serial_cs.c
index 4fed877..17fbff5 100644
--- a/drivers/serial/serial_cs.c
+++ b/drivers/serial/serial_cs.c
@@ -431,10 +431,10 @@ first_tuple(struct pcmcia_device *handle, tuple_t * tuple, cisparse_t * parse)
 {
 	int i;
 	i = pcmcia_get_first_tuple(handle, tuple);
-	if (i != CS_SUCCESS)
+	if (i != 0)
 		return CS_NO_MORE_ITEMS;
 	i = pcmcia_get_tuple_data(handle, tuple);
-	if (i != CS_SUCCESS)
+	if (i != 0)
 		return i;
 	return pcmcia_parse_tuple(handle, tuple, parse);
 }
@@ -527,7 +527,7 @@ static int simple_config(struct pcmcia_device *link)
 
 found_port:
 	i = pcmcia_request_irq(link, &link->irq);
-	if (i != CS_SUCCESS) {
+	if (i != 0) {
 		cs_error(link, RequestIRQ, i);
 		link->irq.AssignedIRQ = 0;
 	}
@@ -541,7 +541,7 @@ found_port:
 		info->quirk->config(link);
 
 	i = pcmcia_request_configuration(link, &link->conf);
-	if (i != CS_SUCCESS) {
+	if (i != 0) {
 		cs_error(link, RequestConfiguration, i);
 		return -1;
 	}
@@ -609,7 +609,7 @@ static int multi_config(struct pcmcia_device * link)
 	}
 
 	i = pcmcia_request_irq(link, &link->irq);
-	if (i != CS_SUCCESS) {
+	if (i != 0) {
 		/* FIXME: comment does not fit, error handling does not fit */
 		printk(KERN_NOTICE
 		       "serial_cs: no usable port range found, giving up\n");
@@ -624,7 +624,7 @@ static int multi_config(struct pcmcia_device * link)
 		info->quirk->config(link);
 
 	i = pcmcia_request_configuration(link, &link->conf);
-	if (i != CS_SUCCESS) {
+	if (i != 0) {
 		cs_error(link, RequestConfiguration, i);
 		return -ENODEV;
 	}
@@ -702,7 +702,7 @@ static int serial_config(struct pcmcia_device * link)
 	/* Is this a compliant multifunction card? */
 	tuple->DesiredTuple = CISTPL_LONGLINK_MFC;
 	tuple->Attributes = TUPLE_RETURN_COMMON | TUPLE_RETURN_LINK;
-	info->multi = (first_tuple(link, tuple, parse) == CS_SUCCESS);
+	info->multi = (first_tuple(link, tuple, parse) == 0);
 
 	/* Is this a multiport card? */
 	tuple->DesiredTuple = CISTPL_MANFID;
@@ -726,7 +726,7 @@ static int serial_config(struct pcmcia_device * link)
 	    ((link->func_id == CISTPL_FUNCID_MULTI) ||
 	     (link->func_id == CISTPL_FUNCID_SERIAL))) {
 		tuple->DesiredTuple = CISTPL_CFTABLE_ENTRY;
-		if (first_tuple(link, tuple, parse) == CS_SUCCESS) {
+		if (first_tuple(link, tuple, parse) == 0) {
 			if ((cf->io.nwin == 1) && (cf->io.win[0].len % 8 == 0))
 				info->multi = cf->io.win[0].len >> 3;
 			if ((cf->io.nwin == 2) && (cf->io.win[0].len == 8) &&
diff --git a/drivers/ssb/pcmcia.c b/drivers/ssb/pcmcia.c
index 24c2a46..9699308 100644
--- a/drivers/ssb/pcmcia.c
+++ b/drivers/ssb/pcmcia.c
@@ -80,7 +80,7 @@ static int ssb_pcmcia_cfg_write(struct ssb_bus *bus, u8 offset, u8 value)
 	reg.Action = CS_WRITE;
 	reg.Value = value;
 	res = pcmcia_access_configuration_register(bus->host_pcmcia, &reg);
-	if (unlikely(res != CS_SUCCESS))
+	if (unlikely(res != 0))
 		return -EBUSY;
 
 	return 0;
@@ -96,7 +96,7 @@ static int ssb_pcmcia_cfg_read(struct ssb_bus *bus, u8 offset, u8 *value)
 	reg.Offset = offset;
 	reg.Action = CS_READ;
 	res = pcmcia_access_configuration_register(bus->host_pcmcia, &reg);
-	if (unlikely(res != CS_SUCCESS))
+	if (unlikely(res != 0))
 		return -EBUSY;
 	*value = reg.Value;
 
@@ -638,17 +638,17 @@ int ssb_pcmcia_get_invariants(struct ssb_bus *bus,
 	tuple.TupleData = buf;
 	tuple.TupleDataMax = sizeof(buf);
 	res = pcmcia_get_first_tuple(bus->host_pcmcia, &tuple);
-	GOTO_ERROR_ON(res != CS_SUCCESS, "MAC first tpl");
+	GOTO_ERROR_ON(res != 0, "MAC first tpl");
 	res = pcmcia_get_tuple_data(bus->host_pcmcia, &tuple);
-	GOTO_ERROR_ON(res != CS_SUCCESS, "MAC first tpl data");
+	GOTO_ERROR_ON(res != 0, "MAC first tpl data");
 	while (1) {
 		GOTO_ERROR_ON(tuple.TupleDataLen < 1, "MAC tpl < 1");
 		if (tuple.TupleData[0] == CISTPL_FUNCE_LAN_NODE_ID)
 			break;
 		res = pcmcia_get_next_tuple(bus->host_pcmcia, &tuple);
-		GOTO_ERROR_ON(res != CS_SUCCESS, "MAC next tpl");
+		GOTO_ERROR_ON(res != 0, "MAC next tpl");
 		res = pcmcia_get_tuple_data(bus->host_pcmcia, &tuple);
-		GOTO_ERROR_ON(res != CS_SUCCESS, "MAC next tpl data");
+		GOTO_ERROR_ON(res != 0, "MAC next tpl data");
 	}
 	GOTO_ERROR_ON(tuple.TupleDataLen != ETH_ALEN + 2, "MAC tpl size");
 	memcpy(sprom->il0mac, &tuple.TupleData[2], ETH_ALEN);
@@ -659,9 +659,9 @@ int ssb_pcmcia_get_invariants(struct ssb_bus *bus,
 	tuple.TupleData = buf;
 	tuple.TupleDataMax = sizeof(buf);
 	res = pcmcia_get_first_tuple(bus->host_pcmcia, &tuple);
-	GOTO_ERROR_ON(res != CS_SUCCESS, "VEN first tpl");
+	GOTO_ERROR_ON(res != 0, "VEN first tpl");
 	res = pcmcia_get_tuple_data(bus->host_pcmcia, &tuple);
-	GOTO_ERROR_ON(res != CS_SUCCESS, "VEN first tpl data");
+	GOTO_ERROR_ON(res != 0, "VEN first tpl data");
 	while (1) {
 		GOTO_ERROR_ON(tuple.TupleDataLen < 1, "VEN tpl < 1");
 		switch (tuple.TupleData[0]) {
@@ -735,9 +735,9 @@ int ssb_pcmcia_get_invariants(struct ssb_bus *bus,
 		res = pcmcia_get_next_tuple(bus->host_pcmcia, &tuple);
 		if (res == CS_NO_MORE_ITEMS)
 			break;
-		GOTO_ERROR_ON(res != CS_SUCCESS, "VEN next tpl");
+		GOTO_ERROR_ON(res != 0, "VEN next tpl");
 		res = pcmcia_get_tuple_data(bus->host_pcmcia, &tuple);
-		GOTO_ERROR_ON(res != CS_SUCCESS, "VEN next tpl data");
+		GOTO_ERROR_ON(res != 0, "VEN next tpl data");
 	}
 
 	return 0;
-- 
1.5.4.3

