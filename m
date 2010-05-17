From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH -next] bridge: fix build for CONFIG_SYSFS disabled
Date: Mon, 17 May 2010 10:56:54 -0700
Message-ID: <20100517105654.2451e61f@nehalam>
References: <20100517163521.649526d0.sfr@canb.auug.org.au>
 <20100517091756.e232bdc2.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, davem@davemloft.net
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60722 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751657Ab0EQR5F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 May 2010 13:57:05 -0400
In-Reply-To: <20100517091756.e232bdc2.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 17 May 2010 09:17:56 -0700
Randy Dunlap <randy.dunlap@oracle.com> wrote:

> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> Fix build when CONFIG_SYSFS is not enabled:
> 
> net/bridge/br_if.c:136: error: 'struct net_bridge_port' has no member named 'sysfs_name'
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
> ---
>  net/bridge/br_if.c |    2 ++
>  1 file changed, 2 insertions(+)
> 
> --- linux-next-20100517.orig/net/bridge/br_if.c
> +++ linux-next-20100517/net/bridge/br_if.c
> @@ -133,7 +133,9 @@ static void del_nbp(struct net_bridge_po
>  	struct net_bridge *br = p->br;
>  	struct net_device *dev = p->dev;
>  
> +#ifdef CONFIG_SYSFS
>  	sysfs_remove_link(br->ifobj, p->sysfs_name);
> +#endif
>  
>  	dev_set_promiscuity(dev, -1);
>  

I don't like peppering code with #ifdef like this.

Turns out that in this place sysfs_name is always the same
as the device name so instead:


--- a/net/bridge/br_if.c	2010-05-17 10:40:49.808031840 -0700
+++ b/net/bridge/br_if.c	2010-05-17 10:49:47.767669246 -0700
@@ -133,7 +133,7 @@ static void del_nbp(struct net_bridge_po
 	struct net_bridge *br = p->br;
 	struct net_device *dev = p->dev;
 
-	sysfs_remove_link(br->ifobj, p->sysfs_name);
+	sysfs_remove_link(br->ifobj, p->dev->name);
 
 	dev_set_promiscuity(dev, -1);
 


-- 
