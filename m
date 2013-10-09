From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH RFC 00/77] Re-design MSI/MSI-X interrupts enablement
 pattern
Date: Wed, 9 Oct 2013 11:41:17 -0400
Message-ID: <20131009154117.GA22495@htj.dyndns.org>
References: <1380840585.3419.50.camel@bwh-desktop.uk.level5networks.com>
 <20131004082920.GA4536@dhcp-26-207.brq.redhat.com>
 <1380922156.3214.49.camel@bwh-desktop.uk.level5networks.com>
 <20131005142054.GA11270@dhcp-26-207.brq.redhat.com>
 <1381009586.645.141.camel@pasglop>
 <20131006060243.GB28142@dhcp-26-207.brq.redhat.com>
 <1381040386.645.143.camel@pasglop>
 <20131006071027.GA29143@dhcp-26-207.brq.redhat.com>
 <20131007180111.GC2481@htj.dyndns.org>
 <20131008122215.GA14389@dhcp-26-207.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	linux-kernel@vger.kernel.org, Bjorn Helgaas <bhelgaas@google.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Michael Ellerman <michael@ellerman.id.au>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Ingo Molnar <mingo@redhat.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Andy King <acking@vmware.com>, Jon Mason <jon.mason@intel.com>,
	Matt Porter <mporter@kernel.crashing.org>,
	linux-pci@vger.kernel.org, linux-mips@linux-mips.org,
	linuxppc-dev@lists.ozlabs.org, linux390@de.ibm.com,
	linux-s390@vger.kernel.org, x86@kernel.org,
	linux-ide@vger.kernel.org, iss_storagedev@hp.com,
	linux-nvme@lists.infradead.org, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	linux-driver@qlogic.com,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	"VMw
To: Alexander Gordeev <agordeev@redhat.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131008122215.GA14389@dhcp-26-207.brq.redhat.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Tue, Oct 08, 2013 at 02:22:16PM +0200, Alexander Gordeev wrote:
> If we talk about pSeries quota, then the current pSeries pci_enable_msix()
> implementation is racy internally and could fail if the quota went down
> *while* pci_enable_msix() is executing. In this case the loop will have to
> exit rather than retry with a lower number (what number?).

Ah, okay, so that one is already broken.

> In this regard the new scheme does not bring anything new and relies on
> the fact this race does not hit and therefore does not worry.
> 
> If we talk about quota as it has to be, then yes - the loop scheme seems
> more preferable.
> 
> Overall, looks like we just need to fix the pSeries implementation,
> if the guys want it, he-he :)

If we can't figure out a better interface for the retry case, I think
what can really help is having a simple interface for the simpler
cases.

> > The problem case is where multiple msi(x) allocation fails completely
> > because the global limit went down before inquiry and allocation.  In
> > the loop based interface, it'd retry with the lower number.
> 
> I am probably missing something here. If the global limit went down before
> inquiry then the inquiry will get what is available and try to allocate with
> than number.

Oh, I should have written between inquiry and allocation.  Sorry.

Thanks.

-- 
tejun
