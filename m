From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: Why are network counters only updated once a second?
Date: Mon, 14 Jan 2008 14:31:49 -0800
Message-ID: <1200349909.15122.31.camel@dell>
References: <478BC662.6030004@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev" <netdev@vger.kernel.org>
To: "Mark Seger" <Mark.Seger@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4085 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755821AbYANVpG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jan 2008 16:45:06 -0500
In-Reply-To: <478BC662.6030004@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-01-14 at 15:30 -0500, Mark Seger wrote:

> Eventually the frequency became better aligned at a 1 second interval 
> because now the number look better, but the problem I see is that when 
> the sampling interval is very close to the monitoring interval you still 
> get periodic incorrect data.  Furthermore, you now need to know which 
> way the counters are updated before you pick a sampling interval!  But 
> the real point is if anyone ever wants to do finer grained monitoring, 
> say every 1/2 or even tenth of a second, they can't because the counters 
> won't change between samples.  Has this ever been discussed before?

On most Broadcom NICs, the statistics counters are periodically DMA'ed
from the chip and the default interval is roughly 1 second.  On most of
these chips, you can override this interval using ethtool -C eth0.

As I mentioned earlier, the 5706/5708 has a bug in the statistics DMA
engine that can corrupt counters from time to time.  The workaround is
effective, but you now lose the ability to control the DMA interval.

