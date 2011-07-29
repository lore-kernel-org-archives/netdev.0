From: Jesse Barnes <jbarnes@virtuousgeek.org>
Subject: Re: [RFC net-next PATCH 1/4] pci: Add flag indicating device has
 been assigned by KVM
Date: Fri, 29 Jul 2011 09:51:41 -0700
Message-ID: <20110729095141.472e8081@jbarnes-desktop>
References: <20110727221406.8435.44324.stgit@gitlad.jf.intel.com>
	<20110727221749.8435.19000.stgit@gitlad.jf.intel.com>
	<1311865877.24408.144.camel@cthulhu.hellion.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Greg Rose <gregory.v.rose@intel.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	netdev@vger.kernel.org, davem@davemloft.net,
	bhutchings@solarflare.com, jeffrey.t.kirsher@intel.com,
	linux-pci@vger.kernel.org
To: Ian Campbell <ijc@hellion.org.uk>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1311865877.24408.144.camel@cthulhu.hellion.org.uk>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 28 Jul 2011 16:11:17 +0100
Ian Campbell <ijc@hellion.org.uk> wrote:

> On Wed, 2011-07-27 at 15:17 -0700, Greg Rose wrote:
> > Device drivers that create and destroy SR-IOV virtual functions via
> > calls to pci_enable_sriov() and pci_disable_sriov can cause catastrophic
> > failures if they attempt to destroy VFs while they are assigned to
> > guest virtual machines.  By adding a flag for use by the KVM module
> > to indicate that a device is assigned a device driver can check that
> > flag and avoid destroying VFs while they are assigned and avoid system
> > failures.
> > 
> > Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> > ---
> > 
> >  include/linux/pci.h     |    2 ++
> 
> I added Jesse and linux-pci to CC.
> 
> >  virt/kvm/assigned-dev.c |    2 ++
> >  virt/kvm/iommu.c        |    4 ++++
> >  3 files changed, 8 insertions(+), 0 deletions(-)
> 
> I suppose this would also be useful in Xen's pciback or any other system
> which does passthrough? (Konrad CC'd for pciback)
> 
> Is there some common lower layer we could hook this in to? (does
> iommu_attach/detach_device make sense?) Or shall we just add the flag
> manipulations to pciback as well?
> 
> Ian.
> 
> > 
> > diff --git a/include/linux/pci.h b/include/linux/pci.h
> > index 2d29218..a297ca2 100644
> > --- a/include/linux/pci.h
> > +++ b/include/linux/pci.h
> > @@ -174,6 +174,8 @@ enum pci_dev_flags {
> >  	PCI_DEV_FLAGS_MSI_INTX_DISABLE_BUG = (__force pci_dev_flags_t) 1,
> >  	/* Device configuration is irrevocably lost if disabled into D3 */
> >  	PCI_DEV_FLAGS_NO_D3 = (__force pci_dev_flags_t) 2,
> > +	/* Provide indication device is assigned by KVM */
> > +	PCI_DEV_FLAGS_ASSIGNED = (__force pci_dev_flags_t) 4,
> >  };

Looks fine, but I'd make the comment less redundant with the code, e.g.
"set when the device is assigned to a guest instance" or somesuch.

-- 
Jesse Barnes, Intel Open Source Technology Center
