From: Jaswinder Singh Rajput <jaswinder@kernel.org>
Subject: [git-pull -tip V2] fix compilation warnings
Date: Thu, 12 Feb 2009 00:46:20 +0530
Message-ID: <1234379780.3910.8.camel@localhost.localdomain>
References: <1234377797.3910.6.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: x86 maintainers <x86@kernel.org>,
	David Miller <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	airlied@linux.ie, netdev@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:49019 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751013AbZBKTRE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Feb 2009 14:17:04 -0500
In-Reply-To: <1234377797.3910.6.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following changes since commit 5765fcf36081bafa06b9553376bd99ceb629beb8:
  Ingo Molnar (1):
        Merge branch 'linus'

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jaswinder/linux-2.6-tipclean.git master

Jaswinder Singh Rajput (7):
      x86: mm/init_32.c fix compilation warning
      x86: kernel/mpparse.c fix compilation warnings
      drm_proc.c fix compilation warning
      falcon fix compilation warnings
      iscsi_ibft.c fix compilation warning
      ne3210.c fix compilation warning for phys_addr_t
      arlan-main.c fix compilation warnings for phys_addr_t

 arch/x86/kernel/mpparse.c         |    6 +++---
 arch/x86/mm/init_32.c             |    2 +-
 drivers/firmware/iscsi_ibft.c     |    4 ++--
 drivers/gpu/drm/drm_proc.c        |    4 ++--
 drivers/net/ne3210.c              |    3 ++-
 drivers/net/sfc/falcon.c          |   24 ++++++++++++------------
 drivers/net/wireless/arlan-main.c |    4 ++--
 7 files changed, 24 insertions(+), 23 deletions(-)

