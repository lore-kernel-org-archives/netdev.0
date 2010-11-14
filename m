From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [PATCH update 2] firewire: net: throttle TX queue before running
 out of tlabels
Date: Sun, 14 Nov 2010 10:25:36 +0100
Message-ID: <4CDFAB10.5050800@s5r6.in-berlin.de>
References: <tkrat.036c5d10fb83f85d@s5r6.in-berlin.de>	 <tkrat.39c164e4c52e2fc8@s5r6.in-berlin.de>	 <tkrat.eaac597cf54bb660@s5r6.in-berlin.de>	 <tkrat.83117f4523f0d928@s5r6.in-berlin.de> <1289710228.8581.16.camel@maxim-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux1394-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Maxim Levitsky <maximlevitsky@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from einhorn.in-berlin.de ([192.109.42.8]:45640 "EHLO
	einhorn.in-berlin.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754823Ab0KNJZv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Nov 2010 04:25:51 -0500
In-Reply-To: <1289710228.8581.16.camel@maxim-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Maxim Levitsky wrote:
> In fact after lot of testing I see that original patch, 
> '[PATCH 4/4] firewire: net: throttle TX queue before running out of
> tlabels' works the best here.
> With AR fixes, I don't see even a single fwnet_write_complete error on
> ether side.

Well, that version missed that the rx path opened up the tx queue again. I.e.
it did not work as intended.

> However the 'update 2' (maybe update 1 too, didn't test), lowers
> desktop->laptop throughput somewhat.
> (250 vs 227 Mbits/s). I tested this many times.
> 
> Actuall raw troughput possible with UDP stream and ether no throttling
> or higher packets in flight count (I tested 50/30), it 280 Mbits/s.

Good, I will test deeper queues with a few different controllers here.  As
long as we keep a margin to 64 so that other traffic besides IPover1394 still
has a chance to acquire transaction labels, it's OK.

> BTW, I still don't understand fully  why my laptop sends only at 180
> Mbits/s pretty much always regardless of patches or TCP/UDP.

If it is not CPU bound, then it is because Ricoh did not optimize the AR DMA
unit as well as Texas Instruments did.
-- 
Stefan Richter
-=====-==-=- =-== -===-
http://arcgraph.de/sr/
