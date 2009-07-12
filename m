From: Mike McCormack <mikem@ring3k.org>
Subject: [PATCH] sky2: endianness fix
Date: Sun, 12 Jul 2009 14:31:42 +0900
Message-ID: <392fb48f0907112231y2d00d5d8mc9cf576f78b4cff@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.240]:3239 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751024AbZGLFhq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jul 2009 01:37:46 -0400
Received: by an-out-0708.google.com with SMTP id d40so3462420and.1
        for <netdev@vger.kernel.org>; Sat, 11 Jul 2009 22:37:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

This patch was prompted by code review.

Mike

---

Signed-off-by: Mike McCormack <mikem@ring3k.org>
---
 drivers/net/sky2.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 23a26d6..21ec0ca 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -4068,7 +4068,7 @@ static int sky2_debug_show(struct seq_file *seq, void *v)
 		     idx = RING_NEXT(idx, STATUS_RING_SIZE)) {
 			const struct sky2_status_le *le = hw->st_le + idx;
 			seq_printf(seq, "[%d] %#x %d %#x\n",
-				   idx, le->opcode, le->length, le->status);
+				   idx, le->opcode, le16_to_cpu(le->length), le32_to_cpu(le->status));
 		}
 		seq_puts(seq, "\n");
 	}
-- 
1.5.6.5
