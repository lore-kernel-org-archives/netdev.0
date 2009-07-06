From: "Ma, Chinang" <chinang.ma@intel.com>
Subject: RE: >10% performance degradation since 2.6.18
Date: Mon, 6 Jul 2009 11:48:47 -0700
Message-ID: <BC02C49EEB98354DBA7F5DD76F2A9E800357E11D67@azsmsx501.amr.corp.intel.com>
References: <20090705040137.GA7747@gondor.apana.org.au>
 <4A522D9A.1090006@hp.com>
 <BC02C49EEB98354DBA7F5DD76F2A9E800357D5A0C5@azsmsx501.amr.corp.intel.com>
 <20090706174203.GV5480@parisc-linux.org>
 <BC02C49EEB98354DBA7F5DD76F2A9E800357E11BC8@azsmsx501.amr.corp.intel.com>
 <20090706180530.GX5480@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Rick Jones <rick.jones2@hp.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Jeff Garzik <jeff@garzik.org>,
	"andi@firstfloor.org" <andi@firstfloor.org>,
	"arjan@infradead.org" <arjan@infradead.org>,
	"jens.axboe@oracle.com" <jens.axboe@oracle.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Styner, Douglas W" <douglas.w.styner@intel.com>,
	"Prickett, Terry O" <terry.o.prickett@intel.com>,
	"Wilcox, Matthew R" <matthew.r.wilcox@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: Matthew Wilcox <matthew@wil.cx>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:22167 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753853AbZGFSsp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2009 14:48:45 -0400
In-Reply-To: <20090706180530.GX5480@parisc-linux.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>-----Original Message-----
>From: Matthew Wilcox [mailto:matthew@wil.cx]
>Sent: Monday, July 06, 2009 11:06 AM
>To: Ma, Chinang
>Cc: Rick Jones; Herbert Xu; Jeff Garzik; andi@firstfloor.org;
>arjan@infradead.org; jens.axboe@oracle.com; linux-kernel@vger.kernel.org;
>Styner, Douglas W; Prickett, Terry O; Wilcox, Matthew R;
>netdev@vger.kernel.org; Brandeburg, Jesse
>Subject: Re: >10% performance degradation since 2.6.18
>
>On Mon, Jul 06, 2009 at 10:57:09AM -0700, Ma, Chinang wrote:
>> >-----Original Message-----
>> >From: Matthew Wilcox [mailto:matthew@wil.cx]
>> >Sent: Monday, July 06, 2009 10:42 AM
>> >To: Ma, Chinang
>> >Cc: Rick Jones; Herbert Xu; Jeff Garzik; andi@firstfloor.org;
>> >arjan@infradead.org; jens.axboe@oracle.com; linux-kernel@vger.kernel.org;
>> >Styner, Douglas W; Prickett, Terry O; Wilcox, Matthew R;
>> >netdev@vger.kernel.org; Brandeburg, Jesse
>> >Subject: Re: >10% performance degradation since 2.6.18
>> >
>> >On Mon, Jul 06, 2009 at 10:36:11AM -0700, Ma, Chinang wrote:
>> >> For OLTP workload we are not pushing much network throughput. Lower
>> >network latency is more important for OLTP performance. For the original
>> >Nehalem 2 sockets OLTP result in this mail thread, we bound the two NIC
>> >interrupts to cpu1 and cpu9 (one NIC per sockets). Database processes
>are
>> >divided into two groups and pinned to socket and each processe only
>> >received request from the NIC it bound to. This binding scheme gave us
>>1%
>> >performance boost pre-Nehalem date. We also see positive impact on this
>NHM
>> >system.
>> >
>> >So you've tried spreading the four RX and TX interrupts for each card
>> >out over, say, CPUs 1, 3, 5, 7 for eth1 and then 9, 11, 13, 15 for eth0,
>> >and it produces worse performance than having all four tied to CPUs 1
>> >and 9?  Interesting.
>>
>> I was comparing 2 NIC on 2 sockets to 2 NIC on the same socket. I have
>not tried spreading out the interrupt for a NIC to cpus in the same sockets.
>Is there good reason for trying this?
>
>If spreading the network load from one CPU to two CPUs increases the
>performance, spreading the network load from two to eight might get even
>better performance.
>

On the distributing interrupt load subject.  Can we do the same thing with the IOC interrupts. We have 4 LSI 3801, The number of i/o interrupt is huge on 4 of the cpus. Is there a way to divide the IOC irq number so we can spread out the i/o interrupt to more cpu?


>Are the clients now pinned to the CPU package on which they receive their
>network interrupts?

Yes. The database processes in server are pinning to the socket on which they received network interrupts.

>
>> >Can you try changing IGB_MAX_RX_QUEUES (in drivers/net/igb/igb.h, about
>> >line 60) to 1, and seeing if performance improves that way?
>>
>> I suppose this should wait until we find out whether spread out NIC
>interrupt in socket helps or not.
>
>Yes, let's try having the driver work the way that LAD designed it
>first ;-)
>
>They may not have been optimising for the database client workload,
>of course.
>
>--
>Matthew Wilcox				Intel Open Source Technology Centre
>"Bill, look, we understand that you're interested in selling us this
>operating system, but compare it to ours.  We can't possibly take such
>a retrograde step."
