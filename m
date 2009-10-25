From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 2/9] gigaset: fix format string typo in CAPI dial command
Date: Sun, 25 Oct 2009 20:29:47 +0100 (CET)
Message-ID: <20091023-patch-gigaset-02.tilman@imap.cc>
References: <20091023-patch-gigaset-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, isdn4linux@listserv.isdn4linux.de,
	i4ldeveloper@listserv.isdn4linux.de
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754071AbZJYT34@vger.kernel.org>
In-Reply-To: <20091023-patch-gigaset-00.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A missing dot lead to garbage characters being included in the
dial command generated from a CAPI CONNECT_REQ message, which
interestingly enough worked anyway, illustrating the resilience
of the device.

Impact: bugfix
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/capi.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/isdn/gigaset/capi.c b/drivers/isdn/gigaset/capi.c
index ac0a2da..d1afac2 100644
--- a/drivers/isdn/gigaset/capi.c
+++ b/drivers/isdn/gigaset/capi.c
@@ -1254,7 +1254,7 @@ static void do_connect_req(struct gigaset_capi_ctr *iif,
 	commands[AT_DIAL] = kmalloc(l+3, GFP_KERNEL);
 	if (!commands[AT_DIAL])
 		goto oom;
-	snprintf(commands[AT_DIAL], l+3, "D%*s\r", l, pp);
+	snprintf(commands[AT_DIAL], l+3, "D%.*s\r", l, pp);
 
 	/* encode parameter: Calling party number */
 	pp = cmsg->CallingPartyNumber;
-- 
1.6.2.1.214.ge986c
