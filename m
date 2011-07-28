From: Ian Campbell <ijc@hellion.org.uk>
Subject: RE: [RFC net-next PATCH 1/4] pci: Add flag indicating device has
 been assigned by KVM
Date: Thu, 28 Jul 2011 17:27:39 +0100
Message-ID: <1311870459.24408.151.camel@cthulhu.hellion.org.uk>
References: <20110727221406.8435.44324.stgit@gitlad.jf.intel.com>
	 <20110727221749.8435.19000.stgit@gitlad.jf.intel.com>
	 <1311865877.24408.144.camel@cthulhu.hellion.org.uk>
	 <43F901BD926A4E43B106BF17856F0755019414D525@orsmsx508.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
To: "Rose, Gregory V" <gregory.v.rose@intel.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <43F901BD926A4E43B106BF17856F0755019414D525@orsmsx508.amr.corp.intel.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2011-07-28 at 08:58 -0700, Rose, Gregory V wrote:
> > -----Original Message-----
> > From: Ian Campbell [mailto:ijc@hellion.org.uk]
> > Sent: Thursday, July 28, 2011 8:11 AM
> > To: Rose, Gregory V; Konrad Rzeszutek Wilk
> > Cc: netdev@vger.kernel.org; davem@davemloft.net;
> > bhutchings@solarflare.com; Kirsher, Jeffrey T; Jesse Barnes; linux-
> > pci@vger.kernel.org
> > Subject: Re: [RFC net-next PATCH 1/4] pci: Add flag indicating device has
> > been assigned by KVM
> > 
> > On Wed, 2011-07-27 at 15:17 -0700, Greg Rose wrote:
> > > Device drivers that create and destroy SR-IOV virtual functions via
> > > calls to pci_enable_sriov() and pci_disable_sriov can cause catastrophic
> > > failures if they attempt to destroy VFs while they are assigned to
> > > guest virtual machines.  By adding a flag for use by the KVM module
> > > to indicate that a device is assigned a device driver can check that
> > > flag and avoid destroying VFs while they are assigned and avoid system
> > > failures.
> > >
> > > Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> > > ---
> > >
> > >  include/linux/pci.h     |    2 ++
> > 
> > I added Jesse and linux-pci to CC.
> > 
> > >  virt/kvm/assigned-dev.c |    2 ++
> > >  virt/kvm/iommu.c        |    4 ++++
> > >  3 files changed, 8 insertions(+), 0 deletions(-)
> > 
> > I suppose this would also be useful in Xen's pciback or any other system
> > which does passthrough? (Konrad CC'd for pciback)
> 
> Definitely yes.  Xen experiences the same issues when the PF driver is
> removed while VFs are assigned to guests.
> 
> > 
> > Is there some common lower layer we could hook this in to? (does
> > iommu_attach/detach_device make sense?) Or shall we just add the flag
> > manipulations to pciback as well?
> [Greg Rose] 
> 
> I was unaware of any common lower layers, i.e I didn't know that Xen
> also uses the iommu_attach/detach_device calls.

my mistake -- under Xen the iommu is driver by the hypervisor and not
the domain 0 kernel so there is no iommu_* in pciback.

>   It took me a week of digging around in the KVM module code just to
> find these hooks.

I'm not actually sure where in pciback the right place to put this would
be is, perhaps Konrad has an idea.

>   Generally I stick to Ethernet device drivers and I'm not that
> familiar with device pass through code.  I was just confronted with a
> problem and looking for some way to fix it.
> 
> ;^)
> 
> That sounds like a good idea, let me have a look at it.
> 
> - Greg
> 

-- 
Ian Campbell

Traffic signals in New York are just rough guidelines.
		-- David Letterman
