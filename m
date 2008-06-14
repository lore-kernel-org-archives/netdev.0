From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: page allocation failure
Date: Sat, 14 Jun 2008 22:36:02 +0100
Message-ID: <20080614213600.GF11300@solarflare.com>
References: <20080614022451.M72462@visp.net.lb> <20080614065845.GB32585@2ka.mipt.ru> <20080614205958.M55299@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:41388 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754734AbYFNVik (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jun 2008 17:38:40 -0400
Content-Disposition: inline
In-Reply-To: <20080614205958.M55299@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryshchenko wrote:
> There is no jumbo frames in this particular setup.
> Probably it is getting out of memory (rtorrent using almost all for fs caching
> maybe).
[...]

The "order: 3" means an allocation of 8 pages (32 KB) at once, which
should not be needed for receiving standard Ethernet frames.  Looking
at the bnx2 code I can't see any case in which it would allocate an
skb much larger than the MTU.

Network drivers usually try to refill the hardware RX ring immediately
after handling RX completions, at which point they are running in atomic
(non-blocking) context and large contiguous memory allocations are
relatively likely to fail even if the system has plenty of memory.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
