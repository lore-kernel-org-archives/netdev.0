From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH 1/6][SCTP]: Check for NULL arg to sctp_bucket_destroy().
Date: Mon, 17 Jul 2006 17:25:21 -0700
Message-ID: <1153182321.4282.43.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:49592 "EHLO e3.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1751260AbWGRA1z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2006 20:27:55 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k6I0Rrsr016705
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Mon, 17 Jul 2006 20:27:54 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k6I0RrqI249804
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 17 Jul 2006 20:27:53 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k6I0Rrgf026626
	for <netdev@vger.kernel.org>; Mon, 17 Jul 2006 20:27:53 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

Please apply the following 6 SCTP patches to the 2.6 tree.

Thanks
Sridhar

[SCTP]: Check for NULL arg to sctp_bucket_destroy().

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---
 net/sctp/socket.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 0a2c71d..518c55a 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -4977,7 +4977,7 @@ static struct sctp_bind_bucket *sctp_buc
 /* Caller must hold hashbucket lock for this tb with local BH disabled */
 static void sctp_bucket_destroy(struct sctp_bind_bucket *pp)
 {
-	if (hlist_empty(&pp->owner)) {
+	if (pp && hlist_empty(&pp->owner)) {
 		if (pp->next)
 			pp->next->pprev = pp->pprev;
 		*(pp->pprev) = pp->next;


