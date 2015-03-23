From: Andrew Vagin <avagin@openvz.org>
Subject: [PATCH] lib utils: use a correct variable to get address length
Date: Tue, 24 Mar 2015 00:16:09 +0300
Message-ID: <1427145369-29477-1-git-send-email-avagin@openvz.org>
Cc: Andrew Vagin <avagin@openvz.org>, Vadim Kochan <vadim4j@gmail.com>
To: Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:5245 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752830AbbCWVcC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Mar 2015 17:32:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dst->famaly is initialized in get_addr_1()

This patch fixes errors like this:
$ ip r a 10.31.0.0/16 dev br0
Error: an inet prefix is expected rather than "10.31.0.0/16".

Cc: Vadim Kochan <vadim4j@gmail.com>
Fixes: f3a2ddc124e0 ("lib utils: Use helpers to get AF bit/byte len")
Signed-off-by: Andrew Vagin <avagin@openvz.org>
---
 lib/utils.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/utils.c b/lib/utils.c
index 9cda268..0d08a86 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -477,7 +477,7 @@ int get_prefix_1(inet_prefix *dst, char *arg, int family)
 
 	err = get_addr_1(dst, arg, family);
 	if (err == 0) {
-		dst->bitlen = af_bit_len(family);
+		dst->bitlen = af_bit_len(dst->family);
 
 		if (slash) {
 			if (get_netmask(&plen, slash+1, 0)
-- 
2.1.0
