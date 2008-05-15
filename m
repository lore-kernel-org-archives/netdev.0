From: Patrick McHardy <kaber@trash.net>
Subject: Re: NET_SCHED cbq dropping too many packets on a bonding interface
Date: Thu, 15 May 2008 20:32:44 +0200
Message-ID: <482C81CC.7000305@trash.net>
References: <20080515091216.GA6550@ff.dom.local> <8ECDBB4EB5394859BFFACAAEE3A6EDB0@uglypunk> <482C6040.9030808@trash.net> <20080515182504.GB2936@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kingsley Foreman <kingsley@internode.com.au>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50014 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756180AbYEOScq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2008 14:32:46 -0400
In-Reply-To: <20080515182504.GB2936@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Thu, May 15, 2008 at 06:09:36PM +0200, Patrick McHardy wrote:
> ...
>> Do things improve if you set txqueuelen to a larger value
>> *before* configuring the qdiscs?
> 
> BTW, I hope it was *before*, but since pfifo_fast_enqueue() uses
> "qdisc->dev->tx_queue_len" does it really matter? (Until it's
> before the test of course...)


Yes, CBQ uses pfifo, not pfifo_fast. pfifo uses txqueuelen
to inialize q->limit, but thats whats used during ->enqueue().
