From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: ata and netdev (was Re: -mm merge plans for 2.6.23)
Date: Tue, 10 Jul 2007 11:24:58 -0700
Message-ID: <20070710112458.e9dbb55e.akpm@linux-foundation.org>
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>
	<4693C4F8.40903@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	IDE/ATA development list <linux-ide@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, Tejun Heo <htejun@gmail.com>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Deepak Saxena <dsaxena@plexity.net>,
	Dan Faerch <dan@hacker.dk>, Benjamin LaHaise <bcrl@kvack.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <linux-ide-owner@vger.kernel.org>
In-Reply-To: <4693C4F8.40903@garzik.org>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 10 Jul 2007 13:42:16 -0400
Jeff Garzik <jeff@garzik.org> wrote:

> 
> (just to provide my indicator of status)

Thanks.

> > libata-add-irq_flags-to-struct-pata_platform_info-fix.patch
> 
> are other pata_platform people happy with this?  I don't know embedded 
> well enough to know if adding this struct member will break things.

This is just a silly remove-unneeded-cast-of-void* cleanup.  I wrote this
as a fixup against
libata-add-irq_flags-to-struct-pata_platform_info.patch with the intention
of folding it into that base patch, but you went and merged the submitter's
original patch so this trivial fixup got stranded in -mm.  Feel free to give
it the piss-off-too-trivial treatment.

> > ata-ahci-alpm-store-interrupt-value.patch
> > ata-ahci-alpm-expose-power-management-policy-option-to-users.patch
> > ata-ahci-alpm-enable-link-power-management-for-ata-drivers.patch
> > ata-ahci-alpm-enable-aggressive-link-power-management-for-ahci-controllers.patch
> > 
> >  These appear to need some work.
> 
> seemed mostly OK to me.  what comments did I miss?

Oh, I thought these were the patches which affected scsi and which James
had issues with.  I guess I got confused.

> 
> > libata-add-human-readable-error-value-decoding.patch
> 
> still pondering; in my mbox queue
> 
> > libata-fix-hopefully-all-the-remaining-problems-with.patch
> > testing-patch-for-ali-pata-fixes-hopefully-for-the-problems-with-atapi-dma.patch
> > pata_ali-more-work.patch
> 
> No idea.  I would poke Alan.  Probably drop.
> 

Alan: poke.

> 
> > 8139too-force-media-setting-fix.patch
> > blackfin-on-chip-ethernet-mac-controller-driver.patch
> > atari_pamsnetc-old-declaration-ritchie-style-fix.patch
> > sundance-phy-address-form-0-only-for-device-id-0x0200.patch
> 
> Needs a bug fix, so that the newly modified loop doesn't scan the final 
> phy id, then loop back around to scan the first again.
> 
> 
> > 3x59x-fix-pci-resource-management.patch
> > update-smc91x-driver-with-arm-versatile-board-info.patch
> > drivers-net-ns83820c-add-paramter-to-disable-auto.patch
> > 
> >  netdev patches which are stuck in limbo land.
> 
> ?  I don't think I've seen these.
> 

3x59x-fix-pci-resource-management.patch: you wrote it ;) I have a comment
here:

- I don't remember the story with cardbus either.  Presumably once upon a
  time the cardbus layer was claiming IO regions on behalf of cardbus
  devices (?)

Need to think about that.

update-smc91x-driver-with-arm-versatile-board-info.patch:

See comment from rmk in changelog:
ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.22-rc6/2.6.22-rc6-mm1/broken-out/update-smc91x-driver-with-arm-versatile-board-info.patch

Deepak, can we move this along a bit please?

drivers-net-ns83820c-add-paramter-to-disable-auto.patch:

See comments in changelog: ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.22-rc6/2.6.22-rc6-mm1/broken-out/drivers-net-ns83820c-add-paramter-to-disable-auto.patch

Dan, Ben: is there any prospect of progress here?

> 
> > bonding-bond_mainc-make-2-functions-static.patch
> 
> FWIW bonding stuff should go to me, since it lives mostly in drivers/net
> 

Ah, noted.

> > x86-initial-fixmap-support.patch
> 
> Andi material?
> 

Spose so.  But it's buried in the middle of a series of four patches.

> 
> > mm-revert-kernel_ds-buffered-write-optimisation.patch
> > revert-81b0c8713385ce1b1b9058e916edcf9561ad76d6.patch
> > revert-6527c2bdf1f833cc18e8f42bd97973d583e4aa83.patch
> > mm-clean-up-buffered-write-code.patch
> > mm-debug-write-deadlocks.patch
> > mm-trim-more-holes.patch
> > mm-buffered-write-cleanup.patch
> > mm-write-iovec-cleanup.patch
> > mm-fix-pagecache-write-deadlocks.patch
> > mm-buffered-write-iterator.patch
> > fs-fix-data-loss-on-error.patch
> > mm-restore-kernel_ds-optimisations.patch
> >  pagefault-in-write deadlock fixes.  Will hold for 2.6.24.
> 
> Any of the above worth 2.6.23?  Just wondering if they were useful 
> cleanups / minor fixes prior to new aops patches?
> 

The first few patches will a) fix up our writev performance regression and
b) reintroduce the writev() deadlock which the writev()-regresion-adding
patch fixed.

So it's all a bit ugly.

> 
> > oss-trident-massive-whitespace-removal.patch
> > oss-trident-fix-locking-around-write_voice_regs.patch
> > oss-trident-replace-deprecated-pci_find_device-with-pci_get_device.patch
> > remove-options-depending-on-oss_obsolete.patch
> > 
> >  Merge
> 
> what about just removing the OSS drivers in question?  :)
> 

Hey, I only work here.

> 
> > intel-iommu-dmar-detection-and-parsing-logic.patch
> > intel-iommu-pci-generic-helper-function.patch
> > intel-iommu-clflush_cache_range-now-takes-size-param.patch
> > intel-iommu-iova-allocation-and-management-routines.patch
> > intel-iommu-intel-iommu-driver.patch
> > intel-iommu-avoid-memory-allocation-failures-in-dma-map-api-calls.patch
> > intel-iommu-intel-iommu-cmdline-option-forcedac.patch
> > intel-iommu-dmar-fault-handling-support.patch
> > intel-iommu-iommu-gfx-workaround.patch
> > intel-iommu-iommu-floppy-workaround.patch
> > 
> >  Don't know.  I don't think there were any great objections, but I don't
> >  think much benefit has been demonstrated?
> 
> Just the general march of progress on new hardware :)
> 
> I would like to see this support merged in /some/ form.  We've been 
> telling Intel for years they were sillyheads for not bothering with an 
> IOMMU.  Now that they have, we should give them a cookie and support 
> good technology.

OK, thanks.
