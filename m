From: William Tu <u9012063@gmail.com>
Subject: [net-next] samples/bpf: set max locked memory to ulimited
Date: Tue, 21 Jun 2016 21:05:58 -0700
Message-ID: <1466568358-37217-1-git-send-email-u9012063@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:33297 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751013AbcFVEGL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 00:06:11 -0400
Received: by mail-pa0-f65.google.com with SMTP id ts6so2820490pac.0
        for <netdev@vger.kernel.org>; Tue, 21 Jun 2016 21:06:11 -0700 (PDT)
Received: from vm-dev.localdomain ([73.93.143.25])
        by smtp.gmail.com with ESMTPSA id tj10sm8180753pab.21.2016.06.21.21.06.04
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jun 2016 21:06:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: William Tu <u9012063@gmail.com>
---
 samples/bpf/sockex2_user.c | 3 +++
 samples/bpf/sockex3_user.c | 3 +++
 2 files changed, 6 insertions(+)

diff --git a/samples/bpf/sockex2_user.c b/samples/bpf/sockex2_user.c
index 29a276d..8a4085c 100644
--- a/samples/bpf/sockex2_user.c
+++ b/samples/bpf/sockex2_user.c
@@ -5,6 +5,7 @@
 #include "bpf_load.h"
 #include <unistd.h>
 #include <arpa/inet.h>
+#include <sys/resource.h>
 
 struct pair {
 	__u64 packets;
@@ -13,11 +14,13 @@ struct pair {
 
 int main(int ac, char **argv)
 {
+	struct rlimit r = {RLIM_INFINITY, RLIM_INFINITY};
 	char filename[256];
 	FILE *f;
 	int i, sock;
 
 	snprintf(filename, sizeof(filename), "%s_kern.o", argv[0]);
+	setrlimit(RLIMIT_MEMLOCK, &r);
 
 	if (load_bpf_file(filename)) {
 		printf("%s", bpf_log_buf);
diff --git a/samples/bpf/sockex3_user.c b/samples/bpf/sockex3_user.c
index 2617772..d4184ab 100644
--- a/samples/bpf/sockex3_user.c
+++ b/samples/bpf/sockex3_user.c
@@ -5,6 +5,7 @@
 #include "bpf_load.h"
 #include <unistd.h>
 #include <arpa/inet.h>
+#include <sys/resource.h>
 
 struct flow_keys {
 	__be32 src;
@@ -23,11 +24,13 @@ struct pair {
 
 int main(int argc, char **argv)
 {
+	struct rlimit r = {RLIM_INFINITY, RLIM_INFINITY};
 	char filename[256];
 	FILE *f;
 	int i, sock;
 
 	snprintf(filename, sizeof(filename), "%s_kern.o", argv[0]);
+	setrlimit(RLIMIT_MEMLOCK, &r);
 
 	if (load_bpf_file(filename)) {
 		printf("%s", bpf_log_buf);
-- 
2.5.0
