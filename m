From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH iproute2 3/3] ip vrf: Improve bpf error messages
Date: Thu,  5 Jan 2017 16:22:23 -0800
Message-ID: <1483662143-15242-4-git-send-email-dsa@cumulusnetworks.com>
References: <1483662143-15242-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:32864 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1031866AbdAFA2w (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2017 19:28:52 -0500
Received: by mail-pg0-f52.google.com with SMTP id g1so206652607pgn.0
        for <netdev@vger.kernel.org>; Thu, 05 Jan 2017 16:28:51 -0800 (PST)
In-Reply-To: <1483662143-15242-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Next up a non-root user gets various bpf related error messages:

$ ip vrf exec mgmt bash
Failed to load BPF prog: 'Operation not permitted'
Kernel compiled with CGROUP_BPF enabled?

Catch the EPERM error and do not show the kernel config option.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 ip/ipvrf.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/ip/ipvrf.c b/ip/ipvrf.c
index dc8364a43a57..8bd99d6251f2 100644
--- a/ip/ipvrf.c
+++ b/ip/ipvrf.c
@@ -181,7 +181,11 @@ static int vrf_configure_cgroup(const char *path, int ifindex)
 	if (prog_fd < 0) {
 		fprintf(stderr, "Failed to load BPF prog: '%s'\n",
 			strerror(errno));
-		fprintf(stderr, "Kernel compiled with CGROUP_BPF enabled?\n");
+
+		if (errno != EPERM) {
+			fprintf(stderr,
+				"Kernel compiled with CGROUP_BPF enabled?\n");
+		}
 		goto out;
 	}
 
-- 
2.1.4
