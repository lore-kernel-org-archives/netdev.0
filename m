From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH iproute2 1/4] ip vrf: Move kernel config hint to prog_load failure
Date: Thu, 15 Dec 2016 12:06:59 -0800
Message-ID: <1481832422-10267-2-git-send-email-dsa@cumulusnetworks.com>
References: <1481832422-10267-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:33970 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753712AbcLOUHJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2016 15:07:09 -0500
Received: by mail-pf0-f169.google.com with SMTP id c4so10278867pfb.1
        for <netdev@vger.kernel.org>; Thu, 15 Dec 2016 12:07:09 -0800 (PST)
In-Reply-To: <1481832422-10267-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the hint about CGROUP_BPF enabled to prog_load failure since
it fails before the attach. Update the existing error message to
print to stderr.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 ip/ipvrf.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/ip/ipvrf.c b/ip/ipvrf.c
index 4d59845416cd..44ad7e07024a 100644
--- a/ip/ipvrf.c
+++ b/ip/ipvrf.c
@@ -170,14 +170,15 @@ static int vrf_configure_cgroup(const char *path, int ifindex)
 	 */
 	prog_fd = prog_load(ifindex);
 	if (prog_fd < 0) {
-		printf("Failed to load BPF prog: '%s'\n", strerror(errno));
+		fprintf(stderr, "Failed to load BPF prog: '%s'\n",
+			strerror(errno));
+		fprintf(stderr, "Kernel compiled with CGROUP_BPF enabled?\n");
 		goto out;
 	}
 
 	if (bpf_prog_attach_fd(prog_fd, cg_fd, BPF_CGROUP_INET_SOCK_CREATE)) {
 		fprintf(stderr, "Failed to attach prog to cgroup: '%s'\n",
 			strerror(errno));
-		fprintf(stderr, "Kernel compiled with CGROUP_BPF enabled?\n");
 		goto out;
 	}
 
-- 
2.1.4
