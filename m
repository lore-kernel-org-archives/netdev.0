From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] hv: name network device ethX rather than sethX
Date: Thu, 11 Mar 2010 09:11:37 -0800
Message-ID: <20100311091137.27f22c57@nehalam>
References: <AD02C96F1FB40A4B896D24F974E9B9D42AA4787A@TK5EX14MBXC139.redmond.corp.microsoft.com>
	<20100308154549.1c62a33b@nehalam>
	<8AFC7968D54FB448A30D8F38F259C5621AF725A9@TK5EX14MBXC116.redmond.corp.microsoft.com>
	<20100309173855.7d297c44@nehalam>
	<20100309174217.00ae3f3b@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Greg KH <gregkh@suse.de>, netdev@vger.kernel.org
To: Hank Janssen <hjanssen@microsoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:41477 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933359Ab0CKRUs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Mar 2010 12:20:48 -0500
In-Reply-To: <20100309174217.00ae3f3b@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes the HyperV network device use the same naming
scheme as other virtual drivers (Xen, KVM). In an ideal world, 
userspace tools would not care what the name is, but some 
users and applications do care. Vyatta CLI is one of the tools
that does depend on what the name is.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
---
 drivers/staging/hv/netvsc_drv.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

--- a/drivers/staging/hv/netvsc_drv.c	2010-03-09 17:34:45.012686682 -0800
+++ b/drivers/staging/hv/netvsc_drv.c	2010-03-11 09:08:00.480877949 -0800
@@ -381,8 +381,7 @@ static int netvsc_probe(struct device *d
 	if (!net_drv_obj->Base.OnDeviceAdd)
 		return -1;
 
-	net = alloc_netdev(sizeof(struct net_device_context), "seth%d",
-			   ether_setup);
+	net = alloc_etherdev(sizeof(struct net_device_context));
 	if (!net)
 		return -1;
 
