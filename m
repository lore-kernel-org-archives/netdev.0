From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH] gigaset: correct range checking off by one error
Date: Tue, 16 Mar 2010 18:04:01 +0100
Message-ID: <20100316172048.CBC5240116@xenon.ts.pxnet.com>
Cc: Dan Carpenter <error27@gmail.com>, Hansjoerg Lipp <hjlipp@web.de>,
	isdn4linux <isdn4linux@listserv.isdn4linux.de>,
	i4ldeveloper <i4ldeveloper@listserv.isdn4linux.de>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	stable@kernel.org
To: Karsten Keil <isdn@linux-pingi.de>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Correct a potential array overrun due to an off by one error in the
range check on the CAPI CONNECT_REQ CIPValue parameter.
Found and reported by Dan Carpenter using smatch.

Impact: bugfix
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/capi.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/isdn/gigaset/capi.c b/drivers/isdn/gigaset/capi.c
index 4a31962..0220c19 100644
--- a/drivers/isdn/gigaset/capi.c
+++ b/drivers/isdn/gigaset/capi.c
@@ -1301,7 +1301,7 @@ static void do_connect_req(struct gigaset_capi_ctr *iif,
 	}
 
 	/* check parameter: CIP Value */
-	if (cmsg->CIPValue > ARRAY_SIZE(cip2bchlc) ||
+	if (cmsg->CIPValue >= ARRAY_SIZE(cip2bchlc) ||
 	    (cmsg->CIPValue > 0 && cip2bchlc[cmsg->CIPValue].bc == NULL)) {
 		dev_notice(cs->dev, "%s: unknown CIP value %d\n",
 			   "CONNECT_REQ", cmsg->CIPValue);
-- 
1.6.5.3.298.g39add
