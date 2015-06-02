From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 -next] tc: {f,m}_bpf: allow to retrieve uds path from env
Date: Tue,  2 Jun 2015 23:35:34 +0200
Message-ID: <5474d3f6a86d38bad6200e726dd3c0992913d990.1433280321.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:56320 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752538AbbFBVfg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 17:35:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow to retrieve uds path from the environment, facilitates
also dealing with export a bit.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 tc/f_bpf.c  | 6 ++++--
 tc/m_bpf.c  | 6 ++++--
 tc/tc_bpf.h | 2 ++
 3 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/tc/f_bpf.c b/tc/f_bpf.c
index 597ef60..c21bf33 100644
--- a/tc/f_bpf.c
+++ b/tc/f_bpf.c
@@ -122,6 +122,7 @@ opt_bpf:
 
 			NEXT_ARG();
 			if (ebpf) {
+				bpf_uds_name = secure_getenv(BPF_ENV_UDS);
 				bpf_obj = *argv;
 				NEXT_ARG();
 
@@ -131,8 +132,9 @@ opt_bpf:
 					bpf_sec_name = *argv;
 					NEXT_ARG();
 				}
-				if (strcmp(*argv, "export") == 0 ||
-				    strcmp(*argv, "exp") == 0) {
+				if (!bpf_uds_name &&
+				    (strcmp(*argv, "export") == 0 ||
+				     strcmp(*argv, "exp") == 0)) {
 					NEXT_ARG();
 					bpf_uds_name = *argv;
 					NEXT_ARG();
diff --git a/tc/m_bpf.c b/tc/m_bpf.c
index 0621157..9ddb667 100644
--- a/tc/m_bpf.c
+++ b/tc/m_bpf.c
@@ -105,6 +105,7 @@ opt_bpf:
 
 			NEXT_ARG();
 			if (ebpf) {
+				bpf_uds_name = secure_getenv(BPF_ENV_UDS);
 				bpf_obj = *argv;
 				NEXT_ARG();
 
@@ -114,8 +115,9 @@ opt_bpf:
 					bpf_sec_name = *argv;
 					NEXT_ARG();
 				}
-				if (strcmp(*argv, "export") == 0 ||
-				    strcmp(*argv, "exp") == 0) {
+				if (!bpf_uds_name &&
+				    (strcmp(*argv, "export") == 0 ||
+				     strcmp(*argv, "exp") == 0)) {
 					NEXT_ARG();
 					bpf_uds_name = *argv;
 					NEXT_ARG();
diff --git a/tc/tc_bpf.h b/tc/tc_bpf.h
index 5a697e5..2ad8812 100644
--- a/tc/tc_bpf.h
+++ b/tc/tc_bpf.h
@@ -25,6 +25,8 @@
 #include "utils.h"
 #include "bpf_scm.h"
 
+#define BPF_ENV_UDS	"TC_BPF_UDS"
+
 int bpf_parse_string(char *arg, bool from_file, __u16 *bpf_len,
 		     char **bpf_string, bool *need_release,
 		     const char separator);
-- 
1.9.3
