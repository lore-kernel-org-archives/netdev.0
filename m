From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [crash] kernel BUG at net/core/dev.c:1328!
Date: Mon, 21 Jul 2008 21:20:20 +0200
Message-ID: <4884E174.5030802@s5r6.in-berlin.de>
References: <20080721134506.GA27598@elte.hu>	<20080721182318.GA20940@elte.hu>	<alpine.LFD.1.10.0807211131390.31863@woody.linux-foundation.org> <20080721.120052.123606398.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, mingo@elte.hu,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from einhorn.in-berlin.de ([192.109.42.8]:52521 "EHLO
	einhorn.in-berlin.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754263AbYGUTUy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 15:20:54 -0400
In-Reply-To: <20080721.120052.123606398.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Linus Torvalds <torvalds@linux-foundation.org>
> Date: Mon, 21 Jul 2008 11:35:21 -0700 (PDT)
> 
>> Maybe the network drivers are few enough that it will get fixed, or
>> maybe the WARN_ON_ONCE() will just be removed and the rule not
>> reinforced.
>>
>> I personally suspect the latter, since it seems to happen with just
>> about _any_ random network driver, including the common and
>> well-maintained ones (ie the Gods only help us for the truly
>> odd/random cases)
> 
> Yes, we'll see how this plays out.
> 
> Ian Schram just posted a patch for the NULL pointer derfer in
> wireless Ingo reported, so we'll see if that bug will be fixed
> now as well.

In the meantime:  Is there perhaps something obviously wrong with 
drivers/ieee1394/eth1394.c's netdevice initialization?  We do it in 
ether1394_add_host(), and shortly thereafter the crashing 
ether1394_host_reset() is called.  So we have essentially

(add host)
	dev = alloc_netdev(...);
	initialize various members in dev...
	register_netdev(dev);

(host reset)
	netif_stop_queue(dev);
	discard some stale 1394 stuff if there were some...
	netif_wake_queue(dev);  <-- crashes in __netif_schedule(dev);

-- 
Stefan Richter
-=====-==--- -=== =-=-=
http://arcgraph.de/sr/
