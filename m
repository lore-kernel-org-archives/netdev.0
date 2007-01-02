From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Network card IRQ balancing with Intel 5000 series chipsets
Date: Tue, 02 Jan 2007 09:56:53 -0800
Message-ID: <459A9CE5.8020403@hp.com>
References: <7e63f56c0612240134s452f6510h8483fb31e5efe799@mail.gmail.com>	<1167039303.3281.1574.camel@laptopd505.fenrus.org>	<7e63f56c0612250326td172f28n532435b23d18b69f@mail.gmail.com>	<1167046499.3281.1623.camel@laptopd505.fenrus.org>	<7e63f56c0612250454g5520bd6aja0fb9ab2656ff74e@mail.gmail.com>	<1167158658.3746.12.camel@localhost>	<7e63f56c0612261151y7aa95954hb2a1d47ce130c38d@mail.gmail.com> <1167171089.3746.23.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Robert Iakobashvili <coroberti@gmail.com>,
	Arjan van de Ven <arjan@infradead.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel11.hp.com ([156.153.255.246]:52220 "EHLO palrel11.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932684AbXABR5o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Jan 2007 12:57:44 -0500
To: hadi@cyberus.ca
In-Reply-To: <1167171089.3746.23.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> The best way to achieve such balancing is to have the network card help
> and essentially be able to select the CPU to notify while at the same
> time considering:
> a) avoiding any packet reordering - which restricts a flow to be
> processed to a single CPU at least within a timeframe
> b) be per-CPU-load-aware - which means to busy out only CPUs which are
> less utilized
> 
> Various such schemes have been discussed here but no vendor is making
> such nics today (search Daves Blog - he did discuss this at one point or
> other).

I thought that Neterion were doing something along those lines with 
their Xframe II NICs - perhaps not CPU loading aware, but doing stuff to 
spread the work of different connections across the CPUs.

I would add a:

c) some knowledge of the CPU on which the thread accessing the socket 
for that "connection" will run.  This could be as simple as the CPU on 
which the socket was last accessed.  Having a _NIC_ know this sort of 
thing is somewhat difficult and expensive (perhaps too much so).  If a 
NIC simply hashes the connection idendifiers you then have the issue of 
different connections, each "owned/accessed" by one thread, taking 
different paths through the system.  No issues about reordering, but 
perhaps some on cache lines going hither and yon.

The question boils down to - Should the application (via the scheduler) 
dictate where its connections are processed, or should the connections 
dictate where the application runs?

rick jones

