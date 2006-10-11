From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH 21/21]: powerpc/cell spidernet DMA coalescing
Date: Wed, 11 Oct 2006 10:20:17 -0500
Message-ID: <20061011152016.GU4381@austin.ibm.com>
References: <20061010204946.GW4381@austin.ibm.com>
	<20061010212324.GR4381@austin.ibm.com>
	<452C2AAA.5070001@austin.ibm.com> <452C4CE0.5010607@am.sony.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, jeff@garzik.org, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, James K Lewis <jklewis@us.ibm.com>,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
To: Geoff Levand <geoffrey.levand@am.sony.com>
Content-Disposition: inline
In-Reply-To: <452C4CE0.5010607@am.sony.com>
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

On Tue, Oct 10, 2006 at 06:46:08PM -0700, Geoff Levand wrote:
> > Linas Vepstas wrote:
> >> The current driver code performs 512 DMA mappns of a bunch of 
> >> 32-byte structures. This is silly, as they are all in contiguous 
> >> memory. Ths patch changes the code to DMA map the entie area
> >> with just one call.
> 
> Linas, 
> 
> Is the motivation for this change to improve performance by reducing the overhead
> of the mapping calls?  

Yes.

> If so, there may be some benefit for some systems.  Could
> you please elaborate?

I started writingthe patch thinking it will have some huge effect on
performance, based on a false assumption on how i/o was done on this
machine

*If* this were another pSeries system, then each call to 
pci_map_single() chews up an actual hardware "translation 
control entry" (TCE) that maps pci bus addresses into 
system RAM addresses. These are somewhat limited resources,
and so one shouldn't squander them.  Furthermore, I thouhght
TCE's have TLB's associated with them (similar to how virtual
memory page tables are backed by hardware page TLB's), of which 
there are even less of. I was thinking that TLB thrashing would 
have a big hit on performance. 

Turns out that there was no difference to performance at all, 
and a quick look at "cell_map_single()" in arch/powerpc/platforms/cell
made it clear why: there's no fancy i/o address mapping.

Thus, the patch has only mrginal benefit; I submit it only in the 
name of "its the right thing to do anyway".

--linas
