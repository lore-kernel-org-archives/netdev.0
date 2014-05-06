From: Sergey Popovich <popovich_sergei@mail.ru>
Subject: [PATCH 2/3] rtnetlink: fix potential NULL pointer dereference
Date: Tue,  6 May 2014 18:13:16 +0300
Message-ID: <d525a30e52966da564bc3e4de31c4197a989b2ae.1399388943.git.popovich_sergei@mail.ru>
References: <cover.1399388943.git.popovich_sergei@mail.ru>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fallback1.mail.ru ([94.100.176.18]:45827 "EHLO
	fallback1.mail.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753435AbaEFPOD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 11:14:03 -0400
Received: from smtp10.mail.ru (smtp10.mail.ru [94.100.176.152])
	by fallback1.mail.ru (mPOP.Fallback_MX) with ESMTP id 248B0381C3EE
	for <netdev@vger.kernel.org>; Tue,  6 May 2014 19:14:01 +0400 (MSK)
Received: from [195.234.68.4] (port=41193 helo=tuxracer.skif.com.ua)
	by smtp10.mail.ru with esmtpa (envelope-from <popovich_sergei@mail.ru>)
	id 1Whh3w-0004LE-CE
	for netdev@vger.kernel.org; Tue, 06 May 2014 19:13:44 +0400
In-Reply-To: <cover.1399388943.git.popovich_sergei@mail.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now since commit fbdc1e8c6b79 (rtnetlink: walk through all devs in
netns safely on link params change) group of network devices can
be moved into another network namespace, there is NULL pointer
dereference in the do_setlink() as it get's called from
rtnl_group_changelink() with ifname == NULL.

Fixes: e7ed828f10bd netlink: support setting devgroup parameters
Signed-off-by: Sergey Popovich <popovich_sergei@mail.ru>
---
 net/core/rtnetlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 95258e2..188c060 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1484,7 +1484,7 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 	 * name provided implies that a name change has been
 	 * requested.
 	 */
-	if (ifm->ifi_index > 0 && ifname[0]) {
+	if (ifname && ifname[0] && ifm->ifi_index > 0) {
 		err = dev_change_name(dev, ifname);
 		if (err < 0)
 			goto errout;
-- 
1.8.3.4
