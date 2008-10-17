From: "Arno J. Klaassen" <arno@heho.snv.jussieu.fr>
Subject: Re: [Bugme-new] [Bug 11752] New: Extremely low netperf UDP_RR	throughput for nvidia MCP65
Date: 17 Oct 2008 16:28:07 +0200
Message-ID: <wp3aivxpmw.fsf@heho.snv.jussieu.fr>
References: <bug-11752-10286@http.bugzilla.kernel.org/>
	<20081016134920.1492cdcc.akpm@linux-foundation.org>
	<48F7AD1A.7050309@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	arno@heho.snv.jussieu.fr, Ayaz Abdulla <aabdulla@nvidia.com>
To: Rick Jones <rick.jones2@hp.com>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shiva.jussieu.fr ([134.157.0.129]:63930 "EHLO shiva.jussieu.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757564AbYJQPom (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Oct 2008 11:44:42 -0400
In-Reply-To: <48F7AD1A.7050309@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hello all,

thanx for your help.


Rick Jones <rick.jones2@hp.com> writes:

> Andrew Morton wrote:
> > (switched to email.  Please respond via emailed reply-to-all, not via the
> > bugzilla web interface).
> > On Mon, 13 Oct 2008 13:41:19 -0700 (PDT)
> > bugme-daemon@bugzilla.kernel.org wrote:
> >
> >>http://bugzilla.kernel.org/show_bug.cgi?id=11752
> >>
> >>           Summary: Extremely low netperf UDP_RR throughput for nvidia MCP65
> >>           Product: Drivers
> >>           Version: 2.5
> >>     KernelVersion: from F10-Beta-x86_64-Live-KDE.iso
> >>          Platform: All
> >>        OS/Version: Linux
> >>              Tree: Mainline
> >>            Status: NEW
> >>          Severity: normal
> >>          Priority: P1
> >>         Component: Network
> >>        AssignedTo: jgarzik@pobox.com
> >>        ReportedBy: arno@heho.snv.jussieu.fr
> >>
> >>
> >>Latest working kernel version: -
> >>Earliest failing kernel version:
> >>Distribution: F10-Beta-x86_64
> >>Hardware Environment: HP Pavillon dv6820ef
> >>Software Environment:
> >>Problem Description: when running at 1Gbps netperf shows good performance for
> >>TCP_STREAM and UDP_STREAM tests, but extremely bad performance for UDP_RR test
> >>(less then 1 ping-pong a second whereas at 100Mbps performance easily reaches
> >>10-20K a second)
> >>
> >>A friend figured out that it looks like small packets at 1Gbps are dropped
> >>as being falsely considered crc-errored.
> 
> Given how netperf UDP_RR has _no_ recovery from lost datagrams, it
> makes sense that performance on that test would be very low - the
> first lost datagram the transactions come to a screeching halt until
> the end-of-test timer expires.
> 
> Are netstat stats showing retransmissions during a TCP_STREAM test?

I will check that later tonoght and/or this WE

> How about a TCP_RR test?  TCP_RR might be low too, it just wouldn't
> necessarily be as low since TCP will get things started again after a
> loss.   UDP_STREAM would just go blasting along without a care in the
> world...

A summary of all tests is (REFERENCE being a freebsd6 box on same
LAN against same server running netserver; it's pretty clear that
the *STREAM tests perform OK and the *RR test poor to very poor) :

TCP_STREAM
              Throughput
              10^6bits/sec

REFERENCE     349.57
fc10-x64      138.48


UDP_STREAM
              Throughput
              10^6bits/sec

REFERENCE     388.45
fc10-x64      365.10


TCP_RR
              Trans.
              Rate
              per sec

REFERENCE     9801.58
fc10-x64        86.87


TCP_CRR
              Trans.
              Rate
              per sec

REFERENCE     4520.98
fc10-x64         5.60


UDP_RR
              Trans.
              Rate
              per sec

REFERENCE     9473.20
fc10-x64         0.80


Arno


