From: Praveen Madhavan <praveenm@chelsio.com>
Subject: [PATCH 1/1] csiostor:fix sparse warnings
Date: Fri,  9 Jan 2015 21:25:16 +0530
Message-ID: <1420818916-12185-1-git-send-email-praveenm@chelsio.com>
Cc: davem@davemloft.net, JBottomley@parallels.com, hch@infradead.org,
	hariprasad@chelsio.com, praveenm@chelsio.com
To: netdev@vger.kernel.org, linux-scsi@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes sparse warning reported by kbuild.
Apply this on net-next since it depends on previous commit.

drivers/scsi/csiostor/csio_hw.c:259:17: sparse: cast to restricted __le32
drivers/scsi/csiostor/csio_hw.c:536:31: sparse: incorrect type in assignment
(different base types)
drivers/scsi/csiostor/csio_hw.c:536:31:    expected unsigned int [unsigned]
[usertype] <noident>
drivers/scsi/csiostor/csio_hw.c:536:31:    got restricted __be32 [usertype]
<noident>
>> drivers/scsi/csiostor/csio_hw.c:2012:5: sparse: symbol 'csio_hw_prep_fw' was
not declared. Should it be static?

Signed-off-by: Praveen Madhavan <praveenm@chelsio.com>
---
 drivers/scsi/csiostor/csio_hw.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/scsi/csiostor/csio_hw.c b/drivers/scsi/csiostor/csio_hw.c
index b70c15f..5c31fa6 100644
--- a/drivers/scsi/csiostor/csio_hw.c
+++ b/drivers/scsi/csiostor/csio_hw.c
@@ -256,7 +256,7 @@ csio_hw_seeprom_read(struct csio_hw *hw, uint32_t addr, uint32_t *data)
 	}
 
 	pci_read_config_dword(hw->pdev, base + PCI_VPD_DATA, data);
-	*data = le32_to_cpu(*data);
+	*data = le32_to_cpu(*(__le32 *)data);
 
 	return 0;
 }
@@ -533,7 +533,7 @@ csio_hw_read_flash(struct csio_hw *hw, uint32_t addr, uint32_t nwords,
 		if (ret)
 			return ret;
 		if (byte_oriented)
-			*data = htonl(*data);
+			*data = (__force __u32) htonl(*data);
 	}
 	return 0;
 }
@@ -2009,7 +2009,7 @@ static struct fw_info *find_fw_info(int chip)
 	return NULL;
 }
 
-int csio_hw_prep_fw(struct csio_hw *hw, struct fw_info *fw_info,
+static int csio_hw_prep_fw(struct csio_hw *hw, struct fw_info *fw_info,
 	       const u8 *fw_data, unsigned int fw_size,
 	       struct fw_hdr *card_fw, enum csio_dev_state state,
 	       int *reset)
-- 
2.0.2

