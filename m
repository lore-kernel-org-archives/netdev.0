From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: dev->get_stats(dev) in COMPAT_NET_DEV_OPS case
Date: Thu, 08 Jan 2009 14:12:05 +0100
Message-ID: <4965FBA5.2010605@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:49903 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755385AbZAHNMG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 08:12:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Stephen,

in commit eeda3fd64f75bcbfaa70ce946513abaf3f23b8e0 ("netdev: introduce 
dev_get_stats() 
<http://git.kernel.org/?p=linux/kernel/git/davem/net-2.6.git;a=commit;h=eeda3fd64f75bcbfaa70ce946513abaf3f23b8e0>")
you remove the setting of dev->get_stats :

@@ -4370,7 
<http://git.kernel.org/?p=linux/kernel/git/davem/net-2.6.git;a=blob;f=net/core/dev.c;h=ca14ab407b338172758bc409efd2baaf75bdee99;hb=d314774cf2cd5dfeb39a00d37deee65d4c627927#l4370> 
+4384,6 
<http://git.kernel.org/?p=linux/kernel/git/davem/net-2.6.git;a=blob;f=net/core/dev.c;h=8843f4e3f5e192eba9eb5154faa1ca4131fb01fc;hb=eeda3fd64f75bcbfaa70ce946513abaf3f23b8e0#l4384> 
@@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 
        netdev_init_queues(dev);
 
-       dev->get_stats = internal_stats;
        netpoll_netdev_init(dev);
        setup(dev);
        strcpy(dev->name, name);

I really appreciate your introduction of COMPAT_NET_DEV_OPS but when i 
try to compile and run a non-converted driver, i get a NULL pointer 
dereference. I tracked it down to be the call of dev->get_stats(dev).

Did you miss something or is this behaviour intended?

Regards,
Oliver

