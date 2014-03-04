From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH net-next] chelsio: Use more current logging style
Date: Tue, 04 Mar 2014 11:36:45 -0800
Message-ID: <1393961805.20435.49.camel@joe-AO722>
References: <1393936917-25847-1-git-send-email-hariprasad@chelsio.com>
	 <1393936917-25847-4-git-send-email-hariprasad@chelsio.com>
	 <1393955035.20435.40.camel@joe-AO722> <531635F4.9050208@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	santosh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
To: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <531635F4.9050208-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-03-04 at 23:22 +0300, Sergei Shtylyov wrote:
> On 03/04/2014 08:43 PM, Joe Perches wrote:
> >> From: Kumar Sanghvi <kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
> >> +		CH_WARN(adap, "SGE idma%u, queue%u, maybe stuck state%u %dsecs"
> >> +			" (debug0=%#x, debug11=%#x)\n",
> > Probably better with the format coalesced:
> > 		CH_WARN(adap, "SGE idma%u, queue%u, maybe stuck state%u %dsecs (debug0=%#x, debug11=%#x)\n",
>     Surely better, as otherwise it shouldn't pass scripts/checkpatch.pl.

It'd complain in any case as CH_<LEVEL> macros are 
uppercase and checkpatch doesn't know that those are
logging uses.

Maybe renaming all the CH_<LEVEL> macros to lower
case like this would help.

This also can now use dynamic_debug for the ch_dbg
statements and removes the CH_MSG function as it's
unused.

From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>

Use more standard style lower case logging macros.

Coalesce formats
Remove unnecessary periods
Enable dynamic debugging and verify debug format/arguments

Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/ethernet/chelsio/cxgb3/adapter.h    |  4 +-
 drivers/net/ethernet/chelsio/cxgb3/ael1002.c    |  2 +-
 drivers/net/ethernet/chelsio/cxgb3/aq100x.c     | 16 +++----
 drivers/net/ethernet/chelsio/cxgb3/common.h     | 29 ++++++-------
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c | 20 ++++-----
 drivers/net/ethernet/chelsio/cxgb3/mc5.c        | 13 +++---
 drivers/net/ethernet/chelsio/cxgb3/sge.c        | 18 ++++----
 drivers/net/ethernet/chelsio/cxgb3/t3_hw.c      | 58 ++++++++++++-------------
 drivers/net/ethernet/chelsio/cxgb3/xgmac.c      |  5 +--
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |  2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |  2 +-
 11 files changed, 82 insertions(+), 87 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb3/adapter.h b/drivers/net/ethernet/chelsio/cxgb3/adapter.h
index 8b395b5..8d30234 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/adapter.h
+++ b/drivers/net/ethernet/chelsio/cxgb3/adapter.h
@@ -272,13 +272,13 @@ static inline u32 t3_read_reg(struct adapter *adapter, u32 reg_addr)
 {
 	u32 val = readl(adapter->regs + reg_addr);
 
-	CH_DBG(adapter, MMIO, "read register 0x%x value 0x%x\n", reg_addr, val);
+	ch_dbg(adapter, MMIO, "read register 0x%x value 0x%x\n", reg_addr, val);
 	return val;
 }
 
 static inline void t3_write_reg(struct adapter *adapter, u32 reg_addr, u32 val)
 {
-	CH_DBG(adapter, MMIO, "setting register 0x%x to 0x%x\n", reg_addr, val);
+	ch_dbg(adapter, MMIO, "setting register 0x%x to 0x%x\n", reg_addr, val);
 	writel(val, adapter->regs + reg_addr);
 }
 
diff --git a/drivers/net/ethernet/chelsio/cxgb3/ael1002.c b/drivers/net/ethernet/chelsio/cxgb3/ael1002.c
index 2028da9..4a3d586 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/ael1002.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/ael1002.c
@@ -133,7 +133,7 @@ static int ael_i2c_rd(struct cphy *phy, int dev_addr, int word_addr)
 			return data >> 8;
 		}
 	}
-	CH_WARN(phy->adapter, "PHY %u i2c read of dev.addr %#x.%#x timed out\n",
+	ch_warn(phy->adapter, "PHY %u i2c read of dev.addr %#x.%#x timed out\n",
 		phy->mdio.prtad, dev_addr, word_addr);
 	return -ETIMEDOUT;
 }
