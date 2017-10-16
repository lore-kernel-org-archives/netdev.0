From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 4/4] bpf: allow access to skb->len from offloads
Date: Mon, 16 Oct 2017 16:40:56 -0700
Message-ID: <20171016234056.1964-5-jakub.kicinski@netronome.com>
References: <20171016234056.1964-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net, Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:56195 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932726AbdJPXlP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 19:41:15 -0400
Received: by mail-pg0-f51.google.com with SMTP id b11so8068268pgn.12
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 16:41:15 -0700 (PDT)
In-Reply-To: <20171016234056.1964-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since we are now doing strict checking of what offloads
may access, make sure skb->len is on that list.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 net/core/filter.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/core/filter.c b/net/core/filter.c
index a908e5da5ffc..f8cd4d9aeb94 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -3656,6 +3656,8 @@ tc_cls_act_is_valid_access_analyzer(int off, int size,
 				    struct bpf_insn_access_aux *info)
 {
 	switch (off) {
+	case offsetof(struct sk_buff, len):
+		return true;
 	case offsetof(struct sk_buff, data):
 		info->reg_type = PTR_TO_PACKET;
 		return true;
-- 
2.14.1
