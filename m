From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [Bugme-new] [Bug 10380] New: sc92031 does not create a device
 link in sysfs
Date: Wed, 2 Apr 2008 09:49:23 -0700
Message-ID: <20080402094923.185f15dc@extreme>
References: <bug-10380-10286@http.bugzilla.kernel.org/>
	<20080402091435.39f99428.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	Cesar Eduardo Barros <cesarb@cesarb.net>, tom@sharkbay.at
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:59329 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755087AbYDBQt1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Apr 2008 12:49:27 -0400
In-Reply-To: <20080402091435.39f99428.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add missing sysfs device association. Compile tested only -ENOHW.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
---
Patch against 2.6.25-rc8, ignore previous patch.


--- a/drivers/net/sc92031.c	2008-04-02 09:34:35.000000000 -0700
+++ b/drivers/net/sc92031.c	2008-04-02 09:47:41.000000000 -0700
@@ -1446,6 +1446,7 @@ static int __devinit sc92031_probe(struc
 	}
 
 	pci_set_drvdata(pdev, dev);
+	SET_NETDEV_DEV(dev, &pdev->dev);
 
 #if SC92031_USE_BAR == 0
 	dev->mem_start = pci_resource_start(pdev, SC92031_USE_BAR);
