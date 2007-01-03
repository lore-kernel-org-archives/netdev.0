From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [IP] TUNNEL: Fix to be built with user application.
Date: Wed,  3 Jan 2007 18:42:53 +0900
Message-ID: <11678173731728-git-send-email-nakam@linux-ipv6.org>
Cc: netdev@vger.kernel.org, Masahide NAKAMURA <nakam@linux-ipv6.org>,
	TAKAMIYA Noriaki <takamiya@po.ntts.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi020.linux-ipv6.org ([203.178.140.20]:45830 "EHLO
	neptune.linux-ipv6.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1749667AbXACJto (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jan 2007 04:49:44 -0500
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

include/linux/if_tunnel.h is broken for user application
because it was changed to use __be32 which is required
to include linux/types.h in advance but didn't.

(This issue is found when building MIPL2 daemon. We are not sure this
is the last header to be fixed about __be32.)

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
Signed-off-by: TAKAMIYA Noriaki <takamiya@po.ntts.co.jp>

---
 include/linux/if_tunnel.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/linux/if_tunnel.h b/include/linux/if_tunnel.h
index 8de079b..660b501 100644
--- a/include/linux/if_tunnel.h
+++ b/include/linux/if_tunnel.h
@@ -1,6 +1,8 @@
 #ifndef _IF_TUNNEL_H_
 #define _IF_TUNNEL_H_
 
+#include <linux/types.h>
+
 #define SIOCGETTUNNEL   (SIOCDEVPRIVATE + 0)
 #define SIOCADDTUNNEL   (SIOCDEVPRIVATE + 1)
 #define SIOCDELTUNNEL   (SIOCDEVPRIVATE + 2)
-- 
1.4.2

