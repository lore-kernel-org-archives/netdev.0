From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next] tun_dst: Remove opts_size
Date: Mon, 31 Aug 2015 20:05:57 -0700
Message-ID: <1441076757-2349-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:36861 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754317AbbIADF7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2015 23:05:59 -0400
Received: by pacgr6 with SMTP id gr6so9104357pac.3
        for <netdev@vger.kernel.org>; Mon, 31 Aug 2015 20:05:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

opts_size is only written and never read. Following patch
removes this unused variable.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 include/net/dst_metadata.h |    1 -
 net/core/dst.c             |    1 -
 2 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/include/net/dst_metadata.h b/include/net/dst_metadata.h
index 547ab82..af9d538 100644
--- a/include/net/dst_metadata.h
+++ b/include/net/dst_metadata.h
@@ -7,7 +7,6 @@
 
 struct metadata_dst {
 	struct dst_entry		dst;
-	size_t				opts_len;
 	union {
 		struct ip_tunnel_info	tun_info;
 	} u;
diff --git a/net/core/dst.c b/net/core/dst.c
index 477035e..0771c8c 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -378,7 +378,6 @@ static void __metadata_dst_init(struct metadata_dst *md_dst, u8 optslen)
 	dst->output = dst_md_discard_sk;
 
 	memset(dst + 1, 0, sizeof(*md_dst) + optslen - sizeof(*dst));
-	md_dst->opts_len = optslen;
 }
 
 struct metadata_dst *metadata_dst_alloc(u8 optslen, gfp_t flags)
-- 
1.7.1
