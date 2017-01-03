From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH net-next v2 24/27] bpf_test: prepare for VLAN_TAG_PRESENT removal
Date: Tue,  3 Jan 2017 21:52:40 +0100 (CET)
Message-ID: <58e4b5f61786ca36f7bbf96b1d55af24c5013996.1483475202.git.mirq-linux@rere.qmqm.pl>
References: <cover.1483475202.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Alexei Starovoitov <ast@kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([84.10.57.10]:34718 "EHLO rere.qmqm.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935925AbdACUwu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Jan 2017 15:52:50 -0500
In-Reply-To: <cover.1483475202.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michał Mirosław <mirq-linux@rere.qmqm.pl>
---
 lib/test_bpf.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/lib/test_bpf.c b/lib/test_bpf.c
index 0362da0b66c3..00d345006671 100644
--- a/lib/test_bpf.c
+++ b/lib/test_bpf.c
@@ -691,8 +691,13 @@ static struct bpf_test tests[] = {
 		CLASSIC,
 		{ },
 		{
+#ifdef VLAN_TAG_PRESENT
 			{ 1, SKB_VLAN_TCI & ~VLAN_TAG_PRESENT },
 			{ 10, SKB_VLAN_TCI & ~VLAN_TAG_PRESENT }
+#else
+			{ 1, SKB_VLAN_TCI },
+			{ 10, SKB_VLAN_TCI }
+#endif
 		},
 	},
 	{
@@ -705,8 +710,13 @@ static struct bpf_test tests[] = {
 		CLASSIC,
 		{ },
 		{
+#ifdef VLAN_TAG_PRESENT
 			{ 1, !!(SKB_VLAN_TCI & VLAN_TAG_PRESENT) },
 			{ 10, !!(SKB_VLAN_TCI & VLAN_TAG_PRESENT) }
+#else
+			{ 1, SKB_VLAN_PRESENT },
+			{ 10, SKB_VLAN_PRESENT }
+#endif
 		},
 	},
 	{
@@ -4773,8 +4783,13 @@ static struct bpf_test tests[] = {
 		CLASSIC,
 		{ },
 		{
+#ifdef VLAN_TAG_PRESENT
 			{  1, !!(SKB_VLAN_TCI & VLAN_TAG_PRESENT) },
 			{ 10, !!(SKB_VLAN_TCI & VLAN_TAG_PRESENT) }
+#else
+			{  1, SKB_VLAN_PRESENT },
+			{ 10, SKB_VLAN_PRESENT }
+#endif
 		},
 		.fill_helper = bpf_fill_maxinsns6,
 	},
-- 
2.11.0
