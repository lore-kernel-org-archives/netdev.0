From: Paul Menzel <pmenzel@molgen.mpg.de>
Subject: [bnx2] [Regression 4.8] Driver loading fails without firmware
Date: Tue, 25 Oct 2016 16:33:31 +0200
Message-ID: <244cb42b-0fce-fe41-7b7c-babb51411e8c@molgen.mpg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Baoquan He <bhe@redhat.com>
To: Sony Chacko <sony.chacko@qlogic.com>,
        Dept-HSGLinuxNICDev@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.molgen.mpg.de ([141.14.17.9]:57383 "EHLO mx1.molgen.mpg.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934085AbcJYOkD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 25 Oct 2016 10:40:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Linux folks,


A server with the Broadcom devices below, fails to load the drivers 
because of missing firmware.

 > $ lspci -nn
 > […]
> 01:00.0 Ethernet controller [0200]: Broadcom Corporation NetXtreme II BCM5709 Gigabit Ethernet [14e4:1639] (rev 20)
> 01:00.1 Ethernet controller [0200]: Broadcom Corporation NetXtreme II BCM5709 Gigabit Ethernet [14e4:1639] (rev 20)
> 02:00.0 Ethernet controller [0200]: Broadcom Corporation NetXtreme II BCM5709 Gigabit Ethernet [14e4:1639] (rev 20)
> 02:00.1 Ethernet controller [0200]: Broadcom Corporation NetXtreme II BCM5709 Gigabit Ethernet [14e4:1639] (rev 20)
> […]

Here are the error messages from Linux 4.8.4.

> [   10.365839] bnx2: QLogic bnx2 Gigabit Ethernet Driver v2.2.6 (January 29, 2014)
> [   10.366989] bnx2 0000:01:00.0: Direct firmware load for bnx2/bnx2-mips-09-6.2.1b.fw failed with error -2
> [   10.367384] bnx2: Can't load firmware file "bnx2/bnx2-mips-09-6.2.1b.fw"
> [   10.367719] bnx2: probe of 0000:01:00.0 failed with error -2
> [   10.368616] bnx2 0000:01:00.1: Direct firmware load for bnx2/bnx2-mips-09-6.2.1b.fw failed with error -2
> [   10.369015] bnx2: Can't load firmware file "bnx2/bnx2-mips-09-6.2.1b.fw"
> [   10.369292] bnx2: probe of 0000:01:00.1 failed with error -2
> [   10.370194] bnx2 0000:02:00.0: Direct firmware load for bnx2/bnx2-mips-09-6.2.1b.fw failed with error -2
> [   10.374460] bnx2: Can't load firmware file "bnx2/bnx2-mips-09-6.2.1b.fw"
> [   10.374743] bnx2: probe of 0000:02:00.0 failed with error -2
> [   10.375619] bnx2 0000:02:00.1: Direct firmware load for bnx2/bnx2-mips-09-6.2.1b.fw failed with error -2
> [   10.376024] bnx2: Can't load firmware file "bnx2/bnx2-mips-09-6.2.1b.fw"
> [   10.376303] bnx2: probe of 0000:02:00.1 failed with error -2
> [   10.376589] bnx2x: QLogic 5771x/578xx 10/20-Gigabit Ethernet Driver bnx2x 1.712.30-0 (2014/02/10)
> [   10.509323] bnx2: QLogic bnx2 Gigabit Ethernet Driver v2.2.6 (January 29, 2014)
> [   10.510467] bnx2 0000:01:00.0: Direct firmware load for bnx2/bnx2-mips-09-6.2.1b.fw failed with error -2
> [   10.510855] bnx2: Can't load firmware file "bnx2/bnx2-mips-09-6.2.1b.fw"
> [   10.511188] bnx2: probe of 0000:01:00.0 failed with error -2
> [   10.512087] bnx2 0000:01:00.1: Direct firmware load for bnx2/bnx2-mips-09-6.2.1b.fw failed with error -2
> [   10.512492] bnx2: Can't load firmware file "bnx2/bnx2-mips-09-6.2.1b.fw"
> [   10.512773] bnx2: probe of 0000:01:00.1 failed with error -2
> [   10.513648] bnx2 0000:02:00.0: Direct firmware load for bnx2/bnx2-mips-09-6.2.1b.fw failed with error -2
> [   10.517861] bnx2: Can't load firmware file "bnx2/bnx2-mips-09-6.2.1b.fw"
> [   10.518182] bnx2: probe of 0000:02:00.0 failed with error -2
> [   10.519071] bnx2 0000:02:00.1: Direct firmware load for bnx2/bnx2-mips-09-6.2.1b.fw failed with error -2
> [   10.519466] bnx2: Can't load firmware file "bnx2/bnx2-mips-09-6.2.1b.fw"
> [   10.519740] bnx2: probe of 0000:02:00.1 failed with error -2
> [   10.520039] bnx2x: QLogic 5771x/578xx 10/20-Gigabit Ethernet Driver bnx2x 1.712.30-0 (2014/02/10)

The system boots fine with the *same* initramfs and Linux 4.4.27, and 
Linux 4.7.10.

> $ dmesg | grep bnx # Linux 4.7.10
> [    9.875426] bnx2: QLogic bnx2 Gigabit Ethernet Driver v2.2.6 (January 29, 2014)
> [    9.876766] bnx2 0000:01:00.0 eth0: Broadcom NetXtreme II BCM5709 1000Base-T (C0) PCI Express found at mem e6000000, IRQ 43, node addr 14:fe:b5:c6:81:01
> [    9.878065] bnx2 0000:01:00.1 eth1: Broadcom NetXtreme II BCM5709 1000Base-T (C0) PCI Express found at mem e8000000, IRQ 44, node addr 14:fe:b5:c6:81:03
> [    9.879357] bnx2 0000:02:00.0 eth2: Broadcom NetXtreme II BCM5709 1000Base-T (C0) PCI Express found at mem ea000000, IRQ 45, node addr 14:fe:b5:c6:81:05
> [    9.880630] bnx2 0000:02:00.1 eth3: Broadcom NetXtreme II BCM5709 1000Base-T (C0) PCI Express found at mem ec000000, IRQ 46, node addr 14:fe:b5:c6:81:07
> [    9.881129] bnx2x: QLogic 5771x/578xx 10/20-Gigabit Ethernet Driver bnx2x 1.712.30-0 (2014/02/10)
> [   27.692521] bnx2 0000:01:00.0 net00: renamed from eth0
> [   27.702703] bnx2 0000:01:00.1 net01: renamed from eth1
> [   27.719779] bnx2 0000:02:00.0 net02: renamed from eth2
> [   27.768563] bnx2 0000:02:00.1 net03: renamed from eth3
> [   28.146396] bnx2 0000:01:00.0 net00: using MSIX
> [   31.294206] bnx2 0000:01:00.0 net00: NIC Copper Link is Up, 1000 Mbps full duplex

There were not many commits between Linux 4.7 and Linux 4.8.

Could the commit below cause this regression?

> $ git log --oneline v4.7...v4.8 -- drivers/net/ethernet/broadcom/bnx2.c
> 3e1be7a bnx2: Reset device during driver initialization
> commit 3e1be7ad2d38c6bd6aeef96df9bd0a7822f4e51c
> Author: Baoquan He <bhe@redhat.com>
> Date:   Fri Sep 9 22:43:12 2016 +0800
>
>     bnx2: Reset device during driver initialization
>
>     When system enters into kdump kernel because of kernel panic, it won't
>     shutdown devices. On-flight DMA will continue transferring data until
>     device driver initializes. All devices are supposed to reset during
>     driver initialization. And this property is used to fix the kdump
>     failure in system with intel iommu. Other systems with hardware iommu
>     should be similar. Please check commit 091d42e ("iommu/vt-d: Copy
>     translation tables from old kernel") and those commits around.
>
>     But bnx2 driver doesn't reset device during driver initialization. The
>     device resetting is deferred to net device up stage. This will cause
>     hardware iommu handling failure on bnx2 device. And its resetting relies
>     on firmware. So in this patch move the firmware requesting code to earlier
>     bnx2_init_one(), then next call bnx2_reset_chip to reset device.
>
>     Signed-off-by: Baoquan He <bhe@redhat.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
>
> diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
> index 8fc3f3c..505ceaf 100644
> --- a/drivers/net/ethernet/broadcom/bnx2.c
> +++ b/drivers/net/ethernet/broadcom/bnx2.c
> @@ -6356,10 +6356,6 @@ bnx2_open(struct net_device *dev)
>         struct bnx2 *bp = netdev_priv(dev);
>         int rc;
>
> -       rc = bnx2_request_firmware(bp);
> -       if (rc < 0)
> -               goto out;
> -
>         netif_carrier_off(dev);
>
>         bnx2_disable_int(bp);
> @@ -6428,7 +6424,6 @@ bnx2_open(struct net_device *dev)
>         bnx2_free_irq(bp);
>         bnx2_free_mem(bp);
>         bnx2_del_napi(bp);
> -       bnx2_release_firmware(bp);
>         goto out;
>  }
>
> @@ -8575,6 +8570,12 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>
>         pci_set_drvdata(pdev, dev);
>
> +       rc = bnx2_request_firmware(bp);
> +       if (rc < 0)
> +               goto error;
> +
> +
> +       bnx2_reset_chip(bp, BNX2_DRV_MSG_CODE_RESET);
>         memcpy(dev->dev_addr, bp->mac_addr, ETH_ALEN);
>
>         dev->hw_features = NETIF_F_IP_CSUM | NETIF_F_SG |
> @@ -8607,6 +8608,7 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>         return 0;
>
>  error:
> +       bnx2_release_firmware(bp);
>         pci_iounmap(pdev, bp->regview);
>         pci_release_regions(pdev);
>         pci_disable_device(pdev);


Kind regards,

Paul
