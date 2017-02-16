From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH iproute2 4/4] ip vrf: Detect invalid vrf name in pids command
Date: Thu, 16 Feb 2017 08:58:58 -0800
Message-ID: <1487264338-17588-5-git-send-email-dsa@cumulusnetworks.com>
References: <1487264338-17588-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org,
        luto@amacapital.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:35010 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932513AbdBPQ7H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 11:59:07 -0500
Received: by mail-pg0-f42.google.com with SMTP id t188so7672664pgt.2
        for <netdev@vger.kernel.org>; Thu, 16 Feb 2017 08:59:07 -0800 (PST)
In-Reply-To: <1487264338-17588-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Verify VRF name is valid before attempting to read cgroups files.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 ip/ipvrf.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/ip/ipvrf.c b/ip/ipvrf.c
index cb7f9fa6d1db..5e204a9ebbb1 100644
--- a/ip/ipvrf.c
+++ b/ip/ipvrf.c
@@ -212,6 +212,10 @@ static int ipvrf_pids(int argc, char **argv)
 	}
 
 	vrf = argv[0];
+	if (!name_is_vrf(vrf)) {
+		fprintf(stderr, "Invalid VRF name\n");
+		return -1;
+	}
 
 	mnt = find_cgroup2_mount();
 	if (!mnt)
-- 
2.1.4
