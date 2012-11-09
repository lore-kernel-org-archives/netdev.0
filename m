From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gianfar: ethernet vanishes after restoring from
 hibernation
Date: Fri, 09 Nov 2012 17:08:59 -0500 (EST)
Message-ID: <20121109.170859.796967518373395470.davem@davemloft.net>
References: <1352181848-24102-1-git-send-email-dongsheng.wang@freescale.com>
	<1352472231-17927-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dongsheng.wang@freescale.com,
	claudiu.manoil@freescale.com
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38863 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756098Ab2KIWJB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2012 17:09:01 -0500
In-Reply-To: <1352472231-17927-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Fri,  9 Nov 2012 09:43:51 -0500

> From: Wang Dongsheng <dongsheng.wang@freescale.com>
> 
> If a gianfar ethernet device is down prior to hibernating a
> system, it will no longer be present upon system restore.
> 
> For example:
> 
> 	~# ifconfig eth0 down
> 	~# echo disk > /sys/power/state
> 
> 	  <trigger a restore from hibernation>
> 
> 	~# ifconfig eth0 up
> 	SIOCSIFFLAGS: No such device
> 
> This happens because the restore function bails out early upon
> finding devices that were not up at hibernation.  In doing so,
> it never gets to the netif_device_attach call at the end of
> the restore function.  Adding the netif_device_attach as done
> here also makes the gfar_restore code consistent with what is
> done in the gfar_resume code.
> 
> Cc: Claudiu Manoil <claudiu.manoil@freescale.com>
> Signed-off-by: Wang Dongsheng <dongsheng.wang@freescale.com>
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

Applied, thanks.
