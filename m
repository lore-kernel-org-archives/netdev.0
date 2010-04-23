From: Dan Carpenter <error27@gmail.com>
Subject: [patch] sctp: cleanup: remove unneeded null check
Date: Fri, 23 Apr 2010 13:59:06 +0200
Message-ID: <20100423115906.GE29093@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	Chris Dischino <cdischino@sonusnet.com>,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:63613 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754713Ab0DWL7R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 07:59:17 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"chunk" can never be null here.  We dereferenced it earlier in the
function and also at the start of the function we passed it to 
sctp_pack_cookie() which dereferences it.

This code has been around since the dawn of git history so if "chunk"
were ever null someone would have complained about it.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 17cb400..52352fc 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -470,8 +470,7 @@ struct sctp_chunk *sctp_make_init_ack(const struct sctp_association *asoc,
 	 *
 	 * [INIT ACK back to where the INIT came from.]
 	 */
-	if (chunk)
-		retval->transport = chunk->transport;
+	retval->transport = chunk->transport;
 
 nomem_chunk:
 	kfree(cookie);
