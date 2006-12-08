From: jamal <hadi@cyberus.ca>
Subject: [PATCH] [XFRM] Fix XFRMGRP_REPORT to use correct multicast group
Date: Thu, 07 Dec 2006 19:14:58 -0500
Message-ID: <1165536898.3666.3.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-0ntqLTCwOJ3pKks8aylA"
Cc: netdev@vger.kernel.org, Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.235]:37831 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1164192AbWLHAPE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Dec 2006 19:15:04 -0500
Received: by wx-out-0506.google.com with SMTP id h27so665960wxd
        for <netdev@vger.kernel.org>; Thu, 07 Dec 2006 16:15:03 -0800 (PST)
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-0ntqLTCwOJ3pKks8aylA
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


Against net-2.6 but should probably go into anything stable that has
reports already.

cheers,
jamal


--=-0ntqLTCwOJ3pKks8aylA
Content-Disposition: attachment; filename=xfrm_repg_fix
Content-Type: text/plain; name=xfrm_repg_fix; charset=us-ascii
Content-Transfer-Encoding: 7bit

[XFRM] Fix XFRMGRP_REPORT to use correct multicast group

XFRMGRP_REPORT uses 0x10 which is a group that belongs
to events. The correct value is 0x20.
We should really be using xfrm_nlgroups going forward; it was tempting
to delete the definition of XFRMGRP_REPORT but it would break at
least iproute2.

Signed-off-by: J Hadi Salim <hadi@cyberus.ca>

---
commit 5229df1f9249e3b509ff426a74f4192b60ad6760
tree 4bb9548261165e1e0a907a6e3768e28b90794cc4
parent 03b09fc1e8f71a14c661af496941b6de963fddf1
author Jamal Hadi Salim <hadi@cyberus.ca> Thu, 07 Dec 2006 19:08:58 -0500
committer Jamal Hadi Salim <hadi@cyberus.ca> Thu, 07 Dec 2006 19:08:58 -0500

 include/linux/xfrm.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index 7907c42..5227603 100644
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -355,7 +355,7 @@ struct xfrm_user_report {
 #define XFRMGRP_EXPIRE		2
 #define XFRMGRP_SA		4
 #define XFRMGRP_POLICY		8
-#define XFRMGRP_REPORT		0x10
+#define XFRMGRP_REPORT		0x20
 #endif
 
 enum xfrm_nlgroups {

--=-0ntqLTCwOJ3pKks8aylA--

