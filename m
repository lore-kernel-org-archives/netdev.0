From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH] skbuff: remove unused dev_consume_skb macro
	definition
Date: Fri, 09 Apr 2010 13:01:37 -0700
Message-ID: <20100409200116.31057.29639.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta09.westchester.pa.mail.comcast.net ([76.96.62.96]:43603
	"EHLO qmta09.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755231Ab0DIUBz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Apr 2010 16:01:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

dev_consume_skb and kfree_skb_clean have no users and in the case of
kfree_skb_clean could cause potential build issues since I cannot find
where it is defined.  Based on the patch in which it was introduced it
appears to have been a bit of leftover code from an earlier version of the
patch in which kfree_skb_clean was dropped in favor of consume_skb.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 include/linux/skbuff.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index cf42f19..38501d2 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -470,7 +470,6 @@ extern int	       skb_cow_data(struct sk_buff *skb, int tailbits,
 				    struct sk_buff **trailer);
 extern int	       skb_pad(struct sk_buff *skb, int pad);
 #define dev_kfree_skb(a)	consume_skb(a)
-#define dev_consume_skb(a)	kfree_skb_clean(a)
 extern void	      skb_over_panic(struct sk_buff *skb, int len,
 				     void *here);
 extern void	      skb_under_panic(struct sk_buff *skb, int len,

