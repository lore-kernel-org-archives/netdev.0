From: Baoquan He <bhe@redhat.com>
Subject: Re: [PATCH] bnx2: Reset device during driver initialization
Date: Fri, 9 Sep 2016 16:50:05 +0800
Message-ID: <20160909085005.GG11356@x1.redhat.com>
References: <1473408667-7107-1-git-send-email-bhe@redhat.com>
 <20160909082225.GE11356@x1.redhat.com>
 <20160909084106.GY1437@8bytes.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sony.chacko@qlogic.com, Dept-HSGLinuxNICDev@qlogic.com,
        linux-kernel@vger.kernel.org, kexec@lists.infradead.org,
        netdev@vger.kernel.org, dyoung@redhat.com
To: Joerg Roedel <joro@8bytes.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160909084106.GY1437@8bytes.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/09/16 at 10:41am, Joerg Roedel wrote:
> 
> Hi Baoquan,
> 
> On Fri, Sep 09, 2016 at 04:22:25PM +0800, Baoquan He wrote:
> > Recently I tried to fix the kdump failure in amd iommu system again, and
> > now the latest code works, IO_PAGE_FAULT can't be seen any more. But on
> > several amd iommu system with bnx2 NIC, always IO_PAGE_FAULT will be
> > printed out. After investegating I found out bnx2 driver doesn't reset
> > hardware/reg like other pci device, it does the reset job in bnx2_open
> > which is the net device up stage. So with this patch the IO_PAGE_FAULT
> > is away too on the system with bnx2 NIC. I will 
> > 
> > However when I got a intel system with vt-d and bnx2 NIC, kdump works
> > well, and no any error message can be seen. From code it clearly shows
> > the domain assignment is done in __intel_map_single, at this time bnx2
> > driver hasn't reset device, the on-flight DMA should still exist. Do you
> > have any idea on this? Or I missed anything? I also deferred the
> > set_dte_entry calling to __map_single calling, the principal should be
> > similar.
> 
> Did you make sure that all unity-mappings are in place in the newly
> assigned domain for the bnx2 device before domains are switched?

About unity-mappings, are you saying it for intel iommu or amd iommu?
For amd iommu, I just skip call set_dte_entry calling during iommu
device init stage. Then in device init stage, namely __map_single, judge
and call set_dte_entry there to install the new pt_root into the related
dev table entry.

Thought you mention it, let me look into the unity-mappings of amd iommu
again.

Thanks a lot!
