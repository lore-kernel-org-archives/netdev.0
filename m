From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [BK PATCH] SCTP bug fixes.
Date: Wed, 5 May 2004 10:52:15 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0405051032220.11086@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dave,

Could you do a
	bk pull http://linux-lksctp.bkbits.net/lksctp-2.5.work &
	bk pull http://linux-lksctp.bkbits.net/lksctp-2.4.work

to get the following couple of bug fixes to SCTP.

Thanks
Sridhar

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/05/05 10:15:28-07:00 sri@us.ibm.com
#   [SCTP] Fix accessing Gap Ack blocks array with a -ve index in
#   sctp_outq_sack()
#
# net/sctp/outqueue.c
#
# ChangeSet
#   2004/05/03 23:02:10-07:00 sri@us.ibm.com
#   [SCTP] Fix memset() parameter ordering.
#
# net/sctp/ulpqueue.c
# net/sctp/ulpevent.c
#
diff -Nru a/net/sctp/outqueue.c b/net/sctp/outqueue.c
--- a/net/sctp/outqueue.c	Wed May  5 10:32:31 2004
+++ b/net/sctp/outqueue.c	Wed May  5 10:32:31 2004
@@ -1056,8 +1056,10 @@
 	}

 	/* Get the highest TSN in the sack. */
-	highest_tsn = sack_ctsn +
-		ntohs(frags[ntohs(sack->num_gap_ack_blocks) - 1].gab.end);
+	highest_tsn = sack_ctsn;
+	if (sack->num_gap_ack_blocks)
+		highest_tsn +=
+		    ntohs(frags[ntohs(sack->num_gap_ack_blocks) - 1].gab.end);

 	if (TSN_lt(asoc->highest_sacked, highest_tsn)) {
 		highest_new_tsn = highest_tsn;
diff -Nru a/net/sctp/ulpevent.c b/net/sctp/ulpevent.c
--- a/net/sctp/ulpevent.c	Wed May  5 10:32:31 2004
+++ b/net/sctp/ulpevent.c	Wed May  5 10:32:31 2004
@@ -77,7 +77,7 @@
 /* Initialize an ULP event from an given skb.  */
 void sctp_ulpevent_init(struct sctp_ulpevent *event, int msg_flags)
 {
-	memset(event, sizeof(struct sctp_ulpevent), 0x00);
+	memset(event, 0, sizeof(struct sctp_ulpevent));
 	event->msg_flags = msg_flags;
 }

diff -Nru a/net/sctp/ulpqueue.c b/net/sctp/ulpqueue.c
--- a/net/sctp/ulpqueue.c	Wed May  5 10:32:31 2004
+++ b/net/sctp/ulpqueue.c	Wed May  5 10:32:31 2004
@@ -79,7 +79,7 @@
 struct sctp_ulpq *sctp_ulpq_init(struct sctp_ulpq *ulpq,
 				 struct sctp_association *asoc)
 {
-	memset(ulpq, sizeof(struct sctp_ulpq), 0x00);
+	memset(ulpq, 0, sizeof(struct sctp_ulpq));

 	ulpq->asoc = asoc;
 	skb_queue_head_init(&ulpq->reasm);
