From: Jens Osterkamp <jens@de.ibm.com>
Subject: [patch 1/2] spidernet: bug fix for init code
Date: Thu, 13 Jul 2006 11:54:23 +0200
Message-ID: <200607131154.23638.jens@de.ibm.com>
References: <20060713084917.278380000@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cbe-oss-dev@ozlabs.org, arndb@de.ibm.com,
	maxim@de.ibm.com, utz.bacher@de.ibm.com, seg@us.ibm.com,
	jklewis@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.29.150]:41931 "EHLO
	mtagate1.de.ibm.com") by vger.kernel.org with ESMTP id S932325AbWGMJy3
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Jul 2006 05:54:29 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.6/8.13.6) with ESMTP id k6D9sQjq144004
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Thu, 13 Jul 2006 09:54:28 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k6D9vLwu037700
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 13 Jul 2006 11:57:22 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k6D9sO0I007820
	for <netdev@vger.kernel.org>; Thu, 13 Jul 2006 11:54:24 +0200
To: jgarzik@pobox.com
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We want to intitialize addr instead of data register first. 

Signed-off-by: Jens Osterkamp <Jens.Osterkamp@de.ibm.com>
Signed-off-by: Arnd Bergmann <arnd.bergmann@de.ibm.com>

Index: git/drivers/net/spider_net.c
===================================================================
--- git.orig/drivers/net/spider_net.c
+++ git/drivers/net/spider_net.c
@@ -1938,7 +1938,7 @@ spider_net_workaround_rxramfull(struct s
 	/* empty sequencer data */
 	for (sequencer = 0; sequencer < SPIDER_NET_FIRMWARE_SEQS;
 	     sequencer++) {
-		spider_net_write_reg(card, SPIDER_NET_GSnPRGDAT +
+		spider_net_write_reg(card, SPIDER_NET_GSnPRGADR +
 				     sequencer * 8, 0x0);
 		for (i = 0; i < SPIDER_NET_FIRMWARE_SEQWORDS; i++) {
 			spider_net_write_reg(card, SPIDER_NET_GSnPRGDAT +

--

