From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH iproute2 1/3] bpf: print xdp offloaded mode
Date: Mon, 26 Jun 2017 17:23:51 -0700
Message-ID: <20170627002353.12292-2-jakub.kicinski@netronome.com>
References: <20170627002353.12292-1-jakub.kicinski@netronome.com>
Cc: daniel@iogearbox.net, oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:33307 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751460AbdF0AYC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Jun 2017 20:24:02 -0400
Received: by mail-pg0-f51.google.com with SMTP id f127so7437202pgc.0
        for <netdev@vger.kernel.org>; Mon, 26 Jun 2017 17:24:02 -0700 (PDT)
In-Reply-To: <20170627002353.12292-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add interpretation of XDP_ATTACHED_HW mode on dump.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 include/linux/if_link.h | 1 +
 ip/iplink_xdp.c         | 2 ++
 2 files changed, 3 insertions(+)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index ea57f3c74c77..8a41b3bafcd4 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -897,6 +897,7 @@ enum {
 	XDP_ATTACHED_NONE = 0,
 	XDP_ATTACHED_DRV,
 	XDP_ATTACHED_SKB,
+	XDP_ATTACHED_HW,
 };
 
 enum {
diff --git a/ip/iplink_xdp.c b/ip/iplink_xdp.c
index 4857f50c80de..1b4ef3b836e8 100644
--- a/ip/iplink_xdp.c
+++ b/ip/iplink_xdp.c
@@ -93,6 +93,8 @@ void xdp_dump(FILE *fp, struct rtattr *xdp)
 		fprintf(fp, "xdp");
 	else if (mode == XDP_ATTACHED_SKB)
 		fprintf(fp, "xdpgeneric");
+	else if (mode == XDP_ATTACHED_HW)
+		fprintf(fp, "xdpoffload");
 	else
 		fprintf(fp, "xdp[%u]", mode);
 
-- 
2.11.0
