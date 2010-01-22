From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] net: constify MIB name tables
Date: Fri, 22 Jan 2010 22:17:26 +0200
Message-ID: <20100122201726.GC22342@x200>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f220.google.com ([209.85.220.220]:44106 "EHLO
	mail-fx0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752400Ab0AVURb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 15:17:31 -0500
Received: by fxm20 with SMTP id 20so1738888fxm.21
        for <netdev@vger.kernel.org>; Fri, 22 Jan 2010 12:17:30 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/snmp.h   |    2 +-
 net/ipv4/proc.c      |    4 ++--
 net/ipv6/proc.c      |   12 ++++++------
 net/sctp/proc.c      |    2 +-
 net/xfrm/xfrm_proc.c |    2 +-
 5 files changed, 11 insertions(+), 11 deletions(-)

--- a/include/net/snmp.h
+++ b/include/net/snmp.h
@@ -32,7 +32,7 @@
  *  - name of entries.
  */
 struct snmp_mib {
-	char *name;
+	const char *name;
 	int entry;
 };
 
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -127,8 +127,8 @@ static const struct snmp_mib snmp4_ipextstats_list[] = {
 	SNMP_MIB_SENTINEL
 };
 
-static struct {
-	char *name;
+static const struct {
+	const char *name;
 	int index;
 } icmpmibmap[] = {
 	{ "DestUnreachs", ICMP_DEST_UNREACH },
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -59,7 +59,7 @@ static const struct file_operations sockstat6_seq_fops = {
 	.release = single_release_net,
 };
 
-static struct snmp_mib snmp6_ipstats_list[] = {
+static const struct snmp_mib snmp6_ipstats_list[] = {
 /* ipv6 mib according to RFC 2465 */
 	SNMP_MIB_ITEM("Ip6InReceives", IPSTATS_MIB_INPKTS),
 	SNMP_MIB_ITEM("Ip6InHdrErrors", IPSTATS_MIB_INHDRERRORS),
@@ -92,7 +92,7 @@ static struct snmp_mib snmp6_ipstats_list[] = {
 	SNMP_MIB_SENTINEL
 };
 
-static struct snmp_mib snmp6_icmp6_list[] = {
+static const struct snmp_mib snmp6_icmp6_list[] = {
 /* icmpv6 mib according to RFC 2466 */
 	SNMP_MIB_ITEM("Icmp6InMsgs", ICMP6_MIB_INMSGS),
 	SNMP_MIB_ITEM("Icmp6InErrors", ICMP6_MIB_INERRORS),
@@ -120,7 +120,7 @@ static const char *const icmp6type2name[256] = {
 };
 
 
-static struct snmp_mib snmp6_udp6_list[] = {
+static const struct snmp_mib snmp6_udp6_list[] = {
 	SNMP_MIB_ITEM("Udp6InDatagrams", UDP_MIB_INDATAGRAMS),
 	SNMP_MIB_ITEM("Udp6NoPorts", UDP_MIB_NOPORTS),
 	SNMP_MIB_ITEM("Udp6InErrors", UDP_MIB_INERRORS),
@@ -128,7 +128,7 @@ static struct snmp_mib snmp6_udp6_list[] = {
 	SNMP_MIB_SENTINEL
 };
 
-static struct snmp_mib snmp6_udplite6_list[] = {
+static const struct snmp_mib snmp6_udplite6_list[] = {
 	SNMP_MIB_ITEM("UdpLite6InDatagrams", UDP_MIB_INDATAGRAMS),
 	SNMP_MIB_ITEM("UdpLite6NoPorts", UDP_MIB_NOPORTS),
 	SNMP_MIB_ITEM("UdpLite6InErrors", UDP_MIB_INERRORS),
@@ -170,8 +170,8 @@ static void snmp6_seq_show_icmpv6msg(struct seq_file *seq, void **mib)
 	return;
 }
 
-static inline void
-snmp6_seq_show_item(struct seq_file *seq, void **mib, struct snmp_mib *itemlist)
+static void snmp6_seq_show_item(struct seq_file *seq, void **mib,
+				const struct snmp_mib *itemlist)
 {
 	int i;
 	for (i=0; itemlist[i].name; i++)
--- a/net/sctp/proc.c
+++ b/net/sctp/proc.c
@@ -40,7 +40,7 @@
 #include <net/sctp/sctp.h>
 #include <net/ip.h> /* for snmp_fold_field */
 
-static struct snmp_mib sctp_snmp_list[] = {
+static const struct snmp_mib sctp_snmp_list[] = {
 	SNMP_MIB_ITEM("SctpCurrEstab", SCTP_MIB_CURRESTAB),
 	SNMP_MIB_ITEM("SctpActiveEstabs", SCTP_MIB_ACTIVEESTABS),
 	SNMP_MIB_ITEM("SctpPassiveEstabs", SCTP_MIB_PASSIVEESTABS),
--- a/net/xfrm/xfrm_proc.c
+++ b/net/xfrm/xfrm_proc.c
@@ -15,7 +15,7 @@
 #include <net/snmp.h>
 #include <net/xfrm.h>
 
-static struct snmp_mib xfrm_mib_list[] = {
+static const struct snmp_mib xfrm_mib_list[] = {
 	SNMP_MIB_ITEM("XfrmInError", LINUX_MIB_XFRMINERROR),
 	SNMP_MIB_ITEM("XfrmInBufferError", LINUX_MIB_XFRMINBUFFERERROR),
 	SNMP_MIB_ITEM("XfrmInHdrError", LINUX_MIB_XFRMINHDRERROR),
