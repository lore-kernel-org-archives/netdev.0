From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: [PATCH v2] drivers/net/tulip/de4x5.c
Date: Wed, 15 Sep 2010 17:43:18 -0400
Message-ID: <1284586998.6275.94.camel@dan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	kyle@mcmartin.ca, davem@davemloft.net, jeffm@suse.com,
	security@kernel.org
To: grundler@parisc-linux.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:54459 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755275Ab0IOVtl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Sep 2010 17:49:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixed formatting (tabs and line breaks).

This was previously reported as a security issue due to leakage of
uninitialized stack memory.  Jeff Mahoney pointed out that this is
incorrect since the copied data is from a union (rather than a struct).
Therefore, this patch is only under consideration for the sake of
correctness, and is not security relevant. 

Signed-off-by: Dan Rosenberg <dan.j.rosenberg@gmail.com>
Acked-by: Grant Grundler <grundler@parisc-linux.org>

--- linux-2.6.35.4.orig/drivers/net/tulip/de4x5.c	2010-08-26 19:47:12.000000000 -0400
+++ linux-2.6.35.4/drivers/net/tulip/de4x5.c	2010-09-14 21:26:52.499474207 -0400
@@ -5474,7 +5474,7 @@ de4x5_ioctl(struct net_device *dev, stru
 	tmp.lval[6] = inl(DE4X5_STRR); j+=4;
 	tmp.lval[7] = inl(DE4X5_SIGR); j+=4;
 	ioc->len = j;
-	if (copy_to_user(ioc->data, tmp.addr, ioc->len)) return -EFAULT;
+	if (copy_to_user(ioc->data, tmp.lval, ioc->len)) return -EFAULT;
 	break;
 
 #define DE4X5_DUMP              0x0f /* Dump the DE4X5 Status */






