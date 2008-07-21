From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [crash] kernel BUG at net/core/dev.c:1328!
Date: Mon, 21 Jul 2008 23:26:24 +0200
Message-ID: <4884FF00.30101@s5r6.in-berlin.de>
References: <alpine.LFD.1.10.0807211131390.31863@woody.linux-foundation.org>	<20080721.120052.123606398.davem@davemloft.net>	<4884E174.5030802@s5r6.in-berlin.de> <20080721.131129.244101157.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, mingo@elte.hu,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from einhorn.in-berlin.de ([192.109.42.8]:53999 "EHLO
	einhorn.in-berlin.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751783AbYGUV1V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 17:27:21 -0400
In-Reply-To: <20080721.131129.244101157.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> You should only do a netif_stop_queue() in your device
> initialization, at the very end of ->open() processing
> when you've fully committed to returning success.
> 
> You should not, in particular, be doing a netif_wake_queue()
> before you've even done a netif_start_queue().
> 
> Many of these drivers are using netif_{stop,wake}_queue()
> to stop packet flow, in particular when link state changes,
> and netif_carrier_{on,off}() already does all of that for
> you.
> 
> Really, anything outside of:
> 
> 1) netif_start_queue() in ->open()
> 2) netif_stop_queue() in ->stop()
> 3) netif_{stop,wake}_queue() in the TX packet handling path
> 
> is superfluous.

Thanks, I wasn't aware of this.  I'll try to fix up eth1394 this way as 
time permits.
-- 
Stefan Richter
-=====-==--- -=== =-=-=
http://arcgraph.de/sr/
