From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 07/13] tg3: Fix TSO loopback test
Date: Thu, 19 May 2011 15:12:50 -0700
Message-ID: <1305843176-32358-8-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1117 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934917Ab1ESVxY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 May 2011 17:53:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit bb158d696489244f79fd4c3abd47968a06b48c79, entitled
"tg3: Add TSO loopback test", mistakenly inverted the checksum field
test from the receive BD.  This patch corrects the problem.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 7675231..d05c6a0 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -11195,7 +11195,7 @@ static int tg3_run_loopback(struct tg3 *tp, u32 pktsz, int loopback_mode)
 			}
 		} else if ((desc->type_flags & RXD_FLAG_TCPUDP_CSUM) &&
 			   (desc->ip_tcp_csum & RXD_TCPCSUM_MASK)
-			    >> RXD_TCPCSUM_SHIFT == 0xffff) {
+			    >> RXD_TCPCSUM_SHIFT != 0xffff) {
 			goto out;
 		}
 
-- 
1.7.3.4


