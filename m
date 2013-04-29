From: Matthew Whitehead <tedheadster@gmail.com>
Subject: [PATCH] 3c509.c: call SET_NETDEV_DEV for all device types (ISA/ISAPnP/EISA)
Date: Mon, 29 Apr 2013 17:46:53 -0400
Message-ID: <1367272013-2496-1-git-send-email-tedheadster@gmail.com>
Cc: Matthew Whitehead <tedheadster@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f182.google.com ([209.85.216.182]:33996 "EHLO
	mail-qc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933125Ab3D2Vq5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 17:46:57 -0400
Received: by mail-qc0-f182.google.com with SMTP id k19so3342144qcs.41
        for <netdev@vger.kernel.org>; Mon, 29 Apr 2013 14:46:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The venerable 3c509 driver only sets its device parent in one case, the ISAPnP one.
It does this with the SET_NETDEV_DEV function. It should register with the device
hierarchy in two additional cases: standard (non-PnP) ISA and EISA.

- Currently they appear here:
/sys/devices/virtual/net/eth0 (standard ISA)
/sys/devices/virtual/net/eth1 (EISA)

- Rather, they should instead be here:
/sys/devices/isa/3c509.0/net/eth0 (standard ISA)
/sys/devices/pci0000:00/0000:00:07.0/00:04/net/eth1 (EISA)

Tested on ISA and EISA boards.

Signed-off-by: Matthew Whitehead <tedheadster@gmail.com>
---
 drivers/net/ethernet/3com/3c509.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/3com/3c509.c b/drivers/net/ethernet/3com/3c509.c
index f36ff99..adb4bf5 100644
--- a/drivers/net/ethernet/3com/3c509.c
+++ b/drivers/net/ethernet/3com/3c509.c
@@ -306,6 +306,7 @@ static int el3_isa_match(struct device *pdev, unsigned int ndev)
 	if (!dev)
 		return -ENOMEM;
 
+	SET_NETDEV_DEV(dev, pdev);
 	netdev_boot_setup_check(dev);
 
 	if (!request_region(ioaddr, EL3_IO_EXTENT, "3c509-isa")) {
@@ -595,6 +596,7 @@ static int __init el3_eisa_probe (struct device *device)
 		return -ENOMEM;
 	}
 
+	SET_NETDEV_DEV(dev, device);
 	netdev_boot_setup_check(dev);
 
 	el3_dev_fill(dev, phys_addr, ioaddr, irq, if_port, EL3_EISA);
-- 
1.7.2.5
