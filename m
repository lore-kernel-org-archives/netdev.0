From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] iproute2: tc: f_flow: add key rxhash
Date: Sun, 22 Aug 2010 00:30:01 +0800
Message-ID: <1282408201-3522-1-git-send-email-xiaosuo@gmail.com>
Cc: Jamal Hadi Salim <hadi@cyberus.ca>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: "Stephen Hemminger" <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:34889 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751557Ab0HUQa5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Aug 2010 12:30:57 -0400
Received: by pxi10 with SMTP id 10so1668849pxi.19
        for <netdev@vger.kernel.org>; Sat, 21 Aug 2010 09:30:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can use rxhash to classify the traffic into flows. As rxhash maybe
supplied by NIC or RPS, it is cheaper.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 include/linux/pkt_cls.h |    1 +
 tc/f_flow.c             |    3 ++-
 2 files changed, 3 insertions(+), 1 deletion(-)
diff --git a/include/linux/pkt_cls.h b/include/linux/pkt_cls.h
index 7f6ba86..defbde2 100644
--- a/include/linux/pkt_cls.h
+++ b/include/linux/pkt_cls.h
@@ -332,6 +332,7 @@ enum {
 	FLOW_KEY_SKUID,
 	FLOW_KEY_SKGID,
 	FLOW_KEY_VLAN_TAG,
+	FLOW_KEY_RXHASH,
 	__FLOW_KEY_MAX,
 };
 
diff --git a/tc/f_flow.c b/tc/f_flow.c
index 84b45c9..574253d 100644
--- a/tc/f_flow.c
+++ b/tc/f_flow.c
@@ -33,7 +33,7 @@ static void explain(void)
 "KEY      := [ src | dst | proto | proto-src | proto-dst | iif | priority | \n"
 "              mark | nfct | nfct-src | nfct-dst | nfct-proto-src | \n"
 "              nfct-proto-dst | rt-classid | sk-uid | sk-gid |\n"
-"              vlan-tag ]\n"
+"              vlan-tag | rxhash ]\n"
 "OPS      := [ or NUM | and NUM | xor NUM | rshift NUM | addend NUM ]\n"
 "ID       := X:Y\n"
 	);
@@ -57,6 +57,7 @@ static const char *flow_keys[FLOW_KEY_MAX+1] = {
 	[FLOW_KEY_SKUID]		= "sk-uid",
 	[FLOW_KEY_SKGID]		= "sk-gid",
 	[FLOW_KEY_VLAN_TAG]		= "vlan-tag",
+	[FLOW_KEY_RXHASH]		= "rxhash",
 };
 
 static int flow_parse_keys(__u32 *keys, __u32 *nkeys, char *argv)
