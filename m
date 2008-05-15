From: Patrick McHardy <kaber@trash.net>
Subject: Re: NET_SCHED cbq dropping too many packets on a bonding interface
Date: Thu, 15 May 2008 18:09:36 +0200
Message-ID: <482C6040.9030808@trash.net>
References: <20080515091216.GA6550@ff.dom.local> <8ECDBB4EB5394859BFFACAAEE3A6EDB0@uglypunk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Kingsley Foreman <kingsley@internode.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46285 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759889AbYEOQJi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2008 12:09:38 -0400
In-Reply-To: <8ECDBB4EB5394859BFFACAAEE3A6EDB0@uglypunk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kingsley Foreman wrote:
> i just rolled back the kernel to 2.6.24 and im seeing the same thing,
> 
> I was using 2.6.22 before and didn't see the problem, txqueuelen on the 
> bond0 interface is 0 (the default)

That might explain things, although it shouldn't have worked before
either.

CBQ creates default pfifo qdiscs for its leaves, these use a limit
of txqueuelen or 1 if it is zero. So even small bursts will cause
drops. Do things improve if you set txqueuelen to a larger value
*before* configuring the qdiscs?

Another thing is that CBQ on bond will probably not work properly
at all, it needs a real device since it measures the timing between
dequeue events for idle time estimation. On software devices this
doesn't work.
