From: "Zhenyu Wu" <y030729@njupt.edu.cn>
Subject: Re: Scheduler Mechnisms!
Date: Wed, 05 Jan 2005 09:47:27 +0800
Message-ID: <304889647.25037@njupt.edu.cn>
Reply-To: "Zhenyu Wu" <y030729@njupt.edu.cn>
Content-Type: text/plain
Cc: lartc@mailman.ds9a.nl
Return-path: <lartc-admin@mailman.ds9a.nl>
To: imipak@yahoo.com, netdev@oss.sgi.com
Sender: lartc-admin@mailman.ds9a.nl
Errors-To: lartc-admin@mailman.ds9a.nl
List-Help: <mailto:lartc-request@mailman.ds9a.nl?subject=help>
List-Post: <mailto:lartc@mailman.ds9a.nl>
List-Subscribe: <http://mailman.ds9a.nl/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=subscribe>
List-Unsubscribe: <http://mailman.ds9a.nl/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=unsubscribe>
List-Archive: <http://mailman.ds9a.nl/pipermail/lartc/>
List-Id: netdev.vger.kernel.org

Thank you very much, i will try to find these papers which must be very helpful
for me. The "more" means that whether there are other mechanisms not only for
Linux. Sorry, i have not make it clear! Sometimes, i wonder whether the qdiscs
such as CBQ, RED, GRED ... are belong to the scheduler mechanisms in linux
enviroment. For example, In Red, which i can find are enqueue, and dequeue.... so,
if i add a RED qidsc to a class, must i add a scheduler mechanism so that i can
decide which packet in the queues will be scheduled and put to the link?

Good luck,
Best,



