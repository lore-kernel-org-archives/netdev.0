From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 6/7] net: ipmr: fix setsockopt error return
Date: Thu, 26 Nov 2015 15:23:49 +0100
Message-ID: <1448547830-21716-7-git-send-email-razor@blackwall.org>
References: <1448547830-21716-1-git-send-email-razor@blackwall.org>
Cc: davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:33718 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751016AbbKZOYH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2015 09:24:07 -0500
Received: by wmec201 with SMTP id c201so33571839wme.0
        for <netdev@vger.kernel.org>; Thu, 26 Nov 2015 06:24:06 -0800 (PST)
In-Reply-To: <1448547830-21716-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

We can have both errors and we'll return the second one, fix it to
return an error at a time as it's normal. I've overlooked this in my
previous set.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/ipv4/ipmr.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 322fdc6ac75b..6c24a16299c7 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1284,12 +1284,14 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval,
 
 	switch (optname) {
 	case MRT_INIT:
-		if (optlen != sizeof(int))
+		if (optlen != sizeof(int)) {
 			ret = -EINVAL;
-		if (rtnl_dereference(mrt->mroute_sk))
+			break;
+		}
+		if (rtnl_dereference(mrt->mroute_sk)) {
 			ret = -EADDRINUSE;
-		if (ret)
 			break;
+		}
 
 		ret = ip_ra_control(sk, 1, mrtsock_destruct);
 		if (ret == 0) {
-- 
2.4.3
