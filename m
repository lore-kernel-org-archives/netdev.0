From: Andi Kleen <ak@muc.de>
Subject: Re: [RFC] netif_rx: receive path optimization
Date: Fri, 01 Apr 2005 18:40:07 +0200
Message-ID: <m1mzsi1me0.fsf@muc.de>
References: <20050330132815.605c17d0@dxpl.pdx.osdl.net>
	<20050331120410.7effa94d@dxpl.pdx.osdl.net>
	<1112303431.1073.67.camel@jzny.localdomain> <424C6A98.1070509@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <424C6A98.1070509@hp.com> (Rick Jones's message of "Thu, 31 Mar
 2005 13:24:40 -0800")
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Rick Jones <rick.jones2@hp.com> writes:

> At the risk of again chewing on my toes (yum), if multiple CPUs are
> pulling packets from the per-device queue there will be packet
> reordering.  HP-UX 10.0 did just that and it was quite nasty even at
> low CPU counts (<=4).  It was changed by HP-UX 10.20 (ca 1995) to
> per-CPU queues with queue selection computed from packet headers (hash
> the IP and TCP/UDP header to pick a CPU) It was called IPS for Inbound
> Packet Scheduling.  11.0 (ca 1998) later changed that to "find where
> the connection last ran and queue to that CPU" That was called TOPS -
> Thread Optimized Packet Scheduling.

We went over this a lot several years ago when Linux got multi threaded RX
with softnet in 2.1.  You might want to go over the archives.

Some things that came out of it was a sender side TCP optimization
to tolerate reordering without slowing down (works great with other
Linux peers) and NAPI style polling mode (which was mostly designed for routing
and still seems to have regressions for the client/server case :/)

Something like TOPS was discussed, but afaik nobody ever implemented
it. Of course benchmark guys do it manually by setting interrupt
and scheduler affinity.

-Andi