Complete Diff:
diff --git a/arch/x86/kernel/mpparse.c b/arch/x86/kernel/mpparse.c
index 66ebb82..2007644 100644
--- a/arch/x86/kernel/mpparse.c
+++ b/arch/x86/kernel/mpparse.c
@@ -692,8 +692,8 @@ static int __init smp_scan_config(unsigned long base, unsigned long length,
 #endif
 			mpf_found = mpf;
 
-			printk(KERN_INFO "found SMP MP-table at [%p] %08lx\n",
-			       mpf, virt_to_phys(mpf));
+			printk(KERN_INFO "found SMP MP-table at [%p] %llx\n",
+			       mpf, (u64)virt_to_phys(mpf));
 
 			if (!reserve)
 				return 1;
@@ -1011,7 +1011,7 @@ static int __init update_mp_table(void)
 	if (!smp_check_mpc(mpc, oem, str))
 		return 0;
 
-	printk(KERN_INFO "mpf: %lx\n", virt_to_phys(mpf));
+	printk(KERN_INFO "mpf: %llx\n", (u64)virt_to_phys(mpf));
 	printk(KERN_INFO "physptr: %x\n", mpf->physptr);
 
 	if (mpc_new_phys && mpc->length > mpc_new_length) {
diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
index 41b3545..21d34b3 100644
--- a/arch/x86/mm/init_32.c
+++ b/arch/x86/mm/init_32.c
@@ -691,7 +691,7 @@ void __init find_low_pfn_range(void)
 			max_pfn = MAXMEM_PFN + highmem_pages;
 		if (highmem_pages + MAXMEM_PFN > max_pfn) {
 			printk(KERN_WARNING "only %luMB highmem pages "
-				"available, ignoring highmem size of %uMB.\n",
+				"available, ignoring highmem size of %luMB.\n",
 				pages_to_mb(max_pfn - MAXMEM_PFN),
 				pages_to_mb(highmem_pages));
 			highmem_pages = 0;
diff --git a/drivers/firmware/iscsi_ibft.c b/drivers/firmware/iscsi_ibft.c
index 3ab3e4a..7b7ddc2 100644
--- a/drivers/firmware/iscsi_ibft.c
+++ b/drivers/firmware/iscsi_ibft.c
@@ -938,8 +938,8 @@ static int __init ibft_init(void)
 		return -ENOMEM;
 
 	if (ibft_addr) {
-		printk(KERN_INFO "iBFT detected at 0x%lx.\n",
-		       virt_to_phys((void *)ibft_addr));
+		printk(KERN_INFO "iBFT detected at 0x%llx.\n",
+		       (u64)virt_to_phys((void *)ibft_addr));
 
 		rc = ibft_check_device();
 		if (rc)
diff --git a/drivers/gpu/drm/drm_proc.c b/drivers/gpu/drm/drm_proc.c
index 8df849f..b756f04 100644
--- a/drivers/gpu/drm/drm_proc.c
+++ b/drivers/gpu/drm/drm_proc.c
@@ -678,9 +678,9 @@ static int drm__vma_info(char *buf, char **start, off_t offset, int request,
 	*start = &buf[offset];
 	*eof = 0;
 
-	DRM_PROC_PRINT("vma use count: %d, high_memory = %p, 0x%08lx\n",
+	DRM_PROC_PRINT("vma use count: %d, high_memory = %p, 0x%llx\n",
 		       atomic_read(&dev->vma_count),
-		       high_memory, virt_to_phys(high_memory));
+		       high_memory, (u64)virt_to_phys(high_memory));
 	list_for_each_entry(pt, &dev->vmalist, head) {
 		if (!(vma = pt->vma))
 			continue;
diff --git a/drivers/net/ne3210.c b/drivers/net/ne3210.c
index fac43fd..6a843f7 100644
--- a/drivers/net/ne3210.c
+++ b/drivers/net/ne3210.c
@@ -150,7 +150,8 @@ static int __init ne3210_eisa_probe (struct device *device)
 		if (phys_mem < virt_to_phys(high_memory)) {
 			printk(KERN_CRIT "ne3210.c: Card RAM overlaps with normal memory!!!\n");
 			printk(KERN_CRIT "ne3210.c: Use EISA SCU to set card memory below 1MB,\n");
-			printk(KERN_CRIT "ne3210.c: or to an address above 0x%lx.\n", virt_to_phys(high_memory));
+			printk(KERN_CRIT "ne3210.c: or to an address above 0x%llx.\n",
+				(u64)virt_to_phys(high_memory));
 			printk(KERN_CRIT "ne3210.c: Driver NOT installed.\n");
 			retval = -EINVAL;
 			goto out3;
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index d5378e6..064307c 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -338,10 +338,10 @@ static int falcon_alloc_special_buffer(struct efx_nic *efx,
 	nic_data->next_buffer_table += buffer->entries;
 
 	EFX_LOG(efx, "allocating special buffers %d-%d at %llx+%x "
-		"(virt %p phys %lx)\n", buffer->index,
+		"(virt %p phys %llx)\n", buffer->index,
 		buffer->index + buffer->entries - 1,
-		(unsigned long long)buffer->dma_addr, len,
-		buffer->addr, virt_to_phys(buffer->addr));
+		(u64)buffer->dma_addr, len,
+		buffer->addr, (u64)virt_to_phys(buffer->addr));
 
 	return 0;
 }
@@ -353,10 +353,10 @@ static void falcon_free_special_buffer(struct efx_nic *efx,
 		return;
 
 	EFX_LOG(efx, "deallocating special buffers %d-%d at %llx+%x "
-		"(virt %p phys %lx)\n", buffer->index,
+		"(virt %p phys %llx)\n", buffer->index,
 		buffer->index + buffer->entries - 1,
-		(unsigned long long)buffer->dma_addr, buffer->len,
-		buffer->addr, virt_to_phys(buffer->addr));
+		(u64)buffer->dma_addr, buffer->len,
+		buffer->addr, (u64)virt_to_phys(buffer->addr));
 
 	pci_free_consistent(efx->pci_dev, buffer->len, buffer->addr,
 			    buffer->dma_addr);
@@ -2343,10 +2343,10 @@ int falcon_probe_port(struct efx_nic *efx)
 				 FALCON_MAC_STATS_SIZE);
 	if (rc)
 		return rc;
-	EFX_LOG(efx, "stats buffer at %llx (virt %p phys %lx)\n",
-		(unsigned long long)efx->stats_buffer.dma_addr,
+	EFX_LOG(efx, "stats buffer at %llx (virt %p phys %llx)\n",
+		(u64)efx->stats_buffer.dma_addr,
 		efx->stats_buffer.addr,
-		virt_to_phys(efx->stats_buffer.addr));
+		(u64)virt_to_phys(efx->stats_buffer.addr));
 
 	return 0;
 }
@@ -2921,9 +2921,9 @@ int falcon_probe_nic(struct efx_nic *efx)
 		goto fail4;
 	BUG_ON(efx->irq_status.dma_addr & 0x0f);
 
-	EFX_LOG(efx, "INT_KER at %llx (virt %p phys %lx)\n",
-		(unsigned long long)efx->irq_status.dma_addr,
-		efx->irq_status.addr, virt_to_phys(efx->irq_status.addr));
+	EFX_LOG(efx, "INT_KER at %llx (virt %p phys %llx)\n",
+		(u64)efx->irq_status.dma_addr,
+		efx->irq_status.addr, (u64)virt_to_phys(efx->irq_status.addr));
 
 	falcon_probe_spi_devices(efx);
 
diff --git a/drivers/net/wireless/arlan-main.c b/drivers/net/wireless/arlan-main.c
index bfca15d..14c1165 100644
--- a/drivers/net/wireless/arlan-main.c
+++ b/drivers/net/wireless/arlan-main.c
@@ -1082,8 +1082,8 @@ static int __init arlan_probe_here(struct net_device *dev,
 	if (arlan_check_fingerprint(memaddr))
 		return -ENODEV;
 
-	printk(KERN_NOTICE "%s: Arlan found at %x, \n ", dev->name, 
-	       (int) virt_to_phys((void*)memaddr));
+	printk(KERN_NOTICE "%s: Arlan found at %llx, \n ", dev->name, 
+	       (u64) virt_to_phys((void*)memaddr));
 
 	ap->card = (void *) memaddr;
 	dev->mem_start = memaddr;


