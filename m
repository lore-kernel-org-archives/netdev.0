From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH 3.14-stable] net/mlx4_core: Preserve pci_dev_data after
 __mlx4_remove_one()
Date: Sun, 1 Jun 2014 12:36:18 +0300
Message-ID: <538AF412.9080406@mellanox.com>
References: <1401607475-8367-1-git-send-email-weiyang@linux.vnet.ibm.com> <20140601073853.GA8635@richard> <538AF2CB.20603@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Bjorn Helgaas <bhelgaas@google.com>,
	Amir Vadai <amirv@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>
To: Wei Yang <weiyang@linux.vnet.ibm.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog108.obsmtp.com ([207.126.144.125]:47127 "EHLO
	eu1sys200aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752096AbaFAJhE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2014 05:37:04 -0400
In-Reply-To: <538AF2CB.20603@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/06/2014 12:30, Or Gerlitz wrote:
> Wait, I recently noticed that on 3.15-rcX if the host is rebooted when 
> the mlx4_core driver is loaded in SRIOV mode, we crash like that, 
> looking on this now, I think there's chance we can relate it to your 
> upstream change befdf89 "net/mlx4_core: Preserve pci_dev_data after 
> __mlx4_remove_one()"

this seems to fix the crash, will further evaluate and submit patch 
later today



index c187d74..c747736 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -2629,7 +2629,7 @@ static void __mlx4_remove_one(struct pci_dev *pdev)
         int               pci_dev_data;
         int p;

-       if (priv->removed)
+       if (!priv || priv->removed)
                 return;

         pci_dev_data = priv->pci_dev_data;
