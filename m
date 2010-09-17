From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: [PATCH v3] drivers/net/tulip/de4x5.c: fix union member name in
 DE4X5_GET_REG ioctl
Date: Fri, 17 Sep 2010 01:05:44 -0400
Message-ID: <1284699944.2565.4.camel@dan>
References: <1284586998.6275.94.camel@dan>
	 <20100916.215313.180410528.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: grundler@parisc-linux.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, kyle@mcmartin.ca, jeffm@suse.com,
	security@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:49799 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751338Ab0IQFFs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Sep 2010 01:05:48 -0400
In-Reply-To: <20100916.215313.180410528.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now with descriptive title, as requested.

This was previously reported as a security issue due to leakage of
uninitialized stack memory.  Jeff Mahoney pointed out that this is
incorrect since the copied data is from a union (rather than a struct).
Therefore, this patch is only under consideration for the sake of
correctness, and is not security relevant. 

Signed-off-by: Dan Rosenberg <dan.j.rosenberg@gmail.com>
Acked-by: Grant Grundler <grundler@parisc-linux.org>

--- linux-2.6.35.4.orig/drivers/net/tulip/de4x5.c       2010-08-26 19:47:12.000000000 -0400
+++ linux-2.6.35.4/drivers/net/tulip/de4x5.c    2010-09-14 21:26:52.499474207 -0400
@@ -5474,7 +5474,7 @@ de4x5_ioctl(struct net_device *dev, stru
        tmp.lval[6] = inl(DE4X5_STRR); j+=4;
        tmp.lval[7] = inl(DE4X5_SIGR); j+=4;
        ioc->len = j;
-       if (copy_to_user(ioc->data, tmp.addr, ioc->len)) return -EFAULT;
+       if (copy_to_user(ioc->data, tmp.lval, ioc->len)) return -EFAULT;
        break;
 
 #define DE4X5_DUMP              0x0f /* Dump the DE4X5 Status */






