From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [BK PATCH] 2.6 SCTP updates.
Date: Tue, 23 Mar 2004 12:13:56 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0403231211310.1818@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Dave,

please do a
	bk pull http://linux-lksctp.bkbits.net/lksctp-2.5.work
to get the following updates to SCTP on top of linux 2.6.5-rc2.

# This patch includes the following deltas:
#	           ChangeSet	1.1817  -> 1.1819
#	net/sctp/sm_make_chunk.c	1.66    -> 1.67
#	 net/sctp/ulpevent.c	1.23    -> 1.24
#	    net/sctp/Kconfig	1.11    -> 1.12
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 04/03/23	sri@us.ibm.com	1.1818
# [SCTP] Don't do any ppid byte-order conversions as it is opaque to SCTP.
# --------------------------------------------
# 04/03/23	sri@us.ibm.com	1.1819
# [SCTP] Avoid the use of hackish CONFIG_IPV6_SCTP__ option.
# --------------------------------------------
#
diff -Nru a/net/sctp/Kconfig b/net/sctp/Kconfig
--- a/net/sctp/Kconfig	Tue Mar 23 11:54:23 2004
+++ b/net/sctp/Kconfig	Tue Mar 23 11:54:23 2004
@@ -5,14 +5,9 @@
 menu "SCTP Configuration (EXPERIMENTAL)"
 	depends on INET && EXPERIMENTAL

-config IPV6_SCTP__
-	tristate
-	default y if IPV6=n
-	default IPV6 if IPV6
-
 config IP_SCTP
 	tristate "The SCTP Protocol (EXPERIMENTAL)"
-	depends on IPV6_SCTP__
+	depends on IPV6 || IPV6=n
 	---help---
 	  Stream Control Transmission Protocol

@@ -61,6 +56,7 @@
 choice
 	prompt "SCTP: Cookie HMAC Algorithm"
 	depends on IP_SCTP
+	default SCTP_HMAC_MD5
 	help
 	  HMAC algorithm to be used during association initialization.  It
 	  is strongly recommended to use HMAC-SHA1 or HMAC-MD5.  See
diff -Nru a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
--- a/net/sctp/sm_make_chunk.c	Tue Mar 23 11:54:23 2004
+++ b/net/sctp/sm_make_chunk.c	Tue Mar 23 11:54:23 2004
@@ -516,7 +516,7 @@
 	 */
 	dp.tsn = 0;
 	dp.stream = htons(sinfo->sinfo_stream);
-	dp.ppid   = htonl(sinfo->sinfo_ppid);
+	dp.ppid   = sinfo->sinfo_ppid;

 	/* Set the flags for an unordered send.  */
 	if (sinfo->sinfo_flags & MSG_UNORDERED) {
diff -Nru a/net/sctp/ulpevent.c b/net/sctp/ulpevent.c
--- a/net/sctp/ulpevent.c	Tue Mar 23 11:54:23 2004
+++ b/net/sctp/ulpevent.c	Tue Mar 23 11:54:23 2004
@@ -663,7 +663,7 @@
 	 * for and this information is passed opaquely by the SCTP stack from
 	 * one end to the other.
 	 */
-	info->sinfo_ppid = ntohl(chunk->subh.data_hdr->ppid);
+	info->sinfo_ppid = chunk->subh.data_hdr->ppid;

 	/* Sockets API Extensions for SCTP
 	 * Section 5.2.2 SCTP Header Information Structure (SCTP_SNDRCV)
