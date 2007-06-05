From: Patrick McHardy <kaber@trash.net>
Subject: [RFC RTNETLINK 02/09]: ifindex 0 does not exist
Date: Tue,  5 Jun 2007 16:12:54 +0200 (MEST)
Message-ID: <20070605141253.15650.15698.sendpatchset@localhost.localdomain>
References: <20070605141250.15650.47178.sendpatchset@localhost.localdomain>
Cc: socketcan@hartkopp.net, hadi@cyberus.ca, xemul@sw.ru,
	Patrick McHardy <kaber@trash.net>, ebiederm@xmission.com,
	tgraf@suug.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63899 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762971AbXFEOMz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 10:12:55 -0400
In-Reply-To: <20070605141250.15650.47178.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[RTNETLINK]: ifindex 0 does not exist

ifindex == 0 does not exist and implies we should do a lookup by name if
one was given.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 72104442408666a0ff9395a5c62a23e96a3845ef
tree d46c7ec0b401a99bfbec94ef328e9c7cf7197854
parent 842f5a7aa8357f4e43b1ab8938c51f4d7ce7aba3
author Patrick McHardy <kaber@trash.net> Mon, 04 Jun 2007 23:23:14 +0200
committer Patrick McHardy <kaber@trash.net> Mon, 04 Jun 2007 23:23:14 +0200

 net/core/rtnetlink.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index a8a5093..02e8bf0 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -580,7 +580,7 @@ static int rtnl_setlink(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 
 	err = -EINVAL;
 	ifm = nlmsg_data(nlh);
-	if (ifm->ifi_index >= 0)
+	if (ifm->ifi_index > 0)
 		dev = dev_get_by_index(ifm->ifi_index);
 	else if (tb[IFLA_IFNAME])
 		dev = dev_get_by_name(ifname);
@@ -672,7 +672,7 @@ static int rtnl_setlink(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	 * name provided implies that a name change has been
 	 * requested.
 	 */
-	if (ifm->ifi_index >= 0 && ifname[0]) {
+	if (ifm->ifi_index > 0 && ifname[0]) {
 		err = dev_change_name(dev, ifname);
 		if (err < 0)
 			goto errout_dev;
@@ -740,7 +740,7 @@ static int rtnl_getlink(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 		return err;
 
 	ifm = nlmsg_data(nlh);
-	if (ifm->ifi_index >= 0) {
+	if (ifm->ifi_index > 0) {
 		dev = dev_get_by_index(ifm->ifi_index);
 		if (dev == NULL)
 			return -ENODEV;
