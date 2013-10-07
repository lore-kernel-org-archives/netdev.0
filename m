From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH RFC 00/77] Re-design MSI/MSI-X interrupts enablement
 pattern
Date: Tue, 08 Oct 2013 07:10:56 +1100
Message-ID: <1381176656.645.171.camel@pasglop>
References: <cover.1380703262.git.agordeev@redhat.com>
         <1380840585.3419.50.camel@bwh-desktop.uk.level5networks.com>
         <20131004082920.GA4536@dhcp-26-207.brq.redhat.com>
         <1380922156.3214.49.camel@bwh-desktop.uk.level5networks.com>
         <20131005142054.GA11270@dhcp-26-207.brq.redhat.com>
         <1381009586.645.141.camel@pasglop>
         <20131006060243.GB28142@dhcp-26-207.brq.redhat.com>
         <1381040386.645.143.camel@pasglop>
         <20131006071027.GA29143@dhcp-26-207.brq.redhat.com>
         <20131007180111.GC2481@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Gordeev <agordeev@redhat.com>,
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
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <20131007180111.GC2481@htj.dyndns.org>
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

On Mon, 2013-10-07 at 14:01 -0400, Tejun Heo wrote:
> I don't think the same race condition would happen with the loop.  The
> problem case is where multiple msi(x) allocation fails completely
> because the global limit went down before inquiry and allocation.  In
> the loop based interface, it'd retry with the lower number.
> 
> As long as the number of drivers which need this sort of adaptive
> allocation isn't too high and the common cases can be made simple, I
> don't think the "complex" part of interface is all that important.
> Maybe we can have reserve / cancel type interface or just keep the
> loop with more explicit function names (ie. try_enable or something
> like that).

I'm thinking a better API overall might just have been to request
individual MSI-X one by one :-)

We want to be able to request an MSI-X at runtime anyway ... if I want
to dynamically add a queue to my network interface, I want it to be able
to pop a new arbitrary MSI-X.

And we don't want to lock drivers into contiguous MSI-X sets either.

And for the cleanup ... well that's what the "pcim" functions are for,
we can just make MSI-X variants.

Ben.
