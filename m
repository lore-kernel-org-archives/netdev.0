From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] napi: limit GRO latency
Date: Mon, 08 Oct 2012 15:10:35 -0400 (EDT)
Message-ID: <20121008.151035.1665672334154033755.davem@davemloft.net>
References: <1349718955.21172.3534.camel@edumazet-glaptop>
	<1349719006.21172.3537.camel@edumazet-glaptop>
	<20121008115835.3a3bfed6@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, rick.jones2@hp.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	jesse@nicira.com
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57050 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751172Ab2JHTKi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2012 15:10:38 -0400
In-Reply-To: <20121008115835.3a3bfed6@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 8 Oct 2012 11:58:35 -0700

> Limit the latency of pending GRO in NAPI processing to 2*HZ.
> When the system is under heavy network load, NAPI will go into
> poll mode via soft irq, and only stay in the loop for
> two jiffies. If this occurs, process the GRO pending list
> to make sure and not delay outstanding TCP frames for too long.
> 
> Rearrange the exit path to get rid of unnecessary goto logic.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Did you see Eric's patch I just applied which limits it to 1ms?
