From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 26/37] drivers/net/wireless/ipw2x00: Use kmemdup
Date: Sat, 15 May 2010 23:21:01 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1005152320450.21345__37210.390813607$1273958552$gmane$org@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: Zhu Yi <yi.zhu@intel.com>,
	Reinette Chatre <reinette.chatre@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.k
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:35454 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756076Ab0EOVVH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 May 2010 17:21:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

Use kmemdup when some other buffer is immediately copied into the
allocated region.

A simplified version of the semantic patch that makes this change is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@@
expression from,to,size,flag;
statement S;
@@

-  to = \(kmalloc\|kzalloc\)(size,flag);
+  to = kmemdup(from,size,flag);
   if (to==NULL || ...) S
-  memcpy(to, from, size);
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/net/wireless/ipw2x00/ipw2200.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff -u -p a/drivers/net/wireless/ipw2x00/ipw2200.c b/drivers/net/wireless/ipw2x00/ipw2200.c
--- a/drivers/net/wireless/ipw2x00/ipw2200.c
+++ b/drivers/net/wireless/ipw2x00/ipw2200.c
@@ -6626,13 +6626,12 @@ static int ipw_wx_set_genie(struct net_d
 		return -EINVAL;
 
 	if (wrqu->data.length) {
-		buf = kmalloc(wrqu->data.length, GFP_KERNEL);
+		buf = kmemdup(extra, wrqu->data.length, GFP_KERNEL);
 		if (buf == NULL) {
 			err = -ENOMEM;
 			goto out;
 		}
 
-		memcpy(buf, extra, wrqu->data.length);
 		kfree(ieee->wpa_ie);
 		ieee->wpa_ie = buf;
 		ieee->wpa_ie_len = wrqu->data.length;
