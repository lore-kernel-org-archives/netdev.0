From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: RFC [PATCH net-2.6 1/6] net: Scheduling softirqs between CPUSs
Date: Mon, 10 Mar 2008 18:06:30 -0700
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F52049D5CE5@orsmsx418.amr.corp.intel.com>
References: <20080305205116.5989A412541@localhost> <20080305.132112.01598419.davem@davemloft.net> <47D19147.9070609@qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <therbert@google.com>, <netdev@vger.kernel.org>,
	"Steven Rostedt" <rostedt@goodmis.org>,
	"Ingo Molnar" <mingo@elte.hu>
To: "Max Krasnyanskiy" <maxk@qualcomm.com>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:8517 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750967AbYCKBGc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2008 21:06:32 -0400
Content-class: urn:content-classes:message
In-Reply-To: <47D19147.9070609@qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Max Krasnyanskiy wrote:
> David Miller wrote:
>> From: therbert@google.com (Tom Herbert)
>> Date: Wed,  5 Mar 2008 12:51:16 -0800 (PST)
>> 
>>> This patch implements kernel changes to allow scheduling of
>>> softirq's between processors. 
>>> 
>>> Signed-off-by: Tom Herbert <therbert@google.com>
>> 
>> I've stated this in the past and I still feel that it is foolish to
>> put all of this code into the kernel when every single piece of
>> networking hardware will be doing this for us transparently.
>> 
>> Maybe if someone had proposed this 4 or 5 years ago, but right now
>> this code will be irrelevant by the time it ships to any real users.
> 
> Plus it seems that for this kind of stuff it be better to replace
> network softirq with kthreads (like in -rt kernel) and let the
> scheduler take care of the load balancing. More flexible and scalable.
> I'd suggest for your to play with -rt kernel and see if it already
> does what you need.

Could we use something like this to reschedule NAPI onto other
processors?  If we get unlucky enough to have multiple napi routines
polling on a single CPU, and one or more completely idle CPUs (idle at
least for softirq) then we could really use one or the other of these
solutions.

anyone know how -rt kernels work for high I/O load environments like 10
Gigabit Ethernet?

Jesse
