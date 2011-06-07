From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: cpu offline cause napi stall
Date: Tue, 07 Jun 2011 01:01:36 -0700 (PDT)
Message-ID: <20110607.010136.1857896380762569754.davem@davemloft.net>
References: <20110601204233.GA2410@osiris.boeblingen.de.ibm.com>
	<20110606.145051.267562411413352856.davem@davemloft.net>
	<1307429403.2642.77.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: heiko.carstens@de.ibm.com, blaschka@linux.vnet.ibm.com,
	netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54394 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751499Ab1FGIBn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2011 04:01:43 -0400
In-Reply-To: <1307429403.2642.77.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 07 Jun 2011 08:50:03 +0200

> From: Heiko Carstens <heiko.carstens@de.ibm.com>
> 
> Frank Blaschka reported :
> <quote>
>   During heavy network load we turn off/on cpus.
>   Sometimes this causes a stall on the network device.
>   Digging into the dump I found out following:
> 
>   napi is scheduled but does not run. From the I/O buffers
>   and the napi state I see napi/rx_softirq processing has stopped
>   because the budget was reached. napi stays in the
>   softnet_data poll_list and the rx_softirq was raised again.
> 
>   I assume at this time the cpu offline comes in,
>   the rx softirq is raised/moved to another cpu but napi stays in the
>   poll_list of the softnet_data of the now offline cpu.
> 
>   Reviewing dev_cpu_callback (net/core/dev.c) I did not find the
>   poll_list is transfered to the new cpu.
> </quote>
> 
> This patch is a straightforward implementation of Frank suggestion :
> 
> Transfert poll_list and trigger NET_RX_SOFTIRQ on new cpu.
> 
> Reported-by: Frank Blaschka <blaschka@linux.vnet.ibm.com>
> Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Tested-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks everyone.
