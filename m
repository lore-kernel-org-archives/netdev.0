From: Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>
Subject: Re: QEMU PIC indirection patch for in-kernel APIC work
Date: Wed, 11 Apr 2007 23:23:14 +1000
Message-ID: <1176297794.14322.72.camel@localhost.localdomain>
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
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Avi Kivity <avi-atKUWr5tajBWk0Htik3J/w@public.gmane.org>
Return-path: <kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <461C6360.1060908-atKUWr5tajBWk0Htik3J/w@public.gmane.org>
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

On Wed, 2007-04-11 at 07:26 +0300, Avi Kivity wrote:
> Nope.  Being async is critical for copyless networking:
> 
> - in the transmit path, so need to stop the sender (guest) from touching
> the memory until it's on the wire.  This means 100% of packets sent will
> be blocked.

Hi Avi,

	You keep saying stuff like this, and I keep ignoring it.  OK, I'll
bite:

	Why would we try to prevent the sender from altering the packets?

> A userspace net interface needs to provide the following:
> 
> - true async operations

I'll hold on this pending discussion above.

> - multiple packets per operation (for interrupt mitigation) (like
> lio_listio)

The benefits for interrupt mitigation are less clear to me in a virtual
environment (scheduling tends to make it happen anyway); I'd want to
benchmark it.

Some kind of batching to reduce syscall overhead, perhaps, but TSO would
go a fair way towards that anyway (probably not enough).

> - scatter/gather packets (iovecs)

Yes, and this is already present in the tap device.  Anthony suggested a
slightly nasty hack for multiple sg packets in one writev()/readv, which
could also give us batching.

> - configurable wakeup (by packet count/timeout) for queue management

I'm not convinced that this is a showstopper, though.

> - hacks (tso)

I'd usually go for a batch interface over TSO, but if the card we're
sending to actually does TSO then TSO will probably win.

> Most of these can be provided by a combination of the pending aio work,
> the pending aio/fd integration, and the not-so-pending tap aio work.  As
> the first two are available as patches and the third is limited to the
> tap device, it is not unreasonable to try it out.  Maybe it will turn
> out not to be as difficult as I predicted just a few lines above.

Indeed, I don't think we're asking for a revolution a-la VJ-style
channels.  But I'm still itching to get back to that, and this might yet
provide an excuse 8)

Cheers,
Rusty.


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
