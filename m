From: Veaceslav Falico <vfalico@gmail.com>
Subject: Re: [patch] bonding: fix a memory leak in bond_arp_send_all()
Date: Fri, 25 Jul 2014 14:24:32 +0200
Message-ID: <20140725122432.GA28747@mikrodark.usersys.redhat.com>
References: <20140725122121.GC528@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f180.google.com ([74.125.82.180]:51572 "EHLO
	mail-we0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752165AbaGYM1b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2014 08:27:31 -0400
Content-Disposition: inline
In-Reply-To: <20140725122121.GC528@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 25, 2014 at 03:21:21PM +0300, Dan Carpenter wrote:
>This test is reversed so the memory is always leaked.  It's better style
>to remove the test anyway.
>
>Fixes: 3e403a77779f ('bonding: make it possible to have unlimited nested upper vlans')
>Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Indeed, dunno how I've missed that. And kfree() verifies for the NULL
situation.

Acked-by: Veaceslav Falico <vfalico@gmail.com>

>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 023ec36..f0f5eab 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -2287,8 +2287,7 @@ found:
> 		ip_rt_put(rt);
> 		bond_arp_send(slave->dev, ARPOP_REQUEST, targets[i],
> 			      addr, tags);
>-		if (!tags)
>-			kfree(tags);
>+		kfree(tags);
> 	}
> }
>
