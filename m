From: Sergei Shtylyov <sshtylyov-hkdhdckH98+B+jHODAdFcQ@public.gmane.org>
Subject: [PATCH 1/2] iwlwifi: use pci_dev->revision, again
Date: Thu, 23 Jun 2011 18:41:40 +0400
Message-ID: <201106231841.40691.sshtylyov@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Commit ff938e43d39e926de74b32a3656c190f979ab642 (net: use pci_dev->revision,
again) already converted this driver to using the 'revision' field of 'struct
pci_dev' but commit c2974a1d18832a9fffb2eb389c3878f5c4ed92f1 (iwlagn: remove
rev_id) later reverted that change for no reason. Now restore the change...

Signed-off-by: Sergei Shtylyov <sshtylyov-hkdhdckH98+B+jHODAdFcQ@public.gmane.org>

---
The patch is against the recent Linus' tree.

 drivers/net/wireless/iwlwifi/iwl-agn.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

Index: linux-2.6/drivers/net/wireless/iwlwifi/iwl-agn.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/iwlwifi/iwl-agn.c
+++ linux-2.6/drivers/net/wireless/iwlwifi/iwl-agn.c
@@ -3275,10 +3275,9 @@ struct ieee80211_ops iwlagn_hw_ops = {
 
 static u32 iwl_hw_detect(struct iwl_priv *priv)
 {
-	u8 rev_id;
+	IWL_DEBUG_INFO(priv, "HW Revision ID = 0x%X\n",
+		       priv->pci_dev->revision);
 
-	pci_read_config_byte(priv->pci_dev, PCI_REVISION_ID, &rev_id);
-	IWL_DEBUG_INFO(priv, "HW Revision ID = 0x%X\n", rev_id);
 	return iwl_read32(priv, CSR_HW_REV);
 }
 
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
