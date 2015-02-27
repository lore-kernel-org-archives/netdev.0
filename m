From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] amd-xgbe: Request IRQs only after driver is fully
 setup
Date: Fri, 27 Feb 2015 17:13:20 -0500 (EST)
Message-ID: <20150227.171320.1659341988981769664.davem@davemloft.net>
References: <20150225195012.17171.35178.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54644 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755328AbbB0WNW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 17:13:22 -0500
In-Reply-To: <20150225195012.17171.35178.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Wed, 25 Feb 2015 13:50:12 -0600

> It is possible that the hardware may not have been properly shutdown
> before this driver gets control, through use by firmware, for example.
> Until the driver is loaded, interrupts associated with the hardware
> could go pending. When the IRQs are requested napi support has not
> been initialized yet, but the ISR will get control and schedule napi
> processing resulting in a kernel panic because the poll routine has not
> been set.
> 
> Adjust the code so that the driver is fully ready to handle and process
> interrupts as soon as the IRQs are requested. This involves requesting
> and freeing IRQs during start and stop processing and ordering the napi
> add and delete calls appropriately.
> 
> Also adjust the powerup and powerdown routines to match the start and
> stop routines in regards to the ordering of tasks, including napi
> related calls.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>

This looks a lot better, applied, thanks Tom.
