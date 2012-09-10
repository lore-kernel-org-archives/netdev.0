From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] ixp4xx_hss: fix build failure due to missing
 linux/module.h inclusion
Date: Mon, 10 Sep 2012 16:15:43 -0400 (EDT)
Message-ID: <20120910.161543.255714089600943802.davem@davemloft.net>
References: <1347278818-6913-1-git-send-email-florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, khc@pm.waw.pl, joe@perches.com,
	stable@vger.kernel.org
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33424 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754626Ab2IJUPp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2012 16:15:45 -0400
In-Reply-To: <1347278818-6913-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian@openwrt.org>
Date: Mon, 10 Sep 2012 14:06:58 +0200

> Commit 36a1211970193ce215de50ed1e4e1272bc814df1 (netprio_cgroup.h:
> dont include module.h from other includes) made the following build
> error on ixp4xx_hss pop up:
> 
>   CC [M]  drivers/net/wan/ixp4xx_hss.o
>  drivers/net/wan/ixp4xx_hss.c:1412:20: error: expected ';', ',' or ')'
>  before string constant
>  drivers/net/wan/ixp4xx_hss.c:1413:25: error: expected ';', ',' or ')'
>  before string constant
>  drivers/net/wan/ixp4xx_hss.c:1414:21: error: expected ';', ',' or ')'
>  before string constant
>  drivers/net/wan/ixp4xx_hss.c:1415:19: error: expected ';', ',' or ')'
>  before string constant
>  make[8]: *** [drivers/net/wan/ixp4xx_hss.o] Error 1
> 
> This was previously hidden because ixp4xx_hss includes linux/hdlc.h which
> includes linux/netdevice.h which includes linux/netprio_cgroup.h which
> used to include linux/module.h. The real issue was actually present since
> the initial commit that added this driver since it uses macros from
> linux/module.h without including this file.
> 
> Signed-off-by: Florian Fainelli <florian@openwrt.org>

Applied and queued up for -stable, thanks.
