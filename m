From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: ixgbe: 82599 and Westmere with HT
Date: Fri, 18 Feb 2011 15:18:40 -0800 (Pacific Standard Time)
Message-ID: <alpine.WNT.2.00.1102181506420.5424@JBRANDEB-DESK2.amr.corp.intel.com>
References: <AANLkTi=1d8aJoFU7gsNy-sYjJomGp-Xz4K+ddKSOk-ir@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Andrew Dickinson <andrew@whydna.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:34943 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754900Ab1BRXTD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Feb 2011 18:19:03 -0500
In-Reply-To: <AANLkTi=1d8aJoFU7gsNy-sYjJomGp-Xz4K+ddKSOk-ir@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 16 Feb 2011, Andrew Dickinson wrote:
> I've got a dual Westmere board (X5675) with an X520 card with dual
> 10G.  I see 24-cores exposed to me and the ixgbe driver exposes 24 tx
> and 24 rx interrupts per NIC.  I then pin the interrupts to cores for
> each NIC (each interrupt gets its own core, standard stuff).

we have a script for that in our standalone driver package at sourceforge 
called set_irq_affinity.sh, fyi.
 
> Anyway.... I'm only seeing RX interrupts on 16 of the 24 cores (random
> src/dest pairs across a /16 each, so I should be getting good flow
> hashing).  Did I miss some magic somewhere?

the way our hardware works is by first looking for a flow director table 
match for the flow (only support TCP flows, no UDP or IP only) and then it 
falls back to using RSS (only supports 16 queues)
 
> I'm running 2.6.32.4, perhaps this has been fixed upstream.  If not,
> any thoughts on how to make this work?

if the adapter port in question isn't transmittinng any packets then the 
flow director will not have any transmits to use to set up the symmetric 
"receive flows".  The latest drivers from sourceforge have the fix to 
update the flow director tables with every transmit, and net-next has it 
too now[1].

hope this helps, 
Jesse

[1] 
http://git.kernel.org/?p=linux/kernel/git/davem/net-next-2.6.git;a=commit;h=69830529b26e6dc9582a4b65ab88f40f050cf94e



