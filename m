From: Daniel Hellstrom <daniel@gaisler.com>
Subject: CRC endianess problem on DGE-510T
Date: Fri, 10 Jun 2011 10:03:14 +0200
Message-ID: <4DF1CFC2.5080101@gaisler.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail176c2.megamailservers.com ([69.49.111.76]:43243 "EHLO
	mail176c2.megamailservers.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755715Ab1FJKzn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2011 06:55:43 -0400
Received: from [192.168.0.47] (gaisler.se [92.33.28.242])
	(authenticated bits=0)
	by mail176c2.megamailservers.com (8.13.6/8.13.1) with ESMTP id p5A83K1m031663
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 10 Jun 2011 04:03:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I'm having problems with the PCI network board D-LINK DGE-510T on 
SPARC32/LEON. The CRC calculated by ether_crc_le() does not match the 
CRC, however after swapping the result it matches. This is the same 
behaviour with the 3 boards I have. After applying the patch below 
everything works.

Does anyone know if this is a correct patch or has had similar problems 
on big endian machines?

Daniel




From: Daniel Hellstrom <daniel@gaisler.com>
Date: Wed, 6 Apr 2011 15:01:44 +0200
[PATCH] dl2k: EEPROM CRC calculation wrong endianess on bigendian machine

Signed-off-by: Daniel Hellstrom <daniel@gaisler.com>
---
 drivers/net/dl2k.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/dl2k.c b/drivers/net/dl2k.c
index c445457..4bbbd7b 100644
--- a/drivers/net/dl2k.c
+++ b/drivers/net/dl2k.c
@@ -346,7 +346,7 @@ parse_eeprom (struct net_device *dev)
        if (np->pdev->vendor == PCI_VENDOR_ID_DLINK) {  /* D-Link Only */
                /* Check CRC */
                crc = ~ether_crc_le (256 - 4, sromdata);
-               if (psrom->crc != crc) {
+               if (psrom->crc != cpu_to_le32(crc)) {q
                        printk (KERN_ERR "%s: EEPROM data CRC error.\n",
                                        dev->name);
                        return -1;
--
1.5.4
