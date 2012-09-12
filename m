From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net-sched: sch_cbq: avoid infinite loop
Date: Tue, 11 Sep 2012 22:21:31 -0400 (EDT)
Message-ID: <20120911.222131.2305298175633650636.davem@davemloft.net>
References: <ceeee25e4588b250ce7b363afe97a489@visp.net.lb>
	<1347405072.13103.675.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: denys@visp.net.lb, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51104 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757410Ab2ILCVg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2012 22:21:36 -0400
In-Reply-To: <1347405072.13103.675.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 12 Sep 2012 01:11:12 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Its possible to setup a bad cbq configuration leading to
> an infinite loop in cbq_classify()
> 
> DEV_OUT=eth0
> ICMP="match ip protocol 1 0xff"
> U32="protocol ip u32"
> DST="match ip dst"
> tc qdisc add dev $DEV_OUT root handle 1: cbq avpkt 1000 \
> 	bandwidth 100mbit
> tc class add dev $DEV_OUT parent 1: classid 1:1 cbq \
> 	rate 512kbit allot 1500 prio 5 bounded isolated
> tc filter add dev $DEV_OUT parent 1: prio 3 $U32 \
> 	$ICMP $DST 192.168.3.234 flowid 1:
> 
> Reported-by: Denys Fedoryschenko <denys@visp.net.lb>
> Tested-by: Denys Fedoryschenko <denys@visp.net.lb>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks Eric.
