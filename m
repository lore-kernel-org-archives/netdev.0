From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] snmp6 stats as %lu
Date: Thu, 3 Apr 2003 08:02:44 +0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030403080244.6bb772e3.rddunlap@osdl.org>
References: <20030402122755.5dc3f022.rddunlap@osdl.org>
	<20030403.044822.00469453.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030403.044822.00469453.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 03 Apr 2003 04:48:22 -0800 (PST) "David S. Miller" <davem@redhat.com> wrote:

|    From: "Randy.Dunlap" <rddunlap@osdl.org>
|    Date: Wed, 2 Apr 2003 12:27:55 +0000
| 
|    ipv4/proc.c prints SNMP stats using %lu,
|    but ipv6/proc.c prints them using %ld.
|    
|    Is this difference intentional, planned, or an oversight,
|    or something else?
| 
| Looks like an oversight to me, both should use the unsigned format.

Here's the patch, on top of the seq_file conversion.

Thanks,
--
~Randy


patch_name:	snmp6-ulong.patch
patch_version:	2003-04-03.07:57:48
author:		Randy.Dunlap <rddunlap@osdl.org>
description:	modify /proc/net/snmp6 to use %lu instead of %ld for output
product:	Linux
product_versions: 2.5.66
maintainer:	Dave Miller (davem@redhat.com)
diffstat:	=
 net/ipv6/proc.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)


diff -Naur ./net/ipv6/proc.c%SN6ULF ./net/ipv6/proc.c
--- ./net/ipv6/proc.c%SN6ULF	Thu Apr  3 07:56:44 2003
+++ ./net/ipv6/proc.c	Thu Apr  3 07:57:07 2003
@@ -156,7 +156,7 @@
 	int i;
 
 	for (i=0; i<sizeof(snmp6_list)/sizeof(snmp6_list[0]); i++)
-		seq_printf(seq, "%-32s\t%ld\n", snmp6_list[i].name,
+		seq_printf(seq, "%-32s\t%lu\n", snmp6_list[i].name,
 			       fold_field(snmp6_list[i].mib, snmp6_list[i].offset));
 
 	return 0;
