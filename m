From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] net: vrf: set operstate and mtu at link create
Date: Wed,  1 Jun 2016 21:16:39 -0700
Message-ID: <1464840999-12763-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34381 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750960AbcFBEQu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2016 00:16:50 -0400
Received: by mail-pa0-f47.google.com with SMTP id bz2so2390531pad.1
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2016 21:16:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The VRF device exists to define L3 domains and guide FIB lookups. As
such its operstate is not relevant. Seeing 'state UNKNOWN' in the
output of 'ip link show' can be confusing, so set operstate at link
create.

Similarly, the MTU for a VRF device is not used; any fragmentation
of the payload is done on the output path based on the real egress
device. An MTU of 1500 on the VRF device while enslaved devices
have a higher MTU can lead to confusion. Since the VRF MTU is not
relevant set to 64k similar to what is done for loopback.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 965e5e9bb3d3..1d9583c5929e 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -687,6 +687,12 @@ static int vrf_dev_init(struct net_device *dev)
 
 	dev->flags = IFF_MASTER | IFF_NOARP;
 
+	/* MTU is irrelevant for VRF device; set to 64k similar to lo */
+	dev->mtu = 64 * 1024;
+
+	/* similarly, oper state is irrelevant; set to up to avoid confusion */
+	dev->operstate = IF_OPER_UP;
+
 	return 0;
 
 out_rth:
-- 
2.1.4
