From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] hv: don't enable Scatter/Gather
Date: Thu, 6 Jan 2011 12:28:27 -0800
Message-ID: <20110106122827.733b5438@nehalam>
References: <20101210180954.58441856@nehalam>
	<8AFC7968D54FB448A30D8F38F259C5622C0BD044@TK5EX14MBXC116.redmond.corp.microsoft.com>
	<1FB5E1D5CA062146B38059374562DF7292CCE678@TK5EX14MBXC121.redmond.corp.microsoft.com>
	<1FB5E1D5CA062146B38059374562DF729555F841@TK5EX14MBXC121.redmond.corp.microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Haiyang Zhang <haiyangz@microsoft.com>,
	Hank Janssen <hjanssen@microsoft.com>,
	Mike Sterling <Mike.Sterling@microsoft.com>,
	netdev@vger.kernel.org, <virtualization@lists.linux-foundation.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37989 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751763Ab1AFU2a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Jan 2011 15:28:30 -0500
In-Reply-To: <1FB5E1D5CA062146B38059374562DF729555F841@TK5EX14MBXC121.redmond.corp.microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The HyperV network driver can do scatter/gather but does not
do checksum offload. Since the network stack requires checksum offload
to do direct transmit (sendfile), netdev_register produces a message
when driver is loaded.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/staging/hv/netvsc_drv.c	2011-01-06 12:23:48.143333212 -0800
+++ b/drivers/staging/hv/netvsc_drv.c	2011-01-06 12:24:10.447744121 -0800
@@ -390,8 +390,6 @@ static int netvsc_probe(struct device *d
 	net->netdev_ops = &device_ops;
 
 	/* TODO: Add GSO and Checksum offload */
-	net->features = NETIF_F_SG;
-
 	SET_ETHTOOL_OPS(net, &ethtool_ops);
 	SET_NETDEV_DEV(net, device);
 
