From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next 1/2] net/dst: Make skb parameter of skb{metadata_dst,tunnel_info}() const
Date: Mon,  2 Oct 2017 10:41:15 +0200
Message-ID: <1506933676-20121-2-git-send-email-simon.horman@netronome.com>
References: <1506933676-20121-1-git-send-email-simon.horman@netronome.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org,
        oss-drivers@netronome.com,
        Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>, Jiri Pirko <jiri@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:55998 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751081AbdJBIlg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 04:41:36 -0400
Received: by mail-wm0-f49.google.com with SMTP id u138so8982498wmu.4
        for <netdev@vger.kernel.org>; Mon, 02 Oct 2017 01:41:36 -0700 (PDT)
In-Reply-To: <1506933676-20121-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make the skb parameter of skb_metadata_dst() and skb_tunnel_info()
const as they are not modified. This is in preparation for using
them in call-sites where skb is const.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
Reviewed-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 include/net/dst_metadata.h | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/net/dst_metadata.h b/include/net/dst_metadata.h
index a803129a4849..9fba2ebf6dda 100644
--- a/include/net/dst_metadata.h
+++ b/include/net/dst_metadata.h
@@ -24,7 +24,7 @@ struct metadata_dst {
 	} u;
 };
 
-static inline struct metadata_dst *skb_metadata_dst(struct sk_buff *skb)
+static inline struct metadata_dst *skb_metadata_dst(const struct sk_buff *skb)
 {
 	struct metadata_dst *md_dst = (struct metadata_dst *) skb_dst(skb);
 
@@ -34,7 +34,8 @@ static inline struct metadata_dst *skb_metadata_dst(struct sk_buff *skb)
 	return NULL;
 }
 
-static inline struct ip_tunnel_info *skb_tunnel_info(struct sk_buff *skb)
+static inline struct ip_tunnel_info *
+skb_tunnel_info(const struct sk_buff *skb)
 {
 	struct metadata_dst *md_dst = skb_metadata_dst(skb);
 	struct dst_entry *dst;
-- 
2.1.4
