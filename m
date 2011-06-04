From: David Miller <davem@davemloft.net>
Subject: Re: small RPS cache for fragments?
Date: Sat, 04 Jun 2011 13:29:40 -0700 (PDT)
Message-ID: <20110604.132940.2214949964968775365.davem@davemloft.net>
References: <20110517.143342.1566027350038182221.davem@davemloft.net>
	<20110524.160123.2051949867829317339.davem@davemloft.net>
	<1306273128.8149.1444.camel@tardy>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34208 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753201Ab1FDU3q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jun 2011 16:29:46 -0400
In-Reply-To: <1306273128.8149.1444.camel@tardy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>
Date: Tue, 24 May 2011 14:38:48 -0700

> Isn't there still an issue (perhaps small) of traffic being sent through
> a mode-rr bond, either at the origin or somewhere along the way?  At the
> origin point will depend on the presence of UFO and whether it is
> propagated up through the bond interface, but as a quick test, I
> disabled TSO, GSO and UFO on four e1000e driven interfaces, bonded them
> mode-rr and ran a netperf UDP_RR test with a 1473 byte request size and
> this is what they looked like at my un-bonded reciever at the other end:
> 
> 14:31:01.011370 IP (tos 0x0, ttl 64, id 24960, offset 1480, flags
> [none], proto UDP (17), length 21)
>     tardy.local > raj-8510w.local: udp
> 14:31:01.011420 IP (tos 0x0, ttl 64, id 24960, offset 0, flags [+],
> proto UDP (17), length 1500)
>     tardy.local.36073 > raj-8510w.local.59951: UDP, length 1473
> 14:31:01.011514 IP (tos 0x0, ttl 64, id 0, offset 0, flags [DF], proto
> UDP (17), length 29)
>     raj-8510w.local.59951 > tardy.local.36073: UDP, length 1

That's not good behavior, and it's of course going to cause sub-optimal
performance if we do the RPS fragment cache.

RR bond mode could do something similar, to alleviate this.

I assume it doesn't do this kind of reordering for TCP.
