From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5] bfin_mac: convert bfin Ethernet driver to NAPI
 framework
Date: Wed, 16 Jul 2014 14:03:01 -0700 (PDT)
Message-ID: <20140716.140301.896018835447121717.davem@davemloft.net>
References: <1405504302-21344-1-git-send-email-sonic.adi@gmail.com>
	<1405516649.10255.59.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sonic.adi@gmail.com, netdev@vger.kernel.org,
	varkabhadram@gmail.com, adi-buildroot-devel@lists.sourceforge.net,
	sonic.zhang@analog.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54758 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750854AbaGPVDF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2014 17:03:05 -0400
In-Reply-To: <1405516649.10255.59.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 16 Jul 2014 15:17:29 +0200

> On Wed, 2014-07-16 at 17:51 +0800, Sonic Zhang wrote:
>> From: Sonic Zhang <sonic.zhang@analog.com>
>> +	if (i < budget) {
>> +		napi_gro_flush(napi, false);
>> +		local_irq_save(flags);
>> +		__napi_complete(napi);
>> +		local_irq_restore(flags);
>> +		enable_irq(IRQ_MAC_RX);
> 
> I have no idea why you open-code napi_complete();
> 
> Why cant you just copy/paste what other drivers do here ?
> 
> 	if (i < budget) {
> 		napi_complete(napi);
> 		enable_irq(IRQ_MAC_RX);
> 	}

Generally speaking, I am very frustrated at how this bfin_mac NAPI
conversion tries to do things in special ways.

Please mimick what other drivers do rather than trying to do things in
a special way unique to your driver.
