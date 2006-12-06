From: jamal <hadi@cyberus.ca>
Subject: [IPROUTE2 PATCH][GENETLINK] Multicast computation off by one
Date: Wed, 06 Dec 2006 12:06:03 -0500
Message-ID: <1165424763.3749.7.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-JrjyaWa6oOURE7tcUtCl"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.227]:37607 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936692AbWLFRGI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Dec 2006 12:06:08 -0500
Received: by wr-out-0506.google.com with SMTP id i7so409241wra
        for <netdev@vger.kernel.org>; Wed, 06 Dec 2006 09:06:07 -0800 (PST)
To: Stephen Hemminger <shemminger@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-JrjyaWa6oOURE7tcUtCl
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

A small typo fixup
BTW, how do you like the subject to look like?

cheers,
jamal

--=-JrjyaWa6oOURE7tcUtCl
Content-Disposition: attachment; filename=genl-p1
Content-Type: text/plain; name=genl-p1; charset=us-ascii
Content-Transfer-Encoding: 7bit

[GENL] Multicast computation off by one

When using the first 32 groups, the multicast group to bit mapping
was off by one.

Signed-off-by: Jamal Hadi Salim

---
commit b883bf2396abc0434b3a63d228593cec80808dbb
tree dba2b9664d88d7a4641d11c6284b984a33d2b47a
parent 288384f22ffafd2d7d888ee45d8dfcf26d3f2b1c
author Jamal Hadi Salim <hadi@cyberus.ca> Tue, 05 Dec 2006 14:13:46 -0500
committer Jamal Hadi Salim <hadi@cyberus.ca> Tue, 05 Dec 2006 14:13:46 -0500

 genl/genl_utils.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/genl/genl_utils.h b/genl/genl_utils.h
index 2f2314b..22e9210 100644
--- a/genl/genl_utils.h
+++ b/genl/genl_utils.h
@@ -16,7 +16,7 @@ extern int genl_ctrl_resolve_family(const char *family);
 /* seems to have dissapeared from netlink.h */
 static inline __u32 nl_mgrp(__u32 group)
 {
-	return group ? 1 << group : 0;
+	return group ? (1 << (group -1)) : 0;
 }
 
 #endif

--=-JrjyaWa6oOURE7tcUtCl--

