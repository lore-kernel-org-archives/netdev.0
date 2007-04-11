From: Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>
Subject: Re: QEMU PIC indirection patch for in-kernel APIC work
Date: Thu, 12 Apr 2007 09:30:00 +1000
Message-ID: <1176334200.14322.133.camel@localhost.localdomain>
References: <4613B438.60107@codemonkey.ws> <4613B89F.8090806@qumranet.com>
	<4613BC6B.1070708@codemonkey.ws> <4613BF07.50606@qumranet.com>
	<4613C993.9020405@codemonkey.ws> <4613CC01.1090500@qumranet.com>
	<4613CDB2.4000903@codemonkey.ws> <4613D001.3040606@qumranet.com>
	<20070404200112.GA6070@elte.hu> <4614098F.2030307@us.ibm.com>
	<20070404212103.GA19026@elte.hu>
	<1175728768.12230.593.camel@localhost.localdomain>
	<4614A294.3000607@qumranet.com>
	<1175821357.12230.642.camel@localhost.localdomain>
	<46187F4E.1080807@qumranet.com>
	<1176087018.11664.65.camel@localhost.localdomain>
	<4619E6DC.3010804@qumranet.com>
	<1176111984.11664.90.camel@localhost.localdomain>
	<461A41CA.9080201@qumranet.com>
	<1176263593.26372.84.camel@localhost.localdomain>
	<461C6360.1060908@qumranet.com>
	<1176297794.14322.72.camel@localhost.localdomain>
	<461CF098.3090003@qumranet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Avi Kivity <avi-atKUWr5tajBWk0Htik3J/w@public.gmane.org>
Return-path: <kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <461CF098.3090003-atKUWr5tajBWk0Htik3J/w@public.gmane.org>
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

On Wed, 2007-04-11 at 17:28 +0300, Avi Kivity wrote:
> Rusty Russell wrote:
> > On Wed, 2007-04-11 at 07:26 +0300, Avi Kivity wrote:
> >   
> >> Nope.  Being async is critical for copyless networking:
> >>
> With async operations, the saga continues like this: the host-side 
> driver allocates an skb, get_page()s and attaches the data to the new 
> skb, this skb crosses the bridge, trickles into the real ethernet 
> device, gets queued there, sent, interrupts fire, triggering async 
> completion.  On this completion, we send a virtual interrupt to the 
> guest, which tells it to destroy the skb and reclaim the pages attached 
> to it.

Hi Avi!

	Thanks for spelling it out, I now understand your POV.  I had
considered it obvious that a (non-async) write which didn't copy would
block until the skb was finished with, which is easy to code up within
the tap device itself.  Otherwise it's actually an async write without a
notification mechanism, which I agree is broken.

	Note though: if the guest can change the packet headers they can
subvert some firewall rules and possibly crash the host.  None of the
networking code I wrote expects packets to change in flight 8(

	This applies to a userspace or kernelspace driver.

> > Yes, and this is already present in the tap device.  Anthony suggested a
> > slightly nasty hack for multiple sg packets in one writev()/readv, which
> > could also give us batching.
> 
> No need for hacks if we get list aio support one day.

As you point out though, aio is not something we want to hold our breath
for.  Plus, aio never makes things simpler, and complexity kills
puppies.

Cheers!
Rusty.


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
