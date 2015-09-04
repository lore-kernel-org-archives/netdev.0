From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] r8169: fix sleepable allocation during
 netdevice stats retrieval.
Date: Fri, 04 Sep 2015 15:22:23 -0700 (PDT)
Message-ID: <20150904.152223.1146732101537643393.davem@davemloft.net>
References: <55E9A518.3080906@gmail.com>
	<20150904.113657.2146226970417029162.davem@davemloft.net>
	<20150904205904.GA32346@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pomidorabelisima@gmail.com, netdev@vger.kernel.org,
	vinschen@redhat.com
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54504 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759298AbbIDWW0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Sep 2015 18:22:26 -0400
In-Reply-To: <20150904205904.GA32346@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Fri, 4 Sep 2015 22:59:04 +0200

> net/core/net-sysfs.c::netstat_show fetches statistics under dev_base_lock.
> 
> Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=104031
> Fixes: 6e85d5ad36a2 ("r8169: Add values missing in @get_stats64 from HW counters")
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Cc: Corinna Vinschen <vinschen@redhat.com>

Is there any reason we cannot allocate this DMA buffer at probe or
open time?

There cannot be any arguments concerning parallel access as far
as I can see, there is a single set of registers to program
this address into therefore we cannot allow more than one entity
to get into the counter fetch sequence at the same time anyways.
