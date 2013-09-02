From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next] net: correctly interlink lower/upper devices
Date: Mon,  2 Sep 2013 16:26:51 +0200
Message-ID: <1378132011-2910-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7624 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756399Ab3IBO0f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Sep 2013 10:26:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we're linking upper devices to lower ones, which results in
upside-down relationship: upper devices seeing lower devices via its upper
lists.

Fix this by correctly linking lower devices to the upper ones.

CC: "David S. Miller" <davem@davemloft.net>
CC: Eric Dumazet <edumazet@google.com>
CC: Jiri Pirko <jiri@resnulli.us>
CC: Alexander Duyck <alexander.h.duyck@intel.com>
CC: Cong Wang <amwang@redhat.com>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 net/core/dev.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 6fbb0c9..743620e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4679,8 +4679,8 @@ static int __netdev_upper_dev_link(struct net_device *dev,
 	 * versa, and don't forget the devices itself. All of these
 	 * links are non-neighbours.
 	 */
-	list_for_each_entry(i, &upper_dev->upper_dev_list, list) {
-		list_for_each_entry(j, &dev->lower_dev_list, list) {
+	list_for_each_entry(i, &dev->lower_dev_list, list) {
+		list_for_each_entry(j, &upper_dev->upper_dev_list, list) {
 			ret = __netdev_adjacent_dev_link(i->dev, j->dev);
 			if (ret)
 				goto rollback_mesh;
-- 
1.8.4
