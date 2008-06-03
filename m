From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 37/39] mv643xx_eth: don't read from upper parts of 64-bit mib registers
Date: Tue,  3 Jun 2008 13:02:52 +0200
Message-ID: <1212490974-23719-38-git-send-email-buytenh@wantstofly.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Cc: netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:48751 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754079AbYFCMA2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 08:00:28 -0400
In-Reply-To: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The two 64-bit MIB registers (good_octets_received and
good_octets_sent) can trigger weird behavior if reads are done
from their 32-bit top parts.  This patch avoids reading the top
halves entirely.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 0f8e79f..54c9c76 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -983,7 +983,7 @@ static void mib_counters_update(struct mv643xx_eth_private *mep)
 	struct mib_counters *p = &mep->mib_counters;
 
 	p->good_octets_received += mib_read(mep, 0x00);
-	p->good_octets_received += (u64)mib_read(mep, 0x04) << 32;
+//	p->good_octets_received += (u64)mib_read(mep, 0x04) << 32;
 	p->bad_octets_received += mib_read(mep, 0x08);
 	p->internal_mac_transmit_err += mib_read(mep, 0x0c);
 	p->good_frames_received += mib_read(mep, 0x10);
@@ -997,7 +997,7 @@ static void mib_counters_update(struct mv643xx_eth_private *mep)
 	p->frames_512_to_1023_octets += mib_read(mep, 0x30);
 	p->frames_1024_to_max_octets += mib_read(mep, 0x34);
 	p->good_octets_sent += mib_read(mep, 0x38);
-	p->good_octets_sent += (u64)mib_read(mep, 0x3c) << 32;
+//	p->good_octets_sent += (u64)mib_read(mep, 0x3c) << 32;
 	p->good_frames_sent += mib_read(mep, 0x40);
 	p->excessive_collision += mib_read(mep, 0x44);
 	p->multicast_frames_sent += mib_read(mep, 0x48);
-- 
1.5.3.4

