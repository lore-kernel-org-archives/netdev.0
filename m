From: "Raj, Ashok" <ashok.raj@intel.com>
Subject: Re: [PATCH v9 1/4] PCI: Add new PCIe Fabric End Node flag,
 PCI_DEV_FLAGS_NO_RELAXED_ORDERING
Date: Wed, 9 Aug 2017 08:58:43 -0700
Message-ID: <20170809155841.GA8675@otc-nc-03>
References: <1501917313-9812-1-git-send-email-dingtianhong@huawei.com>
 <1501917313-9812-2-git-send-email-dingtianhong@huawei.com>
 <20170808232200.GO16580@bhelgaas-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ding Tianhong <dingtianhong@huawei.com>, leedom@chelsio.com,
        bhelgaas@google.com, werner@chelsio.com, ganeshgr@chelsio.com,
        asit.k.mallick@intel.com, patrick.j.cramer@intel.com,
        Suravee.Suthikulpanit@amd.com, Bob.Shaw@amd.com,
        l.stach@pengutronix.de, amira@mellanox.com,
        gabriele.paoloni@huawei.com, David.Laight@aculab.com,
        jeffrey.t.kirsher@intel.com, catalin.marinas@arm.com,
        will.deacon@arm.com, mark.rutland@arm.com, robin.murphy@arm.com,
        davem@davemloft.net, alexander.duyck@gmail.com,
        linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
        linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org,
        linuxarm@huawei.com, ashok.raj@intel.com
To: Bjorn Helgaas <helgaas@kernel.org>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170808232200.GO16580@bhelgaas-glaptop.roam.corp.google.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Bjorn

On Tue, Aug 08, 2017 at 06:22:00PM -0500, Bjorn Helgaas wrote:
> On Sat, Aug 05, 2017 at 03:15:10PM +0800, Ding Tianhong wrote:
> > From: Casey Leedom <leedom@chelsio.com>
> > 
> > Root complexes don't obey PCIe 3.0 ordering rules, hence could lead to
> > data-corruption.
> 
> This needs to include a link to the Intel spec
> (https://software.intel.com/sites/default/files/managed/9e/bc/64-ia-32-architectures-optimization-manual.pdf,
> sec 3.9.1).
> 
> It should also include a pointer to the AMD erratum, if available, or
> at least some reference to how we know it doesn't obey the rules.
> 
> Ashok, thanks for chiming in.  Now that you have, I have a few more
> questions for you:
> 
>   - Is the above doc the one you mentioned as being now public?

Yes. 
>   
>   - Is this considered a hardware erratum?

I would think so. I have tried to pursue the publication in that direction
but it morphed into the optimization guide instead. Once it got into some
open doc i stopped pushing.. but will continue to get this into erratum. i do
agree that's the right place holder for this.

>   
>   - If so, is there a pointer to that as well?
>   
>   - If this is not considered an erratum, can you provide any guidance
>     about how an OS should determine when it should use RO?

The optimization guide states that it only applies to transactions targetting
system memory. For peer-2-peer RO is allowed and has perf upside.

As Casey pointed out in an earlier thread, we choose the heavy hammer approach
because there are some that can lead to data-corruption as opposed to perf
degradation. 

This looks ugly, but maybe we can have 2 flags. one that indicates its a strict
no-no, and one that says no to system memory only. That way driver can
determine when the device would turn the hint on in the TLP.

>     
> Relying on a list of device IDs in an optimization manual is OK for an
> erratum, but if it's *not* an erratum, it seems like a hole in the

Good point.. for this specific case its really an erratum, but for some
reason they made the decision to use this doc vs. the generic errata
data-sheet that would have been the preferred way to document.

> specs because as far as I know there's no generic way for the OS to
> discover whether to use RO.
> 

Cheers,
Ashok
