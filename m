From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] loopback: packet drops accounting
Date: Fri, 17 Apr 2009 01:59:14 -0700 (PDT)
Message-ID: <20090417.015914.09817926.davem@davemloft.net>
References: <49E78DE5.10104@hartkopp.net>
	<20090417.013853.04495551.davem@davemloft.net>
	<49E84459.1060507@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50020
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759884AbZDQI7X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 04:59:23 -0400
In-Reply-To: <49E84459.1060507@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 17 Apr 2009 10:56:57 +0200

> We can in some situations drop packets in netif_rx()
> 
> loopback driver does not report these (unlikely) drops to its stats,
> and incorrectly change packets/bytes counts.
> 
> After this patch applied, "ifconfig lo" can reports these drops as in :
> 
> # ifconfig lo
> lo        Link encap:Local Loopback
>           inet addr:127.0.0.1  Mask:255.0.0.0
>           UP LOOPBACK RUNNING  MTU:16436  Metric:1
>           RX packets:692562900 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:692562900 errors:3228 dropped:3228 overruns:0 carrier:0
>           collisions:0 txqueuelen:0
>           RX bytes:2865674174 (2.6 GiB)  TX bytes:2865674174 (2.6 GiB)
> 
> I chose to reflect those errors only in tx_dropped/tx_errors, and not mirror
> these errors in rx_dropped/rx_errors.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Well, logically the receive is what failed, not the transmit.

I think it's therefore misleading to count it as a TX drop.

Do you feel strongly about this?
