From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 14/51] ipvrf: Don't try to close an invalid fd
Date: Sat, 12 Aug 2017 14:04:33 +0200
Message-ID: <20170812120510.28750-15-phil@nwl.cc>
References: <20170812120510.28750-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:46719 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752361AbdHLMFW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 12 Aug 2017 08:05:22 -0400
In-Reply-To: <20170812120510.28750-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/ipvrf.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/ip/ipvrf.c b/ip/ipvrf.c
index 0094cf8557cd7..92e2db98ca7d7 100644
--- a/ip/ipvrf.c
+++ b/ip/ipvrf.c
@@ -268,7 +268,7 @@ static int vrf_configure_cgroup(const char *path, int ifindex)
 		fprintf(stderr,
 			"Failed to open cgroup path: '%s'\n",
 			strerror(errno));
-		goto out;
+		return rc;
 	}
 
 	/*
@@ -290,13 +290,14 @@ static int vrf_configure_cgroup(const char *path, int ifindex)
 	if (bpf_prog_attach_fd(prog_fd, cg_fd, BPF_CGROUP_INET_SOCK_CREATE)) {
 		fprintf(stderr, "Failed to attach prog to cgroup: '%s'\n",
 			strerror(errno));
-		goto out;
+		goto out2;
 	}
 
 	rc = 0;
+out2:
+	close(prog_fd);
 out:
 	close(cg_fd);
-	close(prog_fd);
 
 	return rc;
 }
-- 
2.13.1
