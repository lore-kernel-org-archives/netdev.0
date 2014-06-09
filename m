From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: [PATCH net-next 2/2] net/mlx4_core: Keep only one driver entry
 release mlx4_priv
Date: Mon, 9 Jun 2014 12:17:20 +0800
Message-ID: <20140609041720.GB7490@richard>
References: <1402224586-21187-1-git-send-email-ogerlitz@mellanox.com>
 <1402224586-21187-3-git-send-email-ogerlitz@mellanox.com>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, amirv@mellanox.com,
	Wei Yang <weiyang@linux.vnet.ibm.com>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp05.in.ibm.com ([122.248.162.5]:54368 "EHLO
	e28smtp05.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750729AbaFIER2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2014 00:17:28 -0400
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Mon, 9 Jun 2014 09:47:26 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id E764A394003E
	for <netdev@vger.kernel.org>; Mon,  9 Jun 2014 09:47:22 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s594IC3E4522244
	for <netdev@vger.kernel.org>; Mon, 9 Jun 2014 09:48:12 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s594HLkh022384
	for <netdev@vger.kernel.org>; Mon, 9 Jun 2014 09:47:22 +0530
Content-Disposition: inline
In-Reply-To: <1402224586-21187-3-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Or :-)

On Sun, Jun 08, 2014 at 01:49:46PM +0300, Or Gerlitz wrote:
>From: Wei Yang <weiyang@linux.vnet.ibm.com>
>
>Following commit befdf89 "net/mlx4_core: Preserve pci_dev_data after
>__mlx4_remove_one()", there are two mlx4 pci callbacks which will
>attempt to release the mlx4_priv object -- .shutdown and .remove.
>
>This leads to a use-after-free access to the already freed mlx4_priv
>instance and trigger a "Kernel access of bad area" crash when both
>.shutdown and .remove are called.
>
>During reboot or kexec, .shutdown is called, with the VFs probed to
>the host going through shutdown first and then the PF. Later, the PF
>will trigger VFs' .remove since VFs still have driver attached.
>
>Fix that by keeping only one driver entry which releases mlx4_priv.
>
>Fixes: befdf89 ('net/mlx4_core: Preserve pci_dev_data after __mlx4_remove_one()')
>CC: Bjorn Helgaas <bhelgaas@google.com>
>Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
>Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
>Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
>---
> drivers/net/ethernet/mellanox/mlx4/main.c |    2 +-
> 1 files changed, 1 insertions(+), 1 deletions(-)
>
>diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
>index 19606a4..703121a 100644
>--- a/drivers/net/ethernet/mellanox/mlx4/main.c
>+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
>@@ -2757,7 +2757,7 @@ static struct pci_driver mlx4_driver = {
> 	.name		= DRV_NAME,
> 	.id_table	= mlx4_pci_table,
> 	.probe		= mlx4_init_one,
>-	.shutdown	= mlx4_remove_one,
>+	.shutdown	= __mlx4_remove_one,
> 	.remove		= mlx4_remove_one,
> 	.err_handler    = &mlx4_err_handler,
> };
>-- 
>1.7.1

-- 
Richard Yang
Help you, Help me
