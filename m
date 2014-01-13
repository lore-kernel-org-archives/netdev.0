From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [PATCH] sctp: remove a redundant NULL check
Date: Mon, 13 Jan 2014 16:46:08 +0300
Message-ID: <20140113134608.GA5232@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:45199 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751789AbaAMNqc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 08:46:32 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It confuses Smatch when we check "sinit" for NULL and then non-NULL and
that causes a false positive warning later.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index d32dae78a486..27f1717170c2 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -1743,7 +1743,7 @@ static int sctp_sendmsg(struct kiocb *iocb, struct sock *sk,
 		 * either the default or the user specified stream counts.
 		 */
 		if (sinfo) {
-			if (!sinit || (sinit && !sinit->sinit_num_ostreams)) {
+			if (!sinit || !sinit->sinit_num_ostreams) {
 				/* Check against the defaults. */
 				if (sinfo->sinfo_stream >=
 				    sp->initmsg.sinit_num_ostreams) {
