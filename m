From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH net-next 24/27] bpf_test: prepare for VLAN_TAG_PRESENT removal
Date: Tue, 13 Dec 2016 01:12:41 +0100 (CET)
Message-ID: <b5f8fbcacab6ccd382d7e52f7b4066e21728419e.1481586602.git.mirq-linux@rere.qmqm.pl>
References: <cover.1481586602.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Alexei Starovoitov <ast@kernel.org> (supporter:BPF (Safe dynamic
        programs and tools)),
        netdev@vger.kernel.org (open list:BPF (Safe dynamic programs and tools)),
        linux-kernel@vger.kernel.org (open list:BPF (Safe dynamic programs and
        tools))
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([84.10.57.10]:50214 "EHLO rere.qmqm.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932593AbcLMAMp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Dec 2016 19:12:45 -0500
In-Reply-To: <cover.1481586602.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michał Mirosław <mirq-linux@rere.qmqm.pl>
---
 lib/test_bpf.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/lib/test_bpf.c b/lib/test_bpf.c
index 0362da0..00d3450 100644
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
2.10.2
