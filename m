From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: ixgbe: [RFC] [PATCH] Fix return of invalid txq
Date: Sat, 16 Jan 2010 02:53:15 -0800
Message-ID: <F86E8680A7D9D74A99DC6345E35A6929501BA2CA@orsmsx503.amr.corp.intel.com>
References: <F86E8680A7D9D74A99DC6345E35A692950158650@orsmsx503.amr.corp.intel.com>
	<20100115.004456.15627093.davem@davemloft.net>
	<1263546020.2038.7.camel@localhost>
 <20100115.010628.67106329.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "krkumar2@in.ibm.com" <krkumar2@in.ibm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:41801 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751572Ab0APKxe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Jan 2010 05:53:34 -0500
In-Reply-To: <20100115.010628.67106329.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: David Miller [mailto:davem@davemloft.net]
>Sent: Friday, January 15, 2010 1:06 AM
>To: Waskiewicz Jr, Peter P
>Cc: krkumar2@in.ibm.com; netdev@vger.kernel.org; Kirsher, Jeffrey T
>Subject: Re: ixgbe: [RFC] [PATCH] Fix return of invalid txq
>
>From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
>Date: Fri, 15 Jan 2010 01:00:20 -0800
>
>> What I've been thinking of is more for the NUMA allocations per port.
>> If we have, say 2 sockets, 8 cores a piece, then we have 16 CPUs.  If
>we
>> assign a port to socket 0, I think the best use of resources is to
>> allocate 8 Rx/Tx queues, one per core in that socket.  If an
>application
>> comes from the other socket, we can have a table to map the other 8
>> cores from that socket into the 8 queues, instead of piling them all
>> into one of the Tx queues.
>
>I fail to see how this can act substantially better than simply
>feeding traffic evenly amongst whatever group of queues have
>been configured.

On systems with a large number of cores, and depending on how a NIC is allocated to a set of processors, there is a difference.  If a port is allocated to socket three on a large NUMA system, then it could be CPUs 16-23 that it'd be using, and I'd have 8 Tx/Rx queues.  I can either use the easy approach Krishna has, which could then execute two minus operations, or I can setup a lookup table in the driver on open(), and then I make a single indexed lookup.  Using the lookup table makes the queue selection O(1) for whatever CPU/queue layout we come up with.

Either way works though.  I still think the table is the better way to go, because of the determinism for any system and NIC configuration/layout.  The overhead of configuring the table is taken during open(), so it's not in the hotpath at all.

Cheers,
-PJ
