From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 21/21]: powerpc/cell spidernet DMA coalescing
Date: Thu, 12 Oct 2006 08:13:52 +1000
Message-ID: <1160604832.4792.10.camel@localhost.localdomain>
References: <20061010204946.GW4381@austin.ibm.com>
	<20061010212324.GR4381@austin.ibm.com>
	<452C2AAA.5070001@austin.ibm.com>
	<452C4CE0.5010607@am.sony.com> <20061011152016.GU4381@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, jeff@garzik.org, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, James K Lewis <jklewis@us.ibm.com>,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
To: Linas Vepstas <linas@austin.ibm.com>
In-Reply-To: <20061011152016.GU4381@austin.ibm.com>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org


> I started writingthe patch thinking it will have some huge effect on
> performance, based on a false assumption on how i/o was done on this
> machine
> 
> *If* this were another pSeries system, then each call to 
> pci_map_single() chews up an actual hardware "translation 
> control entry" (TCE) that maps pci bus addresses into 
> system RAM addresses. These are somewhat limited resources,
> and so one shouldn't squander them.  Furthermore, I thouhght
> TCE's have TLB's associated with them (similar to how virtual
> memory page tables are backed by hardware page TLB's), of which 
> there are even less of. I was thinking that TLB thrashing would 
> have a big hit on performance. 
> 
> Turns out that there was no difference to performance at all, 
> and a quick look at "cell_map_single()" in arch/powerpc/platforms/cell
> made it clear why: there's no fancy i/o address mapping.
> 
> Thus, the patch has only mrginal benefit; I submit it only in the 
> name of "its the right thing to do anyway".

Well, there is no fancy iommu mapping ... yet.

It's been implemented and is coming after we put together some
workarounds for various other spider hardware issues that trigger when
using it (bogus prefetches and bogus pci ordering).

I think the hypervisor based platforms will be happy with that patch
too.

Ben.
