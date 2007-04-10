From: Evgeniy Polyakov <johnpol-9fLWQ3dKdXwox3rIn2DAYQ@public.gmane.org>
Subject: Re: QEMU PIC indirection patch for in-kernel APIC work
Date: Tue, 10 Apr 2007 15:50:37 +0400
Message-ID: <20070410115035.GA2247@2ka.mipt.ru>
References: <1175821357.12230.642.camel@localhost.localdomain>
	<46187F4E.1080807@qumranet.com>
	<1176087018.11664.65.camel@localhost.localdomain>
	<4619E6DC.3010804@qumranet.com>
	<1176111984.11664.90.camel@localhost.localdomain>
	<461A41CA.9080201@qumranet.com>
	<20070410080729.GB16621@2ka.mipt.ru>
	<461B48A8.1060904@qumranet.com>
	<20070410085825.GA20004@2ka.mipt.ru>
	<461B7334.8090807@qumranet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Avi Kivity <avi-atKUWr5tajBWk0Htik3J/w@public.gmane.org>
Return-path: <kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <461B7334.8090807-atKUWr5tajBWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=kvm-devel>
List-Post: <mailto:kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:kvm-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Sender: kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 10, 2007 at 02:21:24PM +0300, Avi Kivity (avi-atKUWr5tajBWk0Htik3J/w@public.gmane.org) wrote:
> >You want to implement zero-copy network device between host and guest, if
> >I understood this thread correctly?
> >So, for sending part, device allocates pages from receiver's memory (or
> >from shared memory), receiver gets an 'interrupt' and got pages from own
> >memory, which are attached to new skb and transferred up to the network
> >stack.
> >It can be extended to use shared ring of pages.
> >  
> 
> This is what Xen does.  It is actually less performant than copying, IIRC.
> 
> The problem with flipping pages around is that physical addresses are 
> cached both in the kvm mmu and in the on-chip tlbs, necessitating 
> expensive page table walks and tlb invalidation IPIs.

Hmm, I'm not familiar with Xen driver, but similar technique was used
with zero-copy network sniffer some time ago, substituting userspace
pages with pages containing skb data was about 25-50% faster than
copying 1500 bytes in general, and in order of 10 times faster in some
cases.

Check a link please in case we are talking about different ideas:
http://marc.info/?l=linux-netdev&m=112262743505711&w=2

-- 
	Evgeniy Polyakov

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
