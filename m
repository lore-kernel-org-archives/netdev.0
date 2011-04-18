From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: r8169 :  always copying the rx buffer to new skb
Date: Mon, 18 Apr 2011 18:27:56 +0100
Message-ID: <1303147676.2857.20.camel@bwh-desktop>
References: <4DAC7001.9060800@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: John Lumby <johnlumby@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:51735 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756117Ab1DRR17 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2011 13:27:59 -0400
In-Reply-To: <4DAC7001.9060800@hotmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-04-18 at 13:08 -0400, John Lumby wrote:
> Summary  -  current r8169 always memcpy's every received buffer to new skb,
>              and I'd like to propose that it should not,
>              which can improve throughput / reduce CPU utilization by 
> around 10%

At least some variants of the hardware have a bug in RX DMA scatter that
can be exploited for denial-of-service.  The workaround is to allocate
huge RX buffers (16K).  Then, to avoid allocation failures later on (and
to save memory) the buffers must be copied rather than passed up the
stack and reallocated.

[...]
> As a second proposal (which I made before),  I'd like to suggest that 
> the number of rx buffers allocated at open should be configurable by 
> module param.
[...]

No, it should implement the ethtool set_ringparam operation.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

