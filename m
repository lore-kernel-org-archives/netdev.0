From: Jan Engelhardt <jengelh@inai.de>
Subject: [PATCH 1/2] nfct-extensions/timeout: adjust for changed nfct_timeout_snprintf API
Date: Sat, 26 May 2012 21:02:34 +0200
Message-ID: <1338058955-5789-2-git-send-email-jengelh@inai.de>
References: <20120526180654.GB31938@1984>
 <1338058955-5789-1-git-send-email-jengelh@inai.de>
Cc: netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netfilter-announce@lists.netfilter.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from seven.medozas.de ([188.40.89.202]:55493 "EHLO seven.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753985Ab2EZTCm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 May 2012 15:02:42 -0400
In-Reply-To: <1338058955-5789-1-git-send-email-jengelh@inai.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Despite requiring libnetfilter_cttimeout >= 1.0.0, it did not
use the new API.

nfct-extensions/timeout.c: In function 'nfct_timeout_cb':
nfct-extensions/timeout.c:99:2: error: too few arguments to function
	'nfct_timeout_snprintf'
In file included from nfct-extensions/timeout.c:26:0:
/usr/include/libnetfilter_cttimeout-1.0.0/libnetfilter_cttimeout/
	libnetfilter_cttimeout.h:114:5: note: declared here

114: int nfct_timeout_snprintf(char *buf, size_t size,
	const struct nfct_timeout *, unsigned int type, unsigned int flags);

Signed-off-by: Jan Engelhardt <jengelh@inai.de>
---
 src/nfct-extensions/timeout.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/src/nfct-extensions/timeout.c b/src/nfct-extensions/timeout.c
index a1a5c52..5b32023 100644
--- a/src/nfct-extensions/timeout.c
+++ b/src/nfct-extensions/timeout.c
@@ -96,7 +96,7 @@ static int nfct_timeout_cb(const struct nlmsghdr *nlh, void *data)
 		goto err_free;
 	}
 
-	nfct_timeout_snprintf(buf, sizeof(buf), t, 0);
+	nfct_timeout_snprintf(buf, sizeof(buf), t, NFCT_TIMEOUT_O_DEFAULT, 0);
 	printf("%s\n", buf);
 
 err_free:
-- 
1.7.7