>It depends on what you mean by "more". More for Linux?
> Certainly. HTB3 seems to be a popular mechanism, and
> you can use IMQ to set up an intermediate device to
> allow shaping of both inbound and outbound traffic,
> using one (or more!) scheduling mechanisms in series.
> 
> (In fact, there are several versions of IMQ out there.
> I've given links to both the projects that seem to be
> alive, but there may be more.)
> 
> There's also ESFQ, but there doesn't seem to be much
> active work on that. There are forward ports to recent
> Linux kernels, though. QLinux has a version of H-SFQ
> for Linux, but again it seems to be getting long in
> the tooth. Unfortunately, I can't find any forward
> ports of that.
> 
> http://luxik.cdi.cz/~devik/qos/htb/
> http://www.linuximq.net/
> http://pupa.da.ru/imq/
> 
> http://www.digriz.org.uk/jdg-qos-script/#qos-2.6
> http://kem.p.lodz.pl/~peter/qnet/
> http://lass.cs.umass.edu/software/qlinux/
> 
> There are a great many systems that I can't find a
> Linux version of. Cisco routers support something
> called "Class-Based Weighted Fair Queueing" (CBWFQ)
> which seems to be a hybrid of classful and classless
> scheduling. Cisco also has two versions of ECN, for
> forwards and backwards propogation.
> 
> I've listed below a number of papers detailing various
> QoS schemes. Some of these have been implemented in
> other OS' (the BSDs tend to get a lot of this stuff
> implemented quickly for them as part of ALTQ) and some
> I've never seen an implementation at all. However, the
> papers should all give enough information to write a
> version for Linux.
> 
> Note: ALTQ can be found at:
> http://www.csl.sony.co.jp/person/kjc/kjc/software.html
> 
> Please note that this list is not exhaustive. Rather,
> I got exhausted after trying to find what was out
> there and what state it was currently in. QoS is a big
> field, if the number of papers is anything to go by.
> Linux only touches the fringes of it. If anyone feels
> particularly bored, or in need of a good ego boost, it
> would be cool to see if a reasonable selection of
> these could be introduced into Linux over the 2.7
> cycle.
> 
> EDF (Earliest Deadline First)
> http://citeseer.ist.psu.edu/13919.html
> 
> BLUE (an alternative to RED)
> http://citeseer.ist.psu.edu/feng99blue.html
> 
> AF PHB (Assured Forwarding Per-Hop Behaviour)
> http://citeseer.ist.psu.edu/552302.html
> 
> SFB (Stochastic Fair Blue)
> http://citeseer.ist.psu.edu/551253.html
> 
> GREEN (a pro-active variant on the theme of RED)
> http://citeseer.ist.psu.edu/feng02green.html
> 
> SMART (Scalable Multipath Aggregated RouTing)
> http://citeseer.ist.psu.edu/vutukury00smart.html
> 
> CSFQ (Core Stateless Fair Queueing)
> http://citeseer.ist.psu.edu/391.html
> 
> StFQ (Start-Time Fair Queueing)
> http://citeseer.ist.psu.edu/goyal96starttime.html
> 
> RFQ (Rainbow Fair Queueing)
> http://citeseer.ist.psu.edu/cao00rainbow.html
> 
> PrFQ (Probabalistic Fair Queueing)
> http://citeseer.ist.psu.edu/anker00prfq.html
> 
> ERR (Elastic Round Robin)
> http://citeseer.ist.psu.edu/kanhere02fair.html
> 
> GFQ (Greedy Fair Queueing)
> http://citeseer.ist.psu.edu/690207.html
> 
> PERR (Prioritized Elastic Round Robin)
> http://citeseer.ist.psu.edu/681127.html
> 
> AOQ (Anchored Opportunity Queueing)
> http://citeseer.ist.psu.edu/701742.html
> 
> BSFQ (Bin Sort Fair Queueing)
> http://citeseer.ist.psu.edu/622188.html
> 
> 
> As for the final question on what happens between
> enqueue and dequeue, there are various diagrams out
> there which show different aspects of how packets
> traverse the system. I've included a few links to
> those I could find:
> 
> http://open-source.arkoon.net/kernel/kernel_net.png
> http://ebtables.sourceforge.net/br_fw_ia/PacketFlow.png
> http://ebtables.sourceforge.net/br_fw_ia/br_fw_ia.html
> http://www.docum.org/docum.org/kptd/
> 
> The last of these is the infamous Kernel Packet
> Travelling Diagram. Most links to this that I've been
> able to find are broken. It should be noted that the
> diagrams all refer to the Linux 2.4 kernel. Linux 2.6
> has quite a few QoS changes to it, but I'm unclear as
> to whether they significantly alter any of the flows.
> 
> I hope this is of some use. Or, at the very least, is
> an effective remedy to insomnia. :)
> 
> Jonathan
> 
> --- Zhenyu Wu <y030729@njupt.edu.cn> wrote:
> 
> > Hello,
> > 
> > Normally, in addition to such qdisc scheduler
> > mechanisms as FIFO, PQ, WRR, WFQ,
> > are there any more? Then, there is a confusion on
> > scheduler in Linux enviroment:
> > Assume there is a qdisc, such as RED as a leaf qdisc
> > in a router, we know, if
> > there is packet which want to enqueue the packet,
> > the Function red_enqueue is
> > called, but when the packet leave the queue(when the
> > Function red_dequeue is
> > called)? I think it is meaningless when the pack
> > leaves the queue just it enterred
> > it. Is there anything need to be done betweent the
> > packet's enqueue and dequeue?
> > 
> > Best,
> > 
> > 
> > _______________________________________________
> > LARTC mailing list / LARTC@mailman.ds9a.nl
> > http://mailman.ds9a.nl/mailman/listinfo/lartc HOWTO:
> > http://lartc.org/
> > 
> 
> 
> 
> 		
> __________________________________ 
> Do you Yahoo!? 
> Jazz up your holiday email with celebrity designs. Learn more. 
> http://celebrity.mail.yahoo.com
> 
>


_______________________________________________
LARTC mailing list / LARTC@mailman.ds9a.nl
http://mailman.ds9a.nl/mailman/listinfo/lartc HOWTO: http://lartc.org/
