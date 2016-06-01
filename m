From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 4/7] netfilter: nf_ct_helper: Fix helper unregister count.
Date: Wed,  1 Jun 2016 14:03:21 +0200
Message-ID: <1464782604-19346-5-git-send-email-pablo@netfilter.org>
References: <1464782604-19346-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1464782604-19346-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Taehee Yoo <ap420073@gmail.com>

helpers should unregister the only registered ports.
but, helper cannot have correct registered ports value when
failed to register.

Signed-off-by: Taehee Yoo <ap420073@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_ftp.c  | 1 +
 net/netfilter/nf_conntrack_irc.c  | 1 +
 net/netfilter/nf_conntrack_sane.c | 1 +
 net/netfilter/nf_conntrack_sip.c  | 1 +
 net/netfilter/nf_conntrack_tftp.c | 1 +
 5 files changed, 5 insertions(+)

diff --git a/net/netfilter/nf_conntrack_ftp.c b/net/netfilter/nf_conntrack_ftp.c
index 883c691..19efeba 100644
--- a/net/netfilter/nf_conntrack_ftp.c
+++ b/net/netfilter/nf_conntrack_ftp.c
@@ -632,6 +632,7 @@ static int __init nf_conntrack_ftp_init(void)
 			if (ret) {
 				pr_err("failed to register helper for pf: %d port: %d\n",
 				       ftp[i][j].tuple.src.l3num, ports[i]);
+				ports_c = i;
 				nf_conntrack_ftp_fini();
 				return ret;
 			}
diff --git a/net/netfilter/nf_conntrack_irc.c b/net/netfilter/nf_conntrack_irc.c
index 8b6da27..f97ac61 100644
--- a/net/netfilter/nf_conntrack_irc.c
+++ b/net/netfilter/nf_conntrack_irc.c
@@ -271,6 +271,7 @@ static int __init nf_conntrack_irc_init(void)
 		if (ret) {
 			pr_err("failed to register helper for pf: %u port: %u\n",
 			       irc[i].tuple.src.l3num, ports[i]);
+			ports_c = i;
 			nf_conntrack_irc_fini();
 			return ret;
 		}
diff --git a/net/netfilter/nf_conntrack_sane.c b/net/netfilter/nf_conntrack_sane.c
index 7523a57..3fcbaab 100644
--- a/net/netfilter/nf_conntrack_sane.c
+++ b/net/netfilter/nf_conntrack_sane.c
@@ -223,6 +223,7 @@ static int __init nf_conntrack_sane_init(void)
 			if (ret) {
 				pr_err("failed to register helper for pf: %d port: %d\n",
 				       sane[i][j].tuple.src.l3num, ports[i]);
+				ports_c = i;
 				nf_conntrack_sane_fini();
 				return ret;
 			}
diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
index 3e06402..f72ba55 100644
--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -1669,6 +1669,7 @@ static int __init nf_conntrack_sip_init(void)
 			if (ret) {
 				pr_err("failed to register helper for pf: %u port: %u\n",
 				       sip[i][j].tuple.src.l3num, ports[i]);
+				ports_c = i;
 				nf_conntrack_sip_fini();
 				return ret;
 			}
diff --git a/net/netfilter/nf_conntrack_tftp.c b/net/netfilter/nf_conntrack_tftp.c
index 36f9640..2e65b543 100644
--- a/net/netfilter/nf_conntrack_tftp.c
+++ b/net/netfilter/nf_conntrack_tftp.c
@@ -142,6 +142,7 @@ static int __init nf_conntrack_tftp_init(void)
 			if (ret) {
 				pr_err("failed to register helper for pf: %u port: %u\n",
 				       tftp[i][j].tuple.src.l3num, ports[i]);
+				ports_c = i;
 				nf_conntrack_tftp_fini();
 				return ret;
 			}
-- 
2.1.4