diff --git a/drivers/net/ethernet/chelsio/cxgb3/aq100x.c b/drivers/net/ethernet/chelsio/cxgb3/aq100x.c
index 341b7ef..27c0512 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/aq100x.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/aq100x.c
@@ -71,7 +71,7 @@ static int aq100x_reset(struct cphy *phy, int wait)
 	int err = t3_phy_reset(phy, MDIO_MMD_VEND1, 3000);
 
 	if (err)
-		CH_WARN(phy->adapter, "PHY%d: reset failed (0x%x).\n",
+		ch_warn(phy->adapter, "PHY%d: reset failed (0x%x)\n",
 			phy->mdio.prtad, err);
 
 	return err;
@@ -294,7 +294,7 @@ int t3_aq100x_phy_prep(struct cphy *phy, struct adapter *adapter, int phy_addr,
 
 			/* Allow prep_adapter to succeed when ffff is read */
 
-			CH_WARN(adapter, "PHY%d: reset failed (0x%x, 0x%x).\n",
+			ch_warn(adapter, "PHY%d: reset failed (0x%x, 0x%x)\n",
 				phy_addr, err, v);
 			goto done;
 		}
@@ -304,7 +304,7 @@ int t3_aq100x_phy_prep(struct cphy *phy, struct adapter *adapter, int phy_addr,
 			msleep(10);
 	} while (v && --wait);
 	if (v) {
-		CH_WARN(adapter, "PHY%d: reset timed out (0x%x).\n",
+		ch_warn(adapter, "PHY%d: reset timed out (0x%x)\n",
 			phy_addr, v);
 
 		goto done; /* let prep_adapter succeed */
@@ -313,12 +313,12 @@ int t3_aq100x_phy_prep(struct cphy *phy, struct adapter *adapter, int phy_addr,
 	/* Datasheet says 3s max but this has been observed */
 	wait = (500 - wait) * 10 + 1000;
 	if (wait > 3000)
-		CH_WARN(adapter, "PHY%d: reset took %ums\n", phy_addr, wait);
+		ch_warn(adapter, "PHY%d: reset took %ums\n", phy_addr, wait);
 
 	/* Firmware version check. */
 	t3_mdio_read(phy, MDIO_MMD_VEND1, AQ_FW_VERSION, &v);
 	if (v != 101)
-		CH_WARN(adapter, "PHY%d: unsupported firmware %d\n",
+		ch_warn(adapter, "PHY%d: unsupported firmware %d\n",
 			phy_addr, v);
 
 	/*
@@ -335,7 +335,7 @@ int t3_aq100x_phy_prep(struct cphy *phy, struct adapter *adapter, int phy_addr,
 			return err;
 		msleep(10);
 	} else
-		CH_WARN(adapter, "PHY%d does not start in low power mode.\n",
+		ch_warn(adapter, "PHY%d does not start in low power mode\n",
 			phy_addr);
 
 	/*
@@ -345,8 +345,8 @@ int t3_aq100x_phy_prep(struct cphy *phy, struct adapter *adapter, int phy_addr,
 	t3_mdio_read(phy, MDIO_MMD_PHYXS, AQ_XAUI_RX_CFG, &v);
 	t3_mdio_read(phy, MDIO_MMD_PHYXS, AQ_XAUI_TX_CFG, &v2);
 	if (v != 0x1b || v2 != 0x1b)
-		CH_WARN(adapter,
-			"PHY%d: incorrect XAUI settings (0x%x, 0x%x).\n",
+		ch_warn(adapter,
+			"PHY%d: incorrect XAUI settings (0x%x, 0x%x)\n",
 			phy_addr, v, v2);
 
 done:
diff --git a/drivers/net/ethernet/chelsio/cxgb3/common.h b/drivers/net/ethernet/chelsio/cxgb3/common.h
index 4424809..59586ee 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/common.h
+++ b/drivers/net/ethernet/chelsio/cxgb3/common.h
@@ -41,25 +41,22 @@
 #include <linux/mdio.h>
 #include "version.h"
 
-#define CH_ERR(adap, fmt, ...)   dev_err(&adap->pdev->dev, fmt, ##__VA_ARGS__)
-#define CH_WARN(adap, fmt, ...)  dev_warn(&adap->pdev->dev, fmt, ##__VA_ARGS__)
-#define CH_ALERT(adap, fmt, ...) dev_alert(&adap->pdev->dev, fmt, ##__VA_ARGS__)
-
-/*
- * More powerful macro that selectively prints messages based on msg_enable.
- * For info and debugging messages.
- */
-#define CH_MSG(adapter, level, category, fmt, ...) do { \
-	if ((adapter)->msg_enable & NETIF_MSG_##category) \
-		dev_printk(KERN_##level, &adapter->pdev->dev, fmt, \
-			   ## __VA_ARGS__); \
-} while (0)
+#define ch_err(adap, fmt, ...)   dev_err(&adap->pdev->dev, fmt, ##__VA_ARGS__)
+#define ch_warn(adap, fmt, ...)  dev_warn(&adap->pdev->dev, fmt, ##__VA_ARGS__)
+#define ch_alert(adap, fmt, ...) dev_alert(&adap->pdev->dev, fmt, ##__VA_ARGS__)
 
 #ifdef DEBUG
-# define CH_DBG(adapter, category, fmt, ...) \
-	CH_MSG(adapter, DEBUG, category, fmt, ## __VA_ARGS__)
+#define ch_dbg(adapter, category, fmt, ...)				\
+do {									\
+	if ((adapter)->msg_enable & NETIF_MSG_##category)		\
+		dev_dbg(&adapter->pdev->dev, fmt, ##__VA_ARGS__);	\
+} while (0)
 #else
-# define CH_DBG(adapter, category, fmt, ...)
+#define ch_dbg(adapter, category, fmt, ...)				\
+do {									\
+	if (0)								\
+		dev_dbg(&adapter->pdev->dev, fmt, ##__VA_ARGS__);	\
+} while (0)
 #endif
 
 /* Additional NETIF_MSG_* categories */
diff --git a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
index 07bbb71..c094011 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
@@ -1043,7 +1043,7 @@ int t3_get_edc_fw(struct cphy *phy, int edc_idx, int size)
 
 	/* check size, take checksum in account */
 	if (fw->size > size + 4) {
-		CH_ERR(adapter, "firmware image too large %u, expected %d\n",
+		ch_err(adapter, "firmware image too large %u, expected %d\n",
 		       (unsigned int)fw->size, size + 4);
 		ret = -EINVAL;
 	}
@@ -1054,7 +1054,7 @@ int t3_get_edc_fw(struct cphy *phy, int edc_idx, int size)
 		csum += ntohl(p[i]);
 
 	if (csum != 0xffffffff) {
-		CH_ERR(adapter, "corrupted firmware image, checksum %u\n",
+		ch_err(adapter, "corrupted firmware image, checksum %u\n",
 		       csum);
 		ret = -EINVAL;
 	}
@@ -1214,7 +1214,7 @@ static int cxgb_up(struct adapter *adap)
 		err = t3_check_fw_version(adap);
 		if (err == -EINVAL) {
 			err = upgrade_fw(adap);
-			CH_WARN(adap, "FW upgrade to %d.%d.%d %s\n",
+			ch_warn(adap, "FW upgrade to %d.%d.%d %s\n",
 				FW_VERSION_MAJOR, FW_VERSION_MINOR,
 				FW_VERSION_MICRO, err ? "failed" : "succeeded");
 		}
@@ -1222,7 +1222,7 @@ static int cxgb_up(struct adapter *adap)
 		err = t3_check_tpsram_version(adap);
 		if (err == -EINVAL) {
 			err = update_tpsram(adap);
-			CH_WARN(adap, "TP upgrade to %d.%d.%d %s\n",
+			ch_warn(adap, "TP upgrade to %d.%d.%d %s\n",
 				TP_VERSION_MAJOR, TP_VERSION_MINOR,
 				TP_VERSION_MICRO, err ? "failed" : "succeeded");
 		}
@@ -1298,7 +1298,7 @@ static int cxgb_up(struct adapter *adap)
 		int ret = bind_qsets(adap);
 
 		if (ret < 0) {
-			CH_ERR(adap, "failed to bind qsets, err %d\n", ret);
+			ch_err(adap, "failed to bind qsets, err %d\n", ret);
 			t3_intr_disable(adap);
 			free_irq_resources(adap);
 			err = ret;
@@ -1310,7 +1310,7 @@ static int cxgb_up(struct adapter *adap)
 out:
 	return err;
 irq_err:
-	CH_ERR(adap, "request_irq failed, err %d\n", err);
+	ch_err(adap, "request_irq failed, err %d\n", err);
 	goto out;
 }
 
@@ -2958,7 +2958,7 @@ static void fatal_error_task(struct work_struct *work)
 	if (!err)
 		t3_resume_ports(adapter);
 
-	CH_ALERT(adapter, "adapter reset %s\n", err ? "failed" : "succeeded");
+	ch_alert(adapter, "adapter reset %s\n", err ? "failed" : "succeeded");
 	rtnl_unlock();
 }
 
@@ -2978,9 +2978,9 @@ void t3_fatal_err(struct adapter *adapter)
 		queue_work(cxgb3_wq, &adapter->fatal_error_handler_task);
 		spin_unlock(&adapter->work_lock);
 	}
-	CH_ALERT(adapter, "encountered fatal error, operation suspended\n");
+	ch_alert(adapter, "encountered fatal error, operation suspended\n");
 	if (!t3_cim_ctl_blk_read(adapter, 0xa0, 4, fw_status))
-		CH_ALERT(adapter, "FW status: 0x%x, 0x%x, 0x%x, 0x%x\n",
+		ch_alert(adapter, "FW status: 0x%x, 0x%x, 0x%x, 0x%x\n",
 			 fw_status[0], fw_status[1],
 			 fw_status[2], fw_status[3]);
 }
@@ -3034,7 +3034,7 @@ static void t3_io_resume(struct pci_dev *pdev)
 {
 	struct adapter *adapter = pci_get_drvdata(pdev);
 
-	CH_ALERT(adapter, "adapter recovering, PEX ERR 0x%x\n",
+	ch_alert(adapter, "adapter recovering, PEX ERR 0x%x\n",
 		 t3_read_reg(adapter, A_PCIE_PEX_ERR));
 
 	rtnl_lock();
diff --git a/drivers/net/ethernet/chelsio/cxgb3/mc5.c b/drivers/net/ethernet/chelsio/cxgb3/mc5.c
index e13b7fe..3d8080d 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/mc5.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/mc5.c
@@ -131,8 +131,7 @@ static int mc5_write(struct adapter *adapter, u32 addr_lo, u32 cmd)
 	t3_write_reg(adapter, A_MC5_DB_DBGI_REQ_ADDR0, addr_lo);
 	if (mc5_cmd_write(adapter, cmd) == 0)
 		return 0;
-	CH_ERR(adapter, "MC5 timeout writing to TCAM address 0x%x\n",
-	       addr_lo);
+	ch_err(adapter, "MC5 timeout writing to TCAM address 0x%x\n", addr_lo);
 	return -1;
 }
 
@@ -339,7 +338,7 @@ int t3_mc5_init(struct mc5 *mc5, unsigned int nservers, unsigned int nfilters,
 	cfg |= V_TMMODE(mc5->mode == MC5_MODE_72_BIT) | F_TMRST;
 	t3_write_reg(adap, A_MC5_DB_CONFIG, cfg);
 	if (t3_wait_op_done(adap, A_MC5_DB_CONFIG, F_TMRDY, 1, 500, 0)) {
-		CH_ERR(adap, "TCAM reset timed out\n");
+		ch_err(adap, "TCAM reset timed out\n");
 		return -1;
 	}
 
@@ -365,7 +364,7 @@ int t3_mc5_init(struct mc5 *mc5, unsigned int nservers, unsigned int nfilters,
 		err = init_idt43102(mc5);
 		break;
 	default:
-		CH_ERR(adap, "Unsupported TCAM type %d\n", mc5->part_type);
+		ch_err(adap, "Unsupported TCAM type %d\n", mc5->part_type);
 		err = -EINVAL;
 		break;
 	}
@@ -386,17 +385,17 @@ void t3_mc5_intr_handler(struct mc5 *mc5)
 	u32 cause = t3_read_reg(adap, A_MC5_DB_INT_CAUSE);
 
 	if ((cause & F_PARITYERR) && mc5->parity_enabled) {
-		CH_ALERT(adap, "MC5 parity error\n");
+		ch_alert(adap, "MC5 parity error\n");
 		mc5->stats.parity_err++;
 	}
 
 	if (cause & F_REQQPARERR) {
-		CH_ALERT(adap, "MC5 request queue parity error\n");
+		ch_alert(adap, "MC5 request queue parity error\n");
 		mc5->stats.reqq_parity_err++;
 	}
 
 	if (cause & F_DISPQPARERR) {
-		CH_ALERT(adap, "MC5 dispatch queue parity error\n");
+		ch_alert(adap, "MC5 dispatch queue parity error\n");
 		mc5->stats.dispq_parity_err++;
 	}
 
diff --git a/drivers/net/ethernet/chelsio/cxgb3/sge.c b/drivers/net/ethernet/chelsio/cxgb3/sge.c
index 632b318..bfbad4b 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/sge.c
@@ -2804,21 +2804,21 @@ void t3_sge_err_intr_handler(struct adapter *adapter)
 				 ~F_FLEMPTY;
 
 	if (status & SGE_PARERR)
-		CH_ALERT(adapter, "SGE parity error (0x%x)\n",
+		ch_alert(adapter, "SGE parity error (0x%x)\n",
 			 status & SGE_PARERR);
 	if (status & SGE_FRAMINGERR)
-		CH_ALERT(adapter, "SGE framing error (0x%x)\n",
+		ch_alert(adapter, "SGE framing error (0x%x)\n",
 			 status & SGE_FRAMINGERR);
 
 	if (status & F_RSPQCREDITOVERFOW)
-		CH_ALERT(adapter, "SGE response queue credit overflow\n");
+		ch_alert(adapter, "SGE response queue credit overflow\n");
 
 	if (status & F_RSPQDISABLED) {
 		v = t3_read_reg(adapter, A_SG_RSPQ_FL_STATUS);
 
-		CH_ALERT(adapter,
-			 "packet delivered to disabled response queue "
-			 "(0x%x)\n", (v >> S_RSPQ0DISABLED) & 0xff);
+		ch_alert(adapter,
+			 "packet delivered to disabled response queue (0x%x)\n",
+			 (v >> S_RSPQ0DISABLED) & 0xff);
 	}
 
 	if (status & (F_HIPIODRBDROPERR | F_LOPIODRBDROPERR))
@@ -3110,17 +3110,17 @@ int t3_sge_alloc_qset(struct adapter *adapter, unsigned int id, int nports,
 	avail = refill_fl(adapter, &q->fl[0], q->fl[0].size,
 			  GFP_KERNEL | __GFP_COMP);
 	if (!avail) {
-		CH_ALERT(adapter, "free list queue 0 initialization failed\n");
+		ch_alert(adapter, "free list queue 0 initialization failed\n");
 		goto err;
 	}
 	if (avail < q->fl[0].size)
-		CH_WARN(adapter, "free list queue 0 enabled with %d credits\n",
+		ch_warn(adapter, "free list queue 0 enabled with %d credits\n",
 			avail);
 
 	avail = refill_fl(adapter, &q->fl[1], q->fl[1].size,
 			  GFP_KERNEL | __GFP_COMP);
 	if (avail < q->fl[1].size)
-		CH_WARN(adapter, "free list queue 1 enabled with %d credits\n",
+		ch_warn(adapter, "free list queue 1 enabled with %d credits\n",
 			avail);
 	refill_rspq(adapter, &q->rspq, q->rspq.size - 1);
 
diff --git a/drivers/net/ethernet/chelsio/cxgb3/t3_hw.c b/drivers/net/ethernet/chelsio/cxgb3/t3_hw.c
index c74a898..8aace68 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/t3_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/t3_hw.c
@@ -627,7 +627,7 @@ int t3_seeprom_read(struct adapter *adapter, u32 addr, __le32 *data)
 	} while (!(val & PCI_VPD_ADDR_F) && --attempts);
 
 	if (!(val & PCI_VPD_ADDR_F)) {
-		CH_ERR(adapter, "reading EEPROM address 0x%x failed\n", addr);
+		ch_err(adapter, "reading EEPROM address 0x%x failed\n", addr);
 		return -EIO;
 	}
 	pci_read_config_dword(adapter->pdev, base + PCI_VPD_DATA, &v);
@@ -663,7 +663,7 @@ int t3_seeprom_write(struct adapter *adapter, u32 addr, __le32 data)
 	} while ((val & PCI_VPD_ADDR_F) && --attempts);
 
 	if (val & PCI_VPD_ADDR_F) {
-		CH_ERR(adapter, "write to EEPROM address 0x%x failed\n", addr);
+		ch_err(adapter, "write to EEPROM address 0x%x failed\n", addr);
 		return -EIO;
 	}
 	return 0;
@@ -963,8 +963,8 @@ int t3_check_tpsram_version(struct adapter *adapter)
 	if (major == TP_VERSION_MAJOR && minor == TP_VERSION_MINOR)
 		return 0;
 	else {
-		CH_ERR(adapter, "found wrong TP version (%u.%u), "
-		       "driver compiled for version %d.%d\n", major, minor,
+		ch_err(adapter, "found wrong TP version (%u.%u), driver compiled for version %d.%d\n",
+		       major, minor,
 		       TP_VERSION_MAJOR, TP_VERSION_MINOR);
 	}
 	return -EINVAL;
@@ -991,7 +991,7 @@ int t3_check_tpsram(struct adapter *adapter, const u8 *tp_sram,
 	for (csum = 0, i = 0; i < size / sizeof(csum); i++)
 		csum += ntohl(p[i]);
 	if (csum != 0xffffffff) {
-		CH_ERR(adapter, "corrupted protocol SRAM image, checksum %u\n",
+		ch_err(adapter, "corrupted protocol SRAM image, checksum %u\n",
 		       csum);
 		return -EINVAL;
 	}
@@ -1041,12 +1041,12 @@ int t3_check_fw_version(struct adapter *adapter)
 	    minor == FW_VERSION_MINOR)
 		return 0;
 	else if (major != FW_VERSION_MAJOR || minor < FW_VERSION_MINOR)
-		CH_WARN(adapter, "found old FW minor version(%u.%u), "
-		        "driver compiled for version %u.%u\n", major, minor,
+		ch_warn(adapter, "found old FW minor version(%u.%u), driver compiled for version %u.%u\n",
+			major, minor,
 			FW_VERSION_MAJOR, FW_VERSION_MINOR);
 	else {
-		CH_WARN(adapter, "found newer FW version(%u.%u), "
-		        "driver compiled for version %u.%u\n", major, minor,
+		ch_warn(adapter, "found newer FW version(%u.%u), driver compiled for version %u.%u\n",
+			major, minor,
 			FW_VERSION_MAJOR, FW_VERSION_MINOR);
 			return 0;
 	}
@@ -1102,7 +1102,7 @@ int t3_load_fw(struct adapter *adapter, const u8 *fw_data, unsigned int size)
 	for (csum = 0, i = 0; i < size / sizeof(csum); i++)
 		csum += ntohl(p[i]);
 	if (csum != 0xffffffff) {
-		CH_ERR(adapter, "corrupted firmware image, checksum %u\n",
+		ch_err(adapter, "corrupted firmware image, checksum %u\n",
 		       csum);
 		return -EINVAL;
 	}
@@ -1127,7 +1127,7 @@ int t3_load_fw(struct adapter *adapter, const u8 *fw_data, unsigned int size)
 	ret = t3_write_flash(adapter, FW_VERS_ADDR, 4, fw_data);
 out:
 	if (ret)
-		CH_ERR(adapter, "firmware download failed, error %d\n", ret);
+		ch_err(adapter, "firmware download failed, error %d\n", ret);
 	return ret;
 }
 
@@ -1408,11 +1408,11 @@ static int t3_handle_intr_status(struct adapter *adapter, unsigned int reg,
 			continue;
 		if (acts->fatal) {
 			fatal++;
-			CH_ALERT(adapter, "%s (0x%x)\n",
+			ch_alert(adapter, "%s (0x%x)\n",
 				 acts->msg, status & acts->mask);
 			status &= ~acts->mask;
 		} else if (acts->msg)
-			CH_WARN(adapter, "%s (0x%x)\n",
+			ch_warn(adapter, "%s (0x%x)\n",
 				acts->msg, status & acts->mask);
 		if (acts->stat_idx >= 0)
 			stats[acts->stat_idx]++;
@@ -1542,7 +1542,7 @@ static void pcie_intr_handler(struct adapter *adapter)
 	};
 
 	if (t3_read_reg(adapter, A_PCIE_INT_CAUSE) & F_PEXERR)
-		CH_ALERT(adapter, "PEX error code 0x%x\n",
+		ch_alert(adapter, "PEX error code 0x%x\n",
 			 t3_read_reg(adapter, A_PCIE_PEX_ERR));
 
 	if (t3_handle_intr_status(adapter, A_PCIE_INT_CAUSE, PCIE_INTR_MASK,
@@ -1761,8 +1761,8 @@ static void mc7_intr_handler(struct mc7 *mc7)
 
 	if (cause & F_CE) {
 		mc7->stats.corr_err++;
-		CH_WARN(adapter, "%s MC7 correctable error at addr 0x%x, "
-			"data 0x%x 0x%x 0x%x\n", mc7->name,
+		ch_warn(adapter, "%s MC7 correctable error at addr 0x%x, data 0x%x 0x%x 0x%x\n",
+			mc7->name,
 			t3_read_reg(adapter, mc7->offset + A_MC7_CE_ADDR),
 			t3_read_reg(adapter, mc7->offset + A_MC7_CE_DATA0),
 			t3_read_reg(adapter, mc7->offset + A_MC7_CE_DATA1),
@@ -1771,8 +1771,8 @@ static void mc7_intr_handler(struct mc7 *mc7)
 
 	if (cause & F_UE) {
 		mc7->stats.uncorr_err++;
-		CH_ALERT(adapter, "%s MC7 uncorrectable error at addr 0x%x, "
-			 "data 0x%x 0x%x 0x%x\n", mc7->name,
+		ch_alert(adapter, "%s MC7 uncorrectable error at addr 0x%x, data 0x%x 0x%x 0x%x\n",
+			 mc7->name,
 			 t3_read_reg(adapter, mc7->offset + A_MC7_UE_ADDR),
 			 t3_read_reg(adapter, mc7->offset + A_MC7_UE_DATA0),
 			 t3_read_reg(adapter, mc7->offset + A_MC7_UE_DATA1),
@@ -1781,7 +1781,7 @@ static void mc7_intr_handler(struct mc7 *mc7)
 
 	if (G_PE(cause)) {
 		mc7->stats.parity_err++;
-		CH_ALERT(adapter, "%s MC7 parity error 0x%x\n",
+		ch_alert(adapter, "%s MC7 parity error 0x%x\n",
 			 mc7->name, G_PE(cause));
 	}
 
@@ -1792,7 +1792,7 @@ static void mc7_intr_handler(struct mc7 *mc7)
 			addr = t3_read_reg(adapter,
 					   mc7->offset + A_MC7_ERR_ADDR);
 		mc7->stats.addr_err++;
-		CH_ALERT(adapter, "%s MC7 address error: 0x%x\n",
+		ch_alert(adapter, "%s MC7 address error: 0x%x\n",
 			 mc7->name, addr);
 	}
 
@@ -1821,11 +1821,11 @@ static int mac_intr_handler(struct adapter *adap, unsigned int idx)
 
 	if (cause & V_TXFIFO_PRTY_ERR(M_TXFIFO_PRTY_ERR)) {
 		mac->stats.tx_fifo_parity_err++;
-		CH_ALERT(adap, "port%d: MAC TX FIFO parity error\n", idx);
+		ch_alert(adap, "port%d: MAC TX FIFO parity error\n", idx);
 	}
 	if (cause & V_RXFIFO_PRTY_ERR(M_RXFIFO_PRTY_ERR)) {
 		mac->stats.rx_fifo_parity_err++;
-		CH_ALERT(adap, "port%d: MAC RX FIFO parity error\n", idx);
+		ch_alert(adap, "port%d: MAC RX FIFO parity error\n", idx);
 	}
 	if (cause & F_TXFIFO_UNDERRUN)
 		mac->stats.tx_fifo_urun++;
@@ -3048,7 +3048,7 @@ static int tp_init(struct adapter *adap, const struct tp_params *p)
 		busy = t3_wait_op_done(adap, A_TP_RESET, F_FLSTINITENABLE,
 				       0, 1000, 5);
 		if (busy)
-			CH_ERR(adap, "TP initialization timed out\n");
+			ch_err(adap, "TP initialization timed out\n");
 	}
 
 	if (!busy)
@@ -3106,7 +3106,7 @@ static int calibrate_xgm(struct adapter *adapter)
 				return 0;
 			}
 		}
-		CH_ERR(adapter, "MAC calibration failed\n");
+		ch_err(adapter, "MAC calibration failed\n");
 		return -1;
 	} else {
 		t3_write_reg(adapter, A_XGM_RGMII_IMP,
@@ -3153,7 +3153,7 @@ static int wrreg_wait(struct adapter *adapter, unsigned int addr, u32 val)
 	t3_read_reg(adapter, addr);	/* flush */
 	if (!(t3_read_reg(adapter, addr) & F_BUSY))
 		return 0;
-	CH_ERR(adapter, "write to MC7 register 0x%x timed out\n", addr);
+	ch_err(adapter, "write to MC7 register 0x%x timed out\n", addr);
 	return -EIO;
 }
 
@@ -3193,7 +3193,7 @@ static int mc7_init(struct mc7 *mc7, unsigned int mc7_clock, int mem_type)
 		msleep(1);
 		if (t3_read_reg(adapter, mc7->offset + A_MC7_CAL) &
 		    (F_BUSY | F_SGL_CAL_EN | F_CAL_FAULT)) {
-			CH_ERR(adapter, "%s MC7 calibration timed out\n",
+			ch_err(adapter, "%s MC7 calibration timed out\n",
 			       mc7->name);
 			goto out_fail;
 		}
@@ -3258,7 +3258,7 @@ static int mc7_init(struct mc7 *mc7, unsigned int mc7_clock, int mem_type)
 		val = t3_read_reg(adapter, mc7->offset + A_MC7_BIST_OP);
 	} while ((val & F_BUSY) && --attempts);
 	if (val & F_BUSY) {
-		CH_ERR(adapter, "%s MC7 BIST timed out\n", mc7->name);
+		ch_err(adapter, "%s MC7 BIST timed out\n", mc7->name);
 		goto out_fail;
 	}
 
@@ -3401,7 +3401,7 @@ int t3_init_hw(struct adapter *adapter, u32 fw_params)
 		msleep(20);
 	} while (t3_read_reg(adapter, A_CIM_HOST_ACC_DATA) && --attempts);
 	if (!attempts) {
-		CH_ERR(adapter, "uP initialization timed out\n");
+		ch_err(adapter, "uP initialization timed out\n");
 		goto out_err;
 	}
 
@@ -3703,7 +3703,7 @@ int t3_prep_adapter(struct adapter *adapter, const struct adapter_info *ai,
 
 		pti = &port_types[adapter->params.vpd.port_type[j]];
 		if (!pti->phy_prep) {
-			CH_ALERT(adapter, "Invalid port type index %d\n",
+			ch_alert(adapter, "Invalid port type index %d\n",
 				 adapter->params.vpd.port_type[j]);
 			return -EINVAL;
 		}
diff --git a/drivers/net/ethernet/chelsio/cxgb3/xgmac.c b/drivers/net/ethernet/chelsio/cxgb3/xgmac.c
index 3af19a5..6d00c37 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/xgmac.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/xgmac.c
@@ -114,7 +114,7 @@ int t3_mac_reset(struct cmac *mac)
 					 F_RXENABLE | F_TXENABLE);
 			if (t3_wait_op_done(adap, A_XGM_SERDES_STATUS1 + oft,
 					    F_CMULOCK, 1, 5, 2)) {
-				CH_ERR(adap,
+				ch_err(adap,
 				       "MAC %d XAUI SERDES CMU lock failed\n",
 				       macidx(mac));
 				return -1;
@@ -181,8 +181,7 @@ static int t3b2_mac_reset(struct cmac *mac)
 	/* Increased loop count to 1000 from 5 cover 1G and 100Mbps case */
 	if (t3_wait_op_done(adap, A_XGM_RX_MAX_PKT_SIZE_ERR_CNT + oft,
 			    0x80000000, 1, 1000, 2)) {
-		CH_ERR(adap, "MAC %d Rx fifo drain failed\n",
-		       macidx(mac));
+		ch_err(adap, "MAC %d Rx fifo drain failed\n", macidx(mac));
 		return -1;
 	}
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 944f2cb..45b1f49 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -59,7 +59,7 @@
 #define T5FW_VERSION_MICRO 0x17
 #define T5FW_VERSION_BUILD 0x00
 
-#define CH_WARN(adap, fmt, ...) dev_warn(adap->pdev_dev, fmt, ## __VA_ARGS__)
+#define ch_warn(adap, fmt, ...) dev_warn(adap->pdev_dev, fmt, ##__VA_ARGS__)
 
 enum {
 	MAX_NPORTS = 4,     /* max # of ports */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 0ac53dd..b3c4b36 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -3638,7 +3638,7 @@ out:
 	q->db_disabled = 0;
 	spin_unlock_bh(&q->db_lock);
 	if (ret)
-		CH_WARN(adap, "DB drop recovery failed.\n");
+		ch_warn(adap, "DB drop recovery failed\n");
 }
 static void recover_all_queues(struct adapter *adap)
 {


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
