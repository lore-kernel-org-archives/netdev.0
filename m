From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v7] bfin_mac: convert bfin Ethernet driver to NAPI
 framework
Date: Tue, 22 Jul 2014 01:01:05 -0700 (PDT)
Message-ID: <20140722.010105.2036198226851589509.davem@davemloft.net>
References: <1406014682-19188-1-git-send-email-sonic.adi@gmail.com>
	<1406015984.10255.121.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sonic.adi@gmail.com, netdev@vger.kernel.org, romieu@fr.zoreil.com,
	adi-buildroot-devel@lists.sourceforge.net, sonic.zhang@analog.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42705 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753070AbaGVIBJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 04:01:09 -0400
In-Reply-To: <1406015984.10255.121.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 22 Jul 2014 09:59:44 +0200

> On Tue, 2014-07-22 at 15:38 +0800, Sonic Zhang wrote:
>> From: Sonic Zhang <sonic.zhang@analog.com>
> 
>> +	if (i < budget) {
>> +		napi_complete(napi);
>> +		if (lp->rx_irq_disabled--)
>> +			if (!lp->rx_irq_disabled)
>> +				enable_irq(IRQ_MAC_RX);
> 
> 
> You wrote :
> 
> 	if (A--)
> 		if (!A)
> 			something();
> 
> Isnt a bit strange ???

Indeed, it's very strange, how about:

	if (!--lp->rx_irq_disabled)

which is the canonical way to express this.
