From: David Miller <davem@davemloft.net>
Subject: Re: RDMA will be reverted
Date: Mon, 24 Jul 2006 18:21:08 -0700 (PDT)
Message-ID: <20060724.182108.37154478.davem@davemloft.net>
References: <44C565D1.6070202@hp.com>
	<20060724.174518.52116903.davem@davemloft.net>
	<44C56BFC.7080000@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, rdreier@cisco.com, tom@opengridcomputing.com,
	netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:45250
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932379AbWGYBU5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jul 2006 21:20:57 -0400
To: rick.jones2@hp.com
In-Reply-To: <44C56BFC.7080000@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rick Jones <rick.jones2@hp.com>
Date: Mon, 24 Jul 2006 17:55:24 -0700

> Even enough bits for 1024 or 2048 CPUs in the single system image?  I have seen 
> 1024 touted by SGI, and with things going so multi-core, perhaps 16384 while 
> sounding initially bizzare would be in the realm of theoretically possible 
> before tooooo long.

Read the RSS NDIS documents from Microsoft.  You aren't going to want
to demux to more than, say, 256 cpus for single network adapter even
on the largest machines.

Therefore a simple translation table and/or "base cpu number" is
sufficient to only need 8 bits of cpu identification.

You will be limited by the number of MSI-X vectors also,
for implementations demuxing directly to cpus using MSI-X
selection.

> That would cover TCP, are there similarly fungible fields in SCTP or
> other ULPs?  And if we were to want to get HW support for the thing,
> getting it adopted in a de jure standards body would probably be in
> order :)

Microsoft never does this, neither do we.  LRO came out of our own
design, the network folks found it reasonable and thus they have
started to implement it.  The same is true for Microsofts RSS stuff.

It's a hardware interpretation, therefore it belongs in a driver API
specification, nowhere else.
