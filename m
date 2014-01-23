From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [PATCH ebtables] arptables: long option "--set-counters" were
 missing
Date: Thu, 23 Jan 2014 21:09:35 +0100
Message-ID: <20140123200921.19853.63386.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Bart De Schuymer <bdschuym@pandora.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61645 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932372AbaAWUJk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jan 2014 15:09:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The long option "--set-counters" where missing in option parsing.
And the corresponding short option "-c" were not mentioned in
the help usage text.

Also update the arptables man page with a description
of the parameter.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 userspace/arptables/arptables.8 |    8 ++++++++
 userspace/arptables/arptables.c |    3 ++-
 2 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/userspace/arptables/arptables.8 b/userspace/arptables/arptables.8
index 0b6b62e..78b2c60 100644
--- a/userspace/arptables/arptables.8
+++ b/userspace/arptables/arptables.8
@@ -215,6 +215,14 @@ The target of the rule. This is one of the following values:
 a target extension (see
 .BR "TARGET EXTENSIONS" ")"
 or a user-defined chain name.
+.TP
+.BI "-c, --set-counters " "PKTS BYTES"
+This enables the administrator to initialize the packet and byte
+counters of a rule (during
+.B INSERT,
+.B APPEND,
+.B REPLACE
+operations).
 
 .SS RULE-SPECIFICATIONS
 The following command line arguments make up a rule specification (as used 
diff --git a/userspace/arptables/arptables.c b/userspace/arptables/arptables.c
index 4da6fea..3fb8ed5 100644
--- a/userspace/arptables/arptables.c
+++ b/userspace/arptables/arptables.c
@@ -152,6 +152,7 @@ static struct option original_opts[] = {
 	{ "help", 2, 0, 'h' },
 	{ "line-numbers", 0, 0, '0' },
 	{ "modprobe", 1, 0, 'M' },
+	{ "set-counters", 1, 0, 'c' },
 	{ 0 }
 };
 
@@ -529,7 +530,7 @@ exit_printhelp(void)
 "  --line-numbers		print line numbers when listing\n"
 "  --exact	-x		expand numbers (display exact values)\n"
 "  --modprobe=<command>		try to insert modules using this command\n"
-"  --set-counters PKTS BYTES	set the counter during insert/append\n"
+"  --set-counters -c PKTS BYTES	set the counter during insert/append\n"
 "[!] --version	-V		print package version.\n");
 	printf(" opcode strings: \n");
         for (i = 0; i < NUMOPCODES; i++)
