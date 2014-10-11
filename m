From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 04/12] isdn/gigaset: fix NULL pointer dereference
Date: Sat, 11 Oct 2014 13:46:29 +0200 (CEST)
Message-ID: <66b96f4d69475c28f7a10794cc8bdccccf7a2f50.1413021630.git.tilman@imap.cc>
References: <cover.1413021630.git.tilman@imap.cc>
Cc: David Miller <davem@davemloft.net>, Dave Jones <davej@redhat.com>,
	Hansjoerg Lipp <hjlipp@web.de>,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.pxnet.com ([89.1.7.7]:46071 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752193AbaJKLrD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Oct 2014 07:47:03 -0400
In-Reply-To: <cover.1413021630.git.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In do_action, a NULL pointer might be passed to function start_dial
which will dereference it.
Fix by adding a check for NULL before the call.

Spotted with Coverity.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/ev-layer.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/isdn/gigaset/ev-layer.c b/drivers/isdn/gigaset/ev-layer.c
index dcae14a..0f699eb 100644
--- a/drivers/isdn/gigaset/ev-layer.c
+++ b/drivers/isdn/gigaset/ev-layer.c
@@ -1380,6 +1380,11 @@ static void do_action(int action, struct cardstate *cs,
 	/* events from the LL */
 
 	case ACT_DIAL:
+		if (!ev->ptr) {
+			*p_genresp = 1;
+			*p_resp_code = RSP_ERROR;
+			break;
+		}
 		start_dial(at_state, ev->ptr, ev->parameter);
 		break;
 	case ACT_ACCEPT:
-- 
1.9.2.459.g68773ac
