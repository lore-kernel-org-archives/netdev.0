From: Andrei Epure <epure.andrei-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] wireless:iwlwifi: changed kmalloc+memcpy with kmemdup
Date: Sun, 10 Mar 2013 15:22:33 +0200
Message-ID: <1362921753-9554-1-git-send-email-epure.andrei@gmail.com>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrei Epure <epure.andrei-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Andrei Epure <epure.andrei-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/wireless/iwlwifi/iwl-test.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-test.c b/drivers/net/wireless/iwlwifi/iwl-test.c
index ce0c67b..9bc402c 100644
--- a/drivers/net/wireless/iwlwifi/iwl-test.c
+++ b/drivers/net/wireless/iwlwifi/iwl-test.c
@@ -271,7 +271,7 @@ static int iwl_test_fw_cmd(struct iwl_test *tst, struct nlattr **tb)
 
 	reply_len = le32_to_cpu(pkt->len_n_flags) & FH_RSCSR_FRAME_SIZE_MSK;
 	skb = iwl_test_alloc_reply(tst, reply_len + 20);
-	reply_buf = kmalloc(reply_len, GFP_KERNEL);
+	reply_buf = kmemdup(&(pkt->hdr), reply_len, GFP_KERNEL);
 	if (!skb || !reply_buf) {
 		kfree_skb(skb);
 		kfree(reply_buf);
@@ -279,7 +279,6 @@ static int iwl_test_fw_cmd(struct iwl_test *tst, struct nlattr **tb)
 	}
 
 	/* The reply is in a page, that we cannot send to user space. */
-	memcpy(reply_buf, &(pkt->hdr), reply_len);
 	iwl_free_resp(&cmd);
 
 	if (nla_put_u32(skb, IWL_TM_ATTR_COMMAND,
-- 
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
