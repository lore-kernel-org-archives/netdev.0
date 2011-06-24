From: Sergei Shtylyov <sshtylyov-hkdhdckH98+B+jHODAdFcQ@public.gmane.org>
Subject: [PATCH v2] iwlwifi: use pci_dev->revision, again
Date: Fri, 24 Jun 2011 19:39:37 +0400
Message-ID: <201106241939.37388.sshtylyov@ru.mvista.com>
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
pci_dev' but commit 084dd79172cb3aad11d2b7ee5628d57badca7c6e (iwlagn: move PCI
related operations from probe and remove to PCI layer) has again added the code
to read the PCI revision ID register...

Signed-off-by: Sergei Shtylyov <sshtylyov-hkdhdckH98+B+jHODAdFcQ@public.gmane.org>

---
The patch is against the iwlwifi-2.6.git...

 drivers/net/wireless/iwlwifi/iwl-pci.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

Index: iwlwifi-2.6/drivers/net/wireless/iwlwifi/iwl-pci.c
===================================================================
--- iwlwifi-2.6.orig/drivers/net/wireless/iwlwifi/iwl-pci.c
+++ iwlwifi-2.6/drivers/net/wireless/iwlwifi/iwl-pci.c
@@ -383,7 +383,6 @@ static int iwl_pci_probe(struct pci_dev 
 {
 	struct iwl_cfg *cfg = (struct iwl_cfg *)(ent->driver_data);
 	struct iwl_pci_bus *bus;
-	u8 rev_id;
 	u16 pci_cmd;
 	int err;
 
@@ -440,8 +439,7 @@ static int iwl_pci_probe(struct pci_dev 
 		(unsigned long long) pci_resource_len(pdev, 0));
 	pr_info("pci_resource_base = %p\n", bus->hw_base);
 
-	pci_read_config_byte(pdev, PCI_REVISION_ID, &rev_id);
-	pr_info("HW Revision ID = 0x%X\n", rev_id);
+	pr_info("HW Revision ID = 0x%X\n", pdev->revision);
 
 	/* We disable the RETRY_TIMEOUT register (0x41) to keep
 	 * PCI Tx retries from interfering with C3 CPU state */
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
