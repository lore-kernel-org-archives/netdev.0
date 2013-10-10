From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [PATCH RFC 00/77] Re-design MSI/MSI-X interrupts enablement pattern
Date: Thu, 10 Oct 2013 09:28:27 -0700
Message-ID: <5256D5AB.4050105@zytor.com>
References: <cover.1380703262.git.agordeev@redhat.com> <5254D397.9030307@zytor.com> <1381292648.645.259.camel@pasglop> <20131010101704.GC11874@dhcp-26-207.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
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
        linux-dr
To: Alexander Gordeev <agordeev@redhat.com>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <20131010101704.GC11874@dhcp-26-207.brq.redhat.com>
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

On 10/10/2013 03:17 AM, Alexander Gordeev wrote:
> On Wed, Oct 09, 2013 at 03:24:08PM +1100, Benjamin Herrenschmidt wrote:
> 
> Ok, this suggestion sounded in one or another form by several people.
> What about name it pcim_enable_msix_range() and wrap in couple more
> helpers to complete an API:
> 
> int pcim_enable_msix_range(pdev, msix_entries, nvec, minvec);
> 	<0 - error code
> 	>0 - number of MSIs allocated, where minvec >= result <= nvec
> 
> int pcim_enable_msix(pdev, msix_entries, nvec);
> 	<0 - error code
> 	>0 - number of MSIs allocated, where 1 >= result <= nvec 
> 
> int pcim_enable_msix_exact(pdev, msix_entries, nvec);
> 	<0 - error code
> 	>0 - number of MSIs allocated, where result == nvec
> 
> The latter's return value seems odd, but I can not help to make
> it consistent with the first two.
> 

Is there a reason for the wrappers, as opposed to just specifying either
1 or nvec as the minimum?

	-hpa
