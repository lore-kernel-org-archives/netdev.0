From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [BK PATCH] 2.6 SCTP update
Date: Fri, 27 Feb 2004 12:33:56 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0402271231490.12389@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Dave,

Please do a
	bk pull http://linux-lksctp.bkbits.net/lksctp-2.5.work
to get the following update to SCTP on top of linux 2.6.3

# This patch includes the following deltas:
#	           ChangeSet	1.1651  -> 1.1652
#	net/sctp/sm_statefuns.c	1.67    -> 1.68
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 04/02/27	sri@us.ibm.com	1.1652
# [SCTP] Fix incorrect INIT process termination with sinit_max_init_timeo.
#
# Currently, sinit_max_init_timeo is treated as the maximum timeout
# value for INIT retransmissions and the INIT process is aborted when
# the timeout reaches this value. But as per the SCTP sockets API draft,
# sinit_max_init_timeo only limits the timeout. The INIT process should
# be aborted only after MAX_INIT_RETRANSMITS.
# --------------------------------------------
#
diff -Nru a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
--- a/net/sctp/sm_statefuns.c	Fri Feb 27 11:04:51 2004
+++ b/net/sctp/sm_statefuns.c	Fri Feb 27 11:04:51 2004
@@ -4272,8 +4272,7 @@

 	SCTP_DEBUG_PRINTK("Timer T1 expired.\n");

-	if ((timeout < asoc->max_init_timeo) &&
-	    (attempts < asoc->max_init_attempts)) {
+	if (attempts < asoc->max_init_attempts) {
 		switch (timer) {
 		case SCTP_EVENT_TIMEOUT_T1_INIT:
 			bp = (struct sctp_bind_addr *) &asoc->base.bind_addr;
