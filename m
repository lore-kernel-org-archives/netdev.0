From: jamal <hadi@cyberus.ca>
Subject: [IPROUTE2][GENERAL] nl_mgrp to crap if base multicast groups
	exceeded
Date: Sun, 25 Feb 2007 12:02:23 -0500
Message-ID: <1172422943.3942.32.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-1JN5YVdk3Fc+rGukT2Nj"
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.230]:15533 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752358AbXBYRC0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Feb 2007 12:02:26 -0500
Received: by wx-out-0506.google.com with SMTP id h31so1104055wxd
        for <netdev@vger.kernel.org>; Sun, 25 Feb 2007 09:02:26 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-1JN5YVdk3Fc+rGukT2Nj
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


cheers,
jamal


--=-1JN5YVdk3Fc+rGukT2Nj
Content-Disposition: attachment; filename=diebadmgrp
Content-Type: text/plain; name=diebadmgrp; charset=us-ascii
Content-Transfer-Encoding: 7bit

[GENERAL] nl_mgrp to crap if base multicast groups exceeded

The old scheme of bitmasks works only for the first 32 groups.
Above that the setsockopt scheme must be used.

Signed-off-by: J Hadi Salim <hadi@cyberus.ca>

---
commit f3d272cea2870805677809bf121737fb6c36dc8e
tree b1e42d5c8d9122a600f2f81e04b0d197642b1878
parent 539bc1cc1b002700504ad8cbe82ea451026c5fe4
author Jamal Hadi Salim <hadi@cyberus.ca> Sun, 25 Feb 2007 11:50:53 -0500
committer Jamal Hadi Salim <hadi@cyberus.ca> Sun, 25 Feb 2007 11:50:53 -0500

 include/utils.h |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/include/utils.h b/include/utils.h
index 1769ca1..a3fd335 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -3,6 +3,7 @@
 
 #include <asm/types.h>
 #include <resolv.h>
+#include <stdlib.h>
 
 #include "libnetlink.h"
 #include "ll_map.h"
@@ -129,7 +130,11 @@ static __inline__ int get_user_hz(void)
 
 static inline __u32 nl_mgrp(__u32 group)
 {
-	return group ? (1 << (group -1)) : 0;
+	if (group > 31 ) {
+		fprintf(stderr, "Use setsockopt for this group %d\n", group);
+		exit(-1);
+	}
+	return group ? (1 << (group - 1)) : 0;
 }
 
 

--=-1JN5YVdk3Fc+rGukT2Nj--

