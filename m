From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net v2 2/2] mpls: fix mpls route deletes to not check for route scope
Date: Wed, 27 May 2015 11:37:05 -0700
Message-ID: <1432751825-40804-3-git-send-email-roopa@cumulusnetworks.com>
Cc: davem@davemloft.net, rshearma@brocade.com, netdev@vger.kernel.org,
	vivek@cumulusnetworks.com
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:34982 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753339AbbE0ShM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 14:37:12 -0400
Received: by pdea3 with SMTP id a3so22868254pde.2
        for <netdev@vger.kernel.org>; Wed, 27 May 2015 11:37:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

Ignore scope for route del messages

Signed-off-by: Vivek Venkataraman <vivek@cumulusnetworks.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/mpls/af_mpls.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 7b3f732..f4eb0dd 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -693,8 +693,10 @@ static int rtm_to_route_config(struct sk_buff *skb,  struct nlmsghdr *nlh,
 	 * (or source specific address in the case of multicast)
 	 * all addresses have universal scope.
 	 */
-	if (rtm->rtm_scope != RT_SCOPE_UNIVERSE)
-		goto errout;
+	if (nlh->nlmsg_type != RTM_DELROUTE &&
+		rtm->rtm_scope != RT_SCOPE_UNIVERSE)
+			goto errout;
+
 	if (rtm->rtm_type != RTN_UNICAST)
 		goto errout;
 	if (rtm->rtm_flags != 0)
-- 
1.7.10.4
