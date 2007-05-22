From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: intermittant petabyte usage reported with broadcom nic
Date: Mon, 21 May 2007 18:15:04 -0700
Message-ID: <1179796504.1661.152.camel@dell>
References: <20070402014319.GA8345@zip.com.au>
 <20070402001300.3b66007d.akpm@linux-foundation.org>
 <20070402074108.GB8345@zip.com.au> <1176596401.5847.7.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, "netdev" <netdev@vger.kernel.org>
To: "CaT" <cat@zip.com.au>, jd@disjunkt.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4789 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754958AbXEVA00 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 May 2007 20:26:26 -0400
In-Reply-To: <1176596401.5847.7.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2 Apr 2007 11:43:19 +1000 CaT <cat@zip.com.au> wrote:
>  
> I take minute by minute snapshots of network traffic by sampling
> /proc/net/dev and most of the time everything works fine. Occasionally
> though I get petabyte byte traffic and corresponding packet traffic.

We were able to reproduce the problem and confirmed that it was a DMA
problem of the statistics block.  About once an hour on average, wrong
counter values will be DMA'ed to host memory.  Luckily, the DMA write
stays within the intended address range so it will not corrupt other
parts of memory.  Other types of DMA including traffic and buffer
descriptors are not affected.

If you happen to be reading /proc/net/dev within a second after the DMA
corruption, you'll see bogus counters.  One second later and until the
next bad DMA, the counters will be normal again.

We are considering ways to workaround the problem.  Thanks.

