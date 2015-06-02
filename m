From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net v3 2/2] mpls: fix mpls route deletes to not check for route scope
Date: Mon,  1 Jun 2015 23:29:27 -0700
Message-ID: <1433226567-23302-3-git-send-email-roopa@cumulusnetworks.com>
Cc: davem@davemloft.net, rshearma@brocade.com, netdev@vger.kernel.org,
	vivek@cumulusnetworks.com
To: ebiederm@xmission.com, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34520 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754261AbbFBG3f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 02:29:35 -0400
Received: by payr10 with SMTP id r10so43821885pay.1
        for <netdev@vger.kernel.org>; Mon, 01 Jun 2015 23:29:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

Ignore scope for route del messages

Signed-off-by: Vivek Venkataraman <vivek@cumulusnetworks.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
Reviewed-by: Robert Shearman <rshearma@brocade.com> 
---
 net/mpls/af_mpls.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 7b3f732..82dadab 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -693,7 +693,8 @@ static int rtm_to_route_config(struct sk_buff *skb,  struct nlmsghdr *nlh,
 	 * (or source specific address in the case of multicast)
 	 * all addresses have universal scope.
 	 */
-	if (rtm->rtm_scope != RT_SCOPE_UNIVERSE)
+	if (nlh->nlmsg_type != RTM_DELROUTE &&
+	    rtm->rtm_scope != RT_SCOPE_UNIVERSE)
 		goto errout;
 	if (rtm->rtm_type != RTN_UNICAST)
 		goto errout;
-- 
1.7.10.4
