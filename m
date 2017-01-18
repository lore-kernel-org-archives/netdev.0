From: Lance Richardson <lrichard@redhat.com>
Subject: [PATCH net-next] csum: eliminate sparse warning in remcsum_unadjust()
Date: Wed, 18 Jan 2017 15:14:56 -0500
Message-ID: <1484770496-3401-1-git-send-email-lrichard@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39686 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752459AbdARVJl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 18 Jan 2017 16:09:41 -0500
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id D0C8AC05AA65
        for <netdev@vger.kernel.org>; Wed, 18 Jan 2017 20:14:58 +0000 (UTC)
Received: from thinkcentre.redhat.com (ovpn-116-133.rdu2.redhat.com [10.10.116.133])
        by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id v0IKEw16021430
        for <netdev@vger.kernel.org>; Wed, 18 Jan 2017 15:14:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cast second parameter of csum_sub() from __sum16 to __wsum.

Signed-off-by: Lance Richardson <lrichard@redhat.com>
---
 include/net/checksum.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/checksum.h b/include/net/checksum.h
index 35d0fab..aef2b2b 100644
--- a/include/net/checksum.h
+++ b/include/net/checksum.h
@@ -179,7 +179,7 @@ static inline __wsum remcsum_adjust(void *ptr, __wsum csum,
 
 static inline void remcsum_unadjust(__sum16 *psum, __wsum delta)
 {
-	*psum = csum_fold(csum_sub(delta, *psum));
+	*psum = csum_fold(csum_sub(delta, (__force __wsum)*psum));
 }
 
 #endif
-- 
2.5.5
