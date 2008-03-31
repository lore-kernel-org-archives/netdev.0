From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: Tree for March 29
Date: Mon, 31 Mar 2008 00:28:36 -0700 (PDT)
Message-ID: <20080331.002836.159833482.davem@davemloft.net>
References: <20080329223354.304e2722.sfr@canb.auug.org.au>
	<20080329191255.7312e036@hskinnemo-gx620.norway.atmel.com>
	<20080330135502.ee27f8a4.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: haavard.skinnemoen@atmel.com, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-ide@vger.kernel.org,
	netdev@vger.kernel.org
To: sfr@canb.auug.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46896
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752556AbYCaH2h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2008 03:28:37 -0400
In-Reply-To: <20080330135502.ee27f8a4.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Sun, 30 Mar 2008 13:55:02 +1100

> Hi Haavard,
> 
> On Sat, 29 Mar 2008 19:12:55 +0100 Haavard Skinnemoen <haavard.skinnemoen@atmel.com> wrote:
> >
> > allnoconfig fails with
> > 
> > include/linux/netdevice.h:843: error: implicit declaration of function 'dev_net'
> > 
> > which seems to be because the definition of dev_net is inside #ifdef
> > CONFIG_NET, while next_net_device, which calls it, is not.
> 
> Thanks for tracking these down.

I've checked in the following to net-2.6.26 to fix this, thanks:

commit 3edf8fa5ccf10688a9280b5cbca8ed3947c42866
Author: David S. Miller <davem@davemloft.net>
Date:   Mon Mar 31 00:28:14 2008 -0700

    [NET]: Fix allnoconfig build on powerpc and avr32
    
    As reported by Haavard Skinnemoen and Stephen Rothwell:
    
    > allnoconfig fails with
    >
    > include/linux/netdevice.h:843: error: implicit declaration of function 'dev_net'
    >
    > which seems to be because the definition of dev_net is inside #ifdef
    > CONFIG_NET, while next_net_device, which calls it, is not.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 8576ca9..993758f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -827,6 +827,7 @@ struct packet_type {
 extern rwlock_t				dev_base_lock;		/* Device list lock */
 
 
+#ifdef CONFIG_NET
 #define for_each_netdev(net, d)		\
 		list_for_each_entry(d, &(net)->dev_base_head, dev_list)
 #define for_each_netdev_safe(net, d, n)	\
@@ -850,6 +851,7 @@ static inline struct net_device *first_net_device(struct net *net)
 	return list_empty(&net->dev_base_head) ? NULL :
 		net_device_entry(net->dev_base_head.next);
 }
+#endif
 
 extern int 			netdev_boot_setup_check(struct net_device *dev);
 extern unsigned long		netdev_boot_base(const char *prefix, int unit);
