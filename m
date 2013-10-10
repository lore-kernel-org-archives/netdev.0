From: Alexander Gordeev <agordeev@redhat.com>
Subject: Re: [PATCH RFC 00/77] Re-design MSI/MSI-X interrupts enablement
 pattern
Date: Thu, 10 Oct 2013 12:17:05 +0200
Message-ID: <20131010101704.GC11874@dhcp-26-207.brq.redhat.com>
References: <cover.1380703262.git.agordeev@redhat.com>
 <5254D397.9030307@zytor.com>
 <1381292648.645.259.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "H. Peter Anvin" <hpa@zytor.com>, linux-kernel@vger.kernel.org,
        Bjorn Helgaas <bhelgaas@google.com>,
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
        linux-driver@qlogic.com,
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <linux-mips-bounce@linux-mips.org>
Content-Disposition: inline
In-Reply-To: <1381292648.645.259.camel@pasglop>
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

On Wed, Oct 09, 2013 at 03:24:08PM +1100, Benjamin Herrenschmidt wrote:
> On Tue, 2013-10-08 at 20:55 -0700, H. Peter Anvin wrote:
> > Why not add a minimum number to pci_enable_msix(), i.e.:
> > 
> > pci_enable_msix(pdev, msix_entries, nvec, minvec)
> > 
> > ... which means "nvec" is the number of interrupts *requested*, and
> > "minvec" is the minimum acceptable number (otherwise fail).
> 
> Which is exactly what Ben (the other Ben :-) suggested and that I
> supports...

Ok, this suggestion sounded in one or another form by several people.
What about name it pcim_enable_msix_range() and wrap in couple more
helpers to complete an API:

int pcim_enable_msix_range(pdev, msix_entries, nvec, minvec);
	<0 - error code
	>0 - number of MSIs allocated, where minvec >= result <= nvec

int pcim_enable_msix(pdev, msix_entries, nvec);
	<0 - error code
	>0 - number of MSIs allocated, where 1 >= result <= nvec 

int pcim_enable_msix_exact(pdev, msix_entries, nvec);
	<0 - error code
	>0 - number of MSIs allocated, where result == nvec

The latter's return value seems odd, but I can not help to make
it consistent with the first two.


(Sorry if you see this message twice - my MUA seems struggle with one of CC).

> Cheers,
> Ben.
> 
> 

-- 
Regards,
Alexander Gordeev
agordeev@redhat.com
