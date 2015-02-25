From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] amd-xgbe: Do not schedule napi until ready
Date: Tue, 24 Feb 2015 23:25:32 -0500 (EST)
Message-ID: <20150224.232532.330751855755079647.davem@davemloft.net>
References: <20150224164801.26035.17252.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54057 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751444AbbBYEZf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 23:25:35 -0500
In-Reply-To: <20150224164801.26035.17252.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Tue, 24 Feb 2015 10:48:01 -0600

> It is possible that the ethernet device could not have been properly
> shutdown when Linux begins executing, through firmware use for example.
> Until the amd-xgbe module is loaded, interrupts associated with the
> the device could be pending. Once the module is loaded and interrupts
> are requested, the interrupt could fire right away. If napi support
> has not been initialized then the poll function will be null and result
> in a kernel panic when napi attempts to invoke the poll function. Add
> a check to the interrupt routine to be sure napi has been initialized
> before trying to schedule it.
> 
> Also, move the napi enablement support to be a bit earlier during
> startup and a bit later during shutdown to be certain napi support is
> enabled while the device can perform DMA.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>

This is not how you fix a problem like this.

You should absolutely not request the IRQ for the device, nor should
you enable NAPI, until the device and driver are both fully setup and
able to process those events successfully.

Trust me, you're not the first person to hit this kind of problem.
:-)
