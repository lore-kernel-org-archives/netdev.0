From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH v2 iproute2] tc: fix bpf compilation with old glibc
Date: Thu, 23 Jul 2015 09:17:41 +0200
Message-ID: <1437635861-19157-1-git-send-email-nicolas.dichtel@6wind.com>
References: <20150722094702.2eb3c0ea@urahara>
Cc: netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Daniel Borkmann <daniel@iogearbox.net>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:48548 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751325AbbGWHRx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2015 03:17:53 -0400
In-Reply-To: <20150722094702.2eb3c0ea@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Error was:
f_bpf.o: In function `bpf_parse_opt':
f_bpf.c:(.text+0x88f): undefined reference to `secure_getenv'
m_bpf.o: In function `parse_bpf':
m_bpf.c:(.text+0x587): undefined reference to `secure_getenv'
collect2: error: ld returned 1 exit status

There is no special reason to use the secure version of getenv, thus let's
simply use getenv().

CC: Daniel Borkmann <daniel@iogearbox.net>
Fixes: 88eea5395483 ("tc: {f,m}_bpf: allow to retrieve uds path from env")
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---

v2: rework the fix to use getenv() instead of secure_getenv()

 examples/bpf/bpf_agent.c | 2 +-
 tc/f_bpf.c               | 2 +-
 tc/m_bpf.c               | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/examples/bpf/bpf_agent.c b/examples/bpf/bpf_agent.c
index 426b8800bf4e..f9b9ce3ccb3d 100644
--- a/examples/bpf/bpf_agent.c
+++ b/examples/bpf/bpf_agent.c
@@ -154,7 +154,7 @@ static void bpf_map_get_from_env(int *tfd)
 		memset(key, 0, sizeof(key));
 		snprintf(key, sizeof(key), "BPF_MAP%d", i);
 
-		val = secure_getenv(key);
+		val = getenv(key);
 		assert(val != NULL);
 
 		tfd[i] = atoi(val);
diff --git a/tc/f_bpf.c b/tc/f_bpf.c
index c21bf33fd25f..490dc6b4e7ba 100644
--- a/tc/f_bpf.c
+++ b/tc/f_bpf.c
@@ -122,7 +122,7 @@ opt_bpf:
 
 			NEXT_ARG();
 			if (ebpf) {
-				bpf_uds_name = secure_getenv(BPF_ENV_UDS);
+				bpf_uds_name = getenv(BPF_ENV_UDS);
 				bpf_obj = *argv;
 				NEXT_ARG();
 
diff --git a/tc/m_bpf.c b/tc/m_bpf.c
index 9ddb6672693c..c51f44fc6ce6 100644
--- a/tc/m_bpf.c
+++ b/tc/m_bpf.c
@@ -105,7 +105,7 @@ opt_bpf:
 
 			NEXT_ARG();
 			if (ebpf) {
-				bpf_uds_name = secure_getenv(BPF_ENV_UDS);
+				bpf_uds_name = getenv(BPF_ENV_UDS);
 				bpf_obj = *argv;
 				NEXT_ARG();
 
-- 
2.4.2
