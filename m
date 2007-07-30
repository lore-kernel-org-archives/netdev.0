From: Andrew Gallatin <gallatin@myri.com>
Subject: Re: [PATCH 0/4][RFC] lro: Generic Large Receive Offload for TCP traffic
Date: Mon, 30 Jul 2007 13:43:11 -0400
Message-ID: <46AE232F.3080409@myri.com>
References: <200707301724.33865.ossthema@de.ibm.com> <20070730170038.GA4884@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jan-Bernd Themann <ossthema@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	Thomas Klein <tklein@de.ibm.com>,
	Jeff Garzik <jeff@garzik.org>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Marcus Eder <meder@de.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>,
	David Miller <davem@davemloft.net>
To: Linas Vepstas <linas@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl.myri.com ([64.172.73.26]:1931 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1762704AbXG3Rwc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jul 2007 13:52:32 -0400
In-Reply-To: <20070730170038.GA4884@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Here is a quick reply before something more official can
be written up:

Linas Vepstas wrote:

 > -- what is LRO?

Large Receive Offload

 > -- Basic principles of operation?

LRO is analogous to a receive side version of TSO.  The NIC (or
driver) merges several consecutive segments from the same connection,
fixing up checksums, etc.  Rather than up to 45 separate 1500 byte
frames (meaning up to 45 trips through the network stack), the driver
merges them into one 65212 byte frame.  It currently works only
with TCP over IPv4.

LRO was, AFAIK, first though of by Neterion.  They had a paper about
it at OLS2005.
http://www.linuxinsight.com/files/ols2005/grossman-reprint.pdf

 > -- Can I use it in my driver?

Yes, it can be used in any driver.

 > -- Does my hardware have to have some special feature before I can 
use it?

No.

 > -- What sort of performance improvement does it provide? Throughput?
 >    Latency? CPU usage? How does it affect DMA allocation? Does it
 >    improve only a certain type of traffic (large/small packets, etc.)

The benefit is directly proportional to the packet rate.

See my reply to the previous RFC for performance information.  The
executive summary is that for the myri10ge 10GbE driver on low end
hardware with 1500b frames, I've seen it increase throughput by a
factor of nearly 2.5x, while at the same time reducing CPU utilization
by 17%.  The affect for jumbo frames is less dramatic, but still
impressive (1.10x, 14% CPU reduction)

You can achieve better speedups if your driver receives into
high-order pages.

 > -- Example code? What's the API? How should my driver use it?

The 3/4 in this patch showed an example of converting a driver
to use LRO for skb based receive buffers.   I'm working on
a patch for myri10ge that shows how you would use it in a driver
which receives into pages.

Cheers,

Drew
