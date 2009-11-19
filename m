From: "Kumar Gopalpet-B05799" <B05799@freescale.com>
Subject: RE: [RFC] gianfar: multi queue stuff not complete
Date: Thu, 19 Nov 2009 14:22:43 +0530
Message-ID: <9F4C7D19E8361D4C94921B95BE08B81B950E25@zin33exm22.fsl.freescale.net>
References: <4B05019F.4090208@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: "Linux Netdev List" <netdev@vger.kernel.org>
To: "Eric Dumazet" <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:36014 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754013AbZKSIwl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2009 03:52:41 -0500
Received: from az33smr02.freescale.net (az33smr02.freescale.net [10.64.34.200])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id nAJ8qldC008423
	for <netdev@vger.kernel.org>; Thu, 19 Nov 2009 01:52:47 -0700 (MST)
Received: from zin33exm22.fsl.freescale.net (zin33exm22.ap.freescale.net [10.232.192.20])
	by az33smr02.freescale.net (8.13.1/8.13.0) with ESMTP id nAJ8qkL4020101
	for <netdev@vger.kernel.org>; Thu, 19 Nov 2009 02:52:47 -0600 (CST)
Content-class: urn:content-classes:message
In-Reply-To: <4B05019F.4090208@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
>I noticed gianfar got multiqueue support recently, but it 
>still updates dev->stats.{tx_bytes|tx_packets|tx_dropped} 
>without proper locking (several cpus could update stats at 
>same time while xmitting on different tx queues)
>
>It should use txq->{tx_bytes|tx_packets|tx_dropped} to avoid 
>wrong tx stats
>
>
>I cooked following preliminar patch but its only for 
>discussion, because I dont know yet how to transform 
>dev->stats.tx_dropped++; in gfar_error(), and also because I 
>cannot compile this driver on my dev machine.
>
>(if a driver uses txq->tx... counters, it must not use any 
>dev->stats.{tx_bytes|tx_packets|tx_dropped}
>that are overwritten by dev_txq_stats_fold(). Or we could 
>change dev_txq_stats_fold() logic to get a mask of what fields 
>a drivers updates in txq-> or dev->stats
>
>

Eric, Yes I agree that still there are a couple of changes left and I am
working on it.
One of them being the stats. Currently caught up in something else, I
will update them ASAP.

Also, suggest me on what kind of stats do I need to maintain ? Both per
device and per queue
or only per queue would be sufficient ?


--

Thanks
Sandeep
