From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next 2/4] filter: add XOR operation
Date: Sat, 31 Mar 2012 23:01:20 +0200
Message-ID: <1333227682-10235-3-git-send-email-jpirko@redhat.com>
References: <1333227682-10235-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	bhutchings@solarflare.com, shemminger@vyatta.com,
	raise.sail@gmail.com, nuno.martins@caixamagica.pt, matt@ozlabs.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46452 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752876Ab2CaVBg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Mar 2012 17:01:36 -0400
In-Reply-To: <1333227682-10235-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add XOR instruction fo BPF machine. Needed for computing packet hashes.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 include/linux/filter.h |    4 +++-
 net/core/filter.c      |    4 ++++
 2 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 92dd993..7209099 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -126,7 +126,8 @@ struct sock_fprog {	/* Required for SO_ATTACH_FILTER. */
 #define SKF_AD_HATYPE	28
 #define SKF_AD_RXHASH	32
 #define SKF_AD_CPU	36
-#define SKF_AD_MAX	40
+#define SKF_AD_ALU_XOR_X	40
+#define SKF_AD_MAX	44
 #define SKF_NET_OFF   (-0x100000)
 #define SKF_LL_OFF    (-0x200000)
 
@@ -231,6 +232,7 @@ enum {
 	BPF_S_ANC_HATYPE,
 	BPF_S_ANC_RXHASH,
 	BPF_S_ANC_CPU,
+	BPF_S_ANC_ALU_XOR_X,
 };
 
 #endif /* __KERNEL__ */
diff --git a/net/core/filter.c b/net/core/filter.c
index cfbea88..5099c4b 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -315,6 +315,9 @@ load_b:
 		case BPF_S_ANC_CPU:
 			A = raw_smp_processor_id();
 			continue;
+		case BPF_S_ANC_ALU_XOR_X:
+			A ^= X;
+			continue;
 		case BPF_S_ANC_NLATTR: {
 			struct nlattr *nla;
 
@@ -559,6 +562,7 @@ int sk_chk_filter(struct sock_filter *filter, unsigned int flen)
 			ANCILLARY(HATYPE);
 			ANCILLARY(RXHASH);
 			ANCILLARY(CPU);
+			ANCILLARY(ALU_XOR_X);
 			}
 		}
 		ftest->code = code;
-- 
1.7.9.1
