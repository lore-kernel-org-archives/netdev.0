From: Paul Moore <pmoore@redhat.com>
Subject: [PATCH] cipso: simplify cipso_v4_translate() when !CONFIG_NETLABEL
Date: Wed, 20 Nov 2013 14:25:48 -0500
Message-ID: <20131120192548.5616.74526.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31429 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754193Ab3KTTZv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Nov 2013 14:25:51 -0500
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id rAKJPoCC027593
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 20 Nov 2013 14:25:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Previous commits corrected some problems with cipso_v4_translate()
when CONFIG_NETLABEL=n but some additional work is needed to tidy
things up a bit.

Signed-off-by: Paul Moore <pmoore@redhat.com>
---
 include/net/cipso_ipv4.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/cipso_ipv4.h b/include/net/cipso_ipv4.h
index a8c2ef6..2244e02 100644
--- a/include/net/cipso_ipv4.h
+++ b/include/net/cipso_ipv4.h
@@ -304,7 +304,7 @@ static inline int cipso_v4_validate(const struct sk_buff *skb,
 
 	for (opt_iter = 6; opt_iter < opt_len;) {
 		tag_len = opt[opt_iter + 1];
-		if ((tag_len == 0) || (opt[opt_iter + 1] > (opt_len - opt_iter))) {
+		if ((tag_len == 0) || (tag_len > (opt_len - opt_iter))) {
 			err_offset = opt_iter + 1;
 			goto out;
 		}
