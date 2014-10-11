From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 01/12] isdn/gigaset: missing break in do_facility_req
Date: Sat, 11 Oct 2014 13:46:29 +0200 (CEST)
Message-ID: <db056151f18db824b1f8814cf6fdfe6aa841bc29.1413021630.git.tilman@imap.cc>
References: <cover.1413021630.git.tilman@imap.cc>
Cc: David Miller <davem@davemloft.net>, Dave Jones <davej@redhat.com>,
	Hansjoerg Lipp <hjlipp@web.de>,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gimli.pxnet.com ([89.1.7.7]:52033 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752105AbaJKLrD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Oct 2014 07:47:03 -0400
In-Reply-To: <cover.1413021630.git.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we take the unsupported supplementary service notification mask
path, we end up falling through and overwriting the error code.
Insert a break statement to skip the remainder of the switch case
and proceed to sending the reply message.

Spotted with Coverity.

Reported-by: Dave Jones <davej@redhat.com>
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/capi.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/isdn/gigaset/capi.c b/drivers/isdn/gigaset/capi.c
index 3286903..a2eabe9 100644
--- a/drivers/isdn/gigaset/capi.c
+++ b/drivers/isdn/gigaset/capi.c
@@ -1180,6 +1180,7 @@ static void do_facility_req(struct gigaset_capi_ctr *iif,
 				confparam[3] = 2;	/* length */
 				capimsg_setu16(confparam, 4,
 					       CapiSupplementaryServiceNotSupported);
+				break;
 			}
 			info = CapiSuccess;
 			confparam[3] = 2;	/* length */
-- 
1.9.2.459.g68773ac
