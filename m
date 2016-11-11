From: Baoquan He <bhe@redhat.com>
Subject: [PATCH 0/2] bnx2: Hard reset bnx2 chip at probe stage
Date: Fri, 11 Nov 2016 21:46:33 +0800
Message-ID: <1478871995-29652-1-git-send-email-bhe@redhat.com>
Cc: linux-kernel@vger.kernel.org, Dept-GELinuxNICDev@cavium.com,
        rasesh.mody@cavium.com, harish.patil@cavium.com,
        frank@undermydesk.org, jsr@dex.edzone.net, pmenzel@molgen.mpg.de,
        jroedel@suse.de, dyoung@redhat.com, Baoquan He <bhe@redhat.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi bnx2 experts,

In commit 3e1be7a ("bnx2: Reset device during driver initialization"),
firmware requesting code was moved from open stage to probe stage.
The reason is in kdump kernel hardware iommu need device be reset in
driver probe stage, otherwise those in-flight DMA from 1st kernel
will continue going and look up into the newly created io-page tables.
So we need reset device to stop in-flight DMA as early as possibe.

But with commit 3e1be7a merged, people reported their bnx2 driver init
failed because of failed firmware loading. After discussion, it's found
that they built bnx2 driver into kernel, and that makes probe function
bnx2_init_one be called in do_initcalls(). But at this time the initramfs
has not been uncompressed yet and mounted, kernel can't detect firmware.

So there's only one way to cover both. Try to hard reset the bnx2 device
at probe stage, without involving firmware issues. I tried to add function
bnx2_hard_reset_chip() to do this and it's only called in kdump kernel.
The thing is I am not quite familiar with bnx2 chip spec, just abstract
code from bnx2_reset_chip, the testing result is good.

Any suggestions are welcomed and much appreciated!

Baoquan He (2):
  Revert "bnx2: Reset device during driver initialization"
  bnx2: Hard reset bnx2 chip at probe stage

 drivers/net/ethernet/broadcom/bnx2.c | 70 +++++++++++++++++++++++++++++++++---
 1 file changed, 65 insertions(+), 5 deletions(-)

-- 
2.5.5
