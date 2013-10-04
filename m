From: Alexander Gordeev <agordeev@redhat.com>
Subject: Re: [PATCH RFC 00/77] Re-design MSI/MSI-X interrupts enablement
 pattern
Date: Fri, 4 Oct 2013 10:29:20 +0200
Message-ID: <20131004082920.GA4536@dhcp-26-207.brq.redhat.com>
References: <cover.1380703262.git.agordeev@redhat.com>
 <1380840585.3419.50.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Bjorn Helgaas <bhelgaas@google.com>,
        Ralf Baechle <ralf@linux-mips.org>,
        Michael Ellerman <michael@ellerman.id.au>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Ingo Molnar <mingo@redhat.com>, Tejun Heo <tj@kernel.org>,
        Dan Williams <dan.j.williams@intel.com>,
        Andy King <acking@vmware.com>, Jon Mason <jon.mason@intel.com>,
        Matt Porter <mporter@kernel.crashing.org>,
        linux-pci@vger.kernel.org, linux-mips@linux-mips.org,
        linuxppc-dev@lists.ozlabs.org, linux390@de.ibm.com,
        linux-s390@vger.kernel.org, x86@kernel.org,
        linux-ide@vger.kernel.org, iss_storagedev@hp.com,
        linux-nvme@lists.infradead.org, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
        linux-dr
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-mips-bounce@linux-mips.org>
Content-Disposition: inline
In-Reply-To: <1380840585.3419.50.camel@bwh-desktop.uk.level5networks.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

On Thu, Oct 03, 2013 at 11:49:45PM +0100, Ben Hutchings wrote:
> On Wed, 2013-10-02 at 12:48 +0200, Alexander Gordeev wrote:
> > This update converts pci_enable_msix() and pci_enable_msi_block()
> > interfaces to canonical kernel functions and makes them return a
> > error code in case of failure or 0 in case of success.
> [...]
> 
> I think this is fundamentally flawed: pci_msix_table_size() and
> pci_get_msi_cap() can only report the limits of the *device* (which the
> driver usually already knows), whereas MSI allocation can also be
> constrained due to *global* limits on the number of distinct IRQs.

Even the current implementation by no means addresses it. Although it
might seem a case for architectures to report the number of IRQs available
for a driver to retry, in fact they all just fail. The same applies to
*any* other type of resource involved: irq_desc's, CPU interrupt vector
space, msi_desc's etc. No platform cares about it and just bails out once
a constrain met (please correct me if I am wrong here). Given that Linux
has been doing well even on embedded I think we should not change it.

The only exception to the above is pSeries platform which takes advantage
of the current design (to implement MSI quota). There are indications we
can satisfy pSeries requirements, but the design proposed in this RFC
is not going to change drastically anyway. The start of the discusstion
is here: https://lkml.org/lkml/2013/9/5/293

> Currently pci_enable_msix() will report a positive value if it fails due
> to the global limit.  Your patch 7 removes that.  pci_enable_msi_block()
> unfortunately doesn't appear to do this.

pci_enable_msi_block() can do more than one MSI only on x86 (with IOMMU),
but it does not bother to return positive numbers, indeed.

> It seems to me that a more useful interface would take a minimum and
> maximum number of vectors from the driver.  This wouldn't allow the
> driver to specify that it could only accept, say, any even number within
> a certain range, but you could still leave the current functions
> available for any driver that needs that.

Mmmm.. I am not sure I am getting it. Could you please rephrase?

> Ben.

-- 
Regards,
Alexander Gordeev
agordeev@redhat.com
