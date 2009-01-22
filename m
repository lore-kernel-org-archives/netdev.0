From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 1/4] sctp: Fix crc32c calculations on big-endian arhes.
Date: Thu, 22 Jan 2009 17:36:05 -0500
Message-ID: <1232663768-4028-2-git-send-email-vladislav.yasevich@hp.com>
References: <1232663768-4028-1-git-send-email-vladislav.yasevich@hp.com>
Cc: linux-sctp@vger.kernel.org, davem@davemloft.net,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:10183 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758633AbZAVWgL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 17:36:11 -0500
In-Reply-To: <1232663768-4028-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

crc32c algorithm provides a byteswaped result.  On little-endian
arches, the result ends up in big-endian/network byte order.
On big-endinan arches, the result ends up in little-endian
order and needs to be byte swapped again.  Thus calling cpu_to_le32
gives the right output.

Tested-by: Jukka Taimisto <jukka.taimisto@mail.suomi.net>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 include/net/sctp/checksum.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/net/sctp/checksum.h b/include/net/sctp/checksum.h
index b799fb2..2fec3c3 100644
--- a/include/net/sctp/checksum.h
+++ b/include/net/sctp/checksum.h
@@ -79,5 +79,5 @@ static inline __be32 sctp_update_cksum(__u8 *buffer, __u16 length, __be32 crc32)
 
 static inline __be32 sctp_end_cksum(__be32 crc32)
 {
-	return ~crc32;
+	return (__force __be32)~cpu_to_le32((__force u32)crc32);
 }
-- 
1.5.3.5

