From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/4] forcedeth: fix power management support
Date: Thu, 24 May 2007 18:00:11 -0400
Message-ID: <46560AEB.8040402@garzik.org>
References: <465237E8.1060005@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
To: Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48514 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752081AbXEXWAS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 May 2007 18:00:18 -0400
In-Reply-To: <465237E8.1060005@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ayaz Abdulla wrote:
> This patch fixes the power management functions. It includes lowering 
> the phy speed to conserve power.
> 
> Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>

Several issues here:

1) Your patch description needs to explain the problems in the power 
management code.  It is self-evident from the patch what functions are 
being changed, and that you feel these changes constitute a fix.  But 
beyond that... no information is given.

2) Lowering the phy speed to conserve power is not an appropriate change 
for a "bug fix only" 2.6.22-rc cycle AFAICS.  Unless there is a 
compelling argument otherwise, I feel this change should be in a 
separate patch, submitted for 2.6.23 (netdev-2.6.git#upstream).

3) You left in debugging printk's, which is sloppy:

+	dprintk(KERN_DEBUG "forcedeth: nv_suspend\n");

4) You save PCI config space twice:

  	pci_save_state(pdev);
+
+	/* save any device state */
+	np->saved_phyinterface = readl(base + NvRegPhyInterface);
+	for (i = 0; i < 64; i++) {
+		pci_read_config_dword(pdev, i*4, &np->saved_config_space[i]);



So, this needs work.

