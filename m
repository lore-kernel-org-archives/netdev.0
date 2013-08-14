From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net 2/3] openvswitch: Use correct type while allocating flex array.
Date: Wed, 14 Aug 2013 16:19:06 -0700
Message-ID: <1376522347-39531-3-git-send-email-jesse@nicira.com>
References: <1376522347-39531-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Pravin B Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog103.obsmtp.com ([74.125.149.71]:58294 "HELO
	na3sys009aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1760033Ab3HNXTV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Aug 2013 19:19:21 -0400
Received: by mail-pa0-f52.google.com with SMTP id kq13so186420pab.39
        for <netdev@vger.kernel.org>; Wed, 14 Aug 2013 16:19:21 -0700 (PDT)
In-Reply-To: <1376522347-39531-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>

Flex array is used to allocate hash buckets which is type struct
hlist_head, but we use `struct hlist_head *` to calculate
array size.  Since hlist_head is of size pointer it works fine.

Following patch use correct type.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 net/openvswitch/flow.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 5c519b1..1aa84dc 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -240,7 +240,7 @@ static struct flex_array *alloc_buckets(unsigned int n_buckets)
 	struct flex_array *buckets;
 	int i, err;
 
-	buckets = flex_array_alloc(sizeof(struct hlist_head *),
+	buckets = flex_array_alloc(sizeof(struct hlist_head),
 				   n_buckets, GFP_KERNEL);
 	if (!buckets)
 		return NULL;
-- 
1.8.1.2
