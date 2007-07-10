From: Jeff Garzik <jeff@garzik.org>
Subject: ata and netdev (was Re: -mm merge plans for 2.6.23)
Date: Tue, 10 Jul 2007 13:42:16 -0400
Message-ID: <4693C4F8.40903@garzik.org>
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	IDE/ATA development list <linux-ide@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, Tejun Heo <htejun@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-ide-owner@vger.kernel.org>
In-Reply-To: <20070710013152.ef2cd200.akpm@linux-foundation.org>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


(just to provide my indicator of status)

Andrew Morton wrote:
> libata-config_pm=n-compile-fix.patch

that's for a branch that you don't get via libata-dev#ALL, #mv-ahci-pata.


> pata_acpi-restore-driver.patch

see Alan's comments.  I've been ignoring pata_acpi for a while, because 
IMO it always needed work.


> libata-core-convert-to-use-cancel_rearming_delayed_work.patch

will merge


> libata-implement-ata_wait_after_reset.patch

I'm pretty much this is obsolete.  Tejun?


> sata_promise-sata-hotplug-support.patch

will merge


> libata-add-irq_flags-to-struct-pata_platform_info-fix.patch

are other pata_platform people happy with this?  I don't know embedded 
well enough to know if adding this struct member will break things.


> ata-add-the-sw-ncq-support-to-sata_nv-for-mcp51-mcp55-mcp61.patch
> sata_nv-allow-changing-queue-depth.patch

should be combined, really.  will merge eventually.  basic concept OK, 
but need to review in depth.

> pata_hpt3x3-major-reworking-and-testing.patch
> iomap-sort-out-the-broken-address-reporting-caused-by-the-iomap-layer.patch
> ata-use-iomap_name.patch

generally OK


> libata-check-for-an-support.patch
> scsi-expose-an-to-user-space.patch
> libata-expose-an-to-user-space.patch
> scsi-save-disk-in-scsi_device.patch
> libata-send-event-when-an-received.patch
> 
>  Am sitting on these due to confusion regarding the status of the ata-ahci
>  patches.

I will apply what I can, but it seems there are lifetime problems


> ata-ahci-alpm-store-interrupt-value.patch
> ata-ahci-alpm-expose-power-management-policy-option-to-users.patch
> ata-ahci-alpm-enable-link-power-management-for-ata-drivers.patch
> ata-ahci-alpm-enable-aggressive-link-power-management-for-ahci-controllers.patch
> 
>  These appear to need some work.

seemed mostly OK to me.  what comments did I miss?


> libata-add-human-readable-error-value-decoding.patch

still pondering; in my mbox queue

> libata-fix-hopefully-all-the-remaining-problems-with.patch
> testing-patch-for-ali-pata-fixes-hopefully-for-the-problems-with-atapi-dma.patch
> pata_ali-more-work.patch

No idea.  I would poke Alan.  Probably drop.


> 8139too-force-media-setting-fix.patch
> blackfin-on-chip-ethernet-mac-controller-driver.patch
> atari_pamsnetc-old-declaration-ritchie-style-fix.patch
> sundance-phy-address-form-0-only-for-device-id-0x0200.patch

Needs a bug fix, so that the newly modified loop doesn't scan the final 
phy id, then loop back around to scan the first again.


> 3x59x-fix-pci-resource-management.patch
> update-smc91x-driver-with-arm-versatile-board-info.patch
> drivers-net-ns83820c-add-paramter-to-disable-auto.patch
> 
>  netdev patches which are stuck in limbo land.

?  I don't think I've seen these.


> bonding-bond_mainc-make-2-functions-static.patch

FWIW bonding stuff should go to me, since it lives mostly in drivers/net


> x86-initial-fixmap-support.patch

Andi material?


> mm-revert-kernel_ds-buffered-write-optimisation.patch
> revert-81b0c8713385ce1b1b9058e916edcf9561ad76d6.patch
> revert-6527c2bdf1f833cc18e8f42bd97973d583e4aa83.patch
> mm-clean-up-buffered-write-code.patch
> mm-debug-write-deadlocks.patch
> mm-trim-more-holes.patch
> mm-buffered-write-cleanup.patch
> mm-write-iovec-cleanup.patch
> mm-fix-pagecache-write-deadlocks.patch
> mm-buffered-write-iterator.patch
> fs-fix-data-loss-on-error.patch
> mm-restore-kernel_ds-optimisations.patch
>  pagefault-in-write deadlock fixes.  Will hold for 2.6.24.

Any of the above worth 2.6.23?  Just wondering if they were useful 
cleanups / minor fixes prior to new aops patches?


> more-scheduled-oss-driver-removal.patch

ACK


> oss-trident-massive-whitespace-removal.patch
> oss-trident-fix-locking-around-write_voice_regs.patch
> oss-trident-replace-deprecated-pci_find_device-with-pci_get_device.patch
> remove-options-depending-on-oss_obsolete.patch
> 
>  Merge

what about just removing the OSS drivers in question?  :)


> intel-iommu-dmar-detection-and-parsing-logic.patch
> intel-iommu-pci-generic-helper-function.patch
> intel-iommu-clflush_cache_range-now-takes-size-param.patch
> intel-iommu-iova-allocation-and-management-routines.patch
> intel-iommu-intel-iommu-driver.patch
> intel-iommu-avoid-memory-allocation-failures-in-dma-map-api-calls.patch
> intel-iommu-intel-iommu-cmdline-option-forcedac.patch
> intel-iommu-dmar-fault-handling-support.patch
> intel-iommu-iommu-gfx-workaround.patch
> intel-iommu-iommu-floppy-workaround.patch
> 
>  Don't know.  I don't think there were any great objections, but I don't
>  think much benefit has been demonstrated?

Just the general march of progress on new hardware :)

I would like to see this support merged in /some/ form.  We've been 
telling Intel for years they were sillyheads for not bothering with an 
IOMMU.  Now that they have, we should give them a cookie and support 
good technology.

	Jeff


