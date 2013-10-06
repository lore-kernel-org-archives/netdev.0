From: Alexander Gordeev <agordeev@redhat.com>
Subject: Re: [PATCH RFC 00/77] Re-design MSI/MSI-X interrupts enablement
 pattern
Date: Sun, 6 Oct 2013 09:10:30 +0200
Message-ID: <20131006071027.GA29143@dhcp-26-207.brq.redhat.com>
References: <cover.1380703262.git.agordeev@redhat.com>
 <1380840585.3419.50.camel@bwh-desktop.uk.level5networks.com>
 <20131004082920.GA4536@dhcp-26-207.brq.redhat.com>
 <1380922156.3214.49.camel@bwh-desktop.uk.level5networks.com>
 <20131005142054.GA11270@dhcp-26-207.brq.redhat.com>
 <1381009586.645.141.camel@pasglop>
 <20131006060243.GB28142@dhcp-26-207.brq.redhat.com>
 <1381040386.645.143.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
        linux-kernel@vger.kernel.org, Bjorn Helgaas <bhelgaas@google.com>,
        Ralf Baechle <ralf@linux-mips.org>,
        Michael Ellerman <michael@ellerman.id.au>,
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
        linux-driver@qlo
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <linux-mips-bounce@linux-mips.org>
Content-Disposition: inline
In-Reply-To: <1381040386.645.143.camel@pasglop>
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

On Sun, Oct 06, 2013 at 05:19:46PM +1100, Benjamin Herrenschmidt wrote:
> On Sun, 2013-10-06 at 08:02 +0200, Alexander Gordeev wrote:
> > In fact, in the current design to address the quota race decently the
> > drivers would have to protect the *loop* to prevent the quota change
> > between a pci_enable_msix() returned a positive number and the the next
> > call to pci_enable_msix() with that number. Is it doable?
> 
> I am not advocating for the current design, simply saying that your
> proposal doesn't address this issue while Ben's does.

There is one major flaw in min-max approach - the generic MSI layer
will have to take decisions on exact number of MSIs to request, not
device drivers.

This will never work for all devices, because there might be specific
requirements which are not covered by the min-max. That is what Ben
described "...say, any even number within a certain range". Ben suggests
to leave the existing loop scheme to cover such devices, which I think is
not right.

What about introducing pci_lock_msi() and pci_unlock_msi() and let device
drivers care about their ranges and specifics in race-safe manner?
I do not call to introduce it right now (since it appears pSeries has not
been hitting the race for years) just as a possible alternative to Ben's
proposal.

-- 
Regards,
Alexander Gordeev
agordeev@redhat.com
