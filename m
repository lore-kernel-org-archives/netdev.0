From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2009-03-20
Date: Fri, 20 Mar 2009 16:29:35 -0400
Message-ID: <20090320202934.GA3263@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:50040 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752079AbZCTUaj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 16:30:39 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

One last(?) straggler for 2.6.29 -- avoid a NULL function pointer
dereference when processing certain nl80211 messages...

Please let me know if there are problems!

Thanks,

John

---

Individual patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit 170ebf85160dd128e1c4206cc197cce7d1424705:
  Tilman Schmidt (1):
        bas_gigaset: correctly allocate USB interrupt transfer buffer

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Jouni Malinen (1):
      nl80211: Check that function pointer != NULL before using it

 net/wireless/nl80211.c |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index 1e728ff..31b807a 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -1908,6 +1908,11 @@ static int nl80211_get_mesh_params(struct sk_buff *skb,
 	if (err)
 		return err;
 
+	if (!drv->ops->get_mesh_params) {
+		err = -EOPNOTSUPP;
+		goto out;
+	}
+
 	/* Get the mesh params */
 	rtnl_lock();
 	err = drv->ops->get_mesh_params(&drv->wiphy, dev, &cur_params);
@@ -2017,6 +2022,11 @@ static int nl80211_set_mesh_params(struct sk_buff *skb, struct genl_info *info)
 	if (err)
 		return err;
 
+	if (!drv->ops->set_mesh_params) {
+		err = -EOPNOTSUPP;
+		goto out;
+	}
+
 	/* This makes sure that there aren't more than 32 mesh config
 	 * parameters (otherwise our bitfield scheme would not work.) */
 	BUILD_BUG_ON(NL80211_MESHCONF_ATTR_MAX > 32);
@@ -2061,6 +2071,7 @@ static int nl80211_set_mesh_params(struct sk_buff *skb, struct genl_info *info)
 	err = drv->ops->set_mesh_params(&drv->wiphy, dev, &cfg, mask);
 	rtnl_unlock();
 
+ out:
 	/* cleanup */
 	cfg80211_put_dev(drv);
 	dev_put(dev);
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
