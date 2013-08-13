From: Weiping Pan <wpan@redhat.com>
Subject: [PATCH net] tun: compare with 0 instead of total_len
Date: Tue, 13 Aug 2013 21:46:56 +0800
Message-ID: <732ec15a7682b3ab87858de0b19a0848f0ad8944.1376399185.git.wpan@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60869 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753619Ab3HMNrW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Aug 2013 09:47:22 -0400
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r7DDlMCa001332
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 13 Aug 2013 09:47:22 -0400
Received: from localhost.localdomain.com (dhcp-17-97.nay.redhat.com [10.66.17.97])
	by int-mx12.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id r7DDlKNS020674
	for <netdev@vger.kernel.org>; Tue, 13 Aug 2013 09:47:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since we set "len = total_len" in the beginning of tun_get_user(),
so we should compare the new len with 0, instead of total_len,
or the if statement always returns false.

Signed-off-by: Weiping Pan <wpan@redhat.com>
---
 drivers/net/tun.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index db690a3..5a8ee1c 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1074,7 +1074,7 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 	u32 rxhash;
 
 	if (!(tun->flags & TUN_NO_PI)) {
-		if ((len -= sizeof(pi)) > total_len)
+		if ((len -= sizeof(pi)) < 0)
 			return -EINVAL;
 
 		if (memcpy_fromiovecend((void *)&pi, iv, 0, sizeof(pi)))
@@ -1083,7 +1083,7 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 	}
 
 	if (tun->flags & TUN_VNET_HDR) {
-		if ((len -= tun->vnet_hdr_sz) > total_len)
+		if ((len -= tun->vnet_hdr_sz) < 0)
 			return -EINVAL;
 
 		if (memcpy_fromiovecend((void *)&gso, iv, offset, sizeof(gso)))
-- 
1.7.4
