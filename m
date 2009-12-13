From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 4/9] drivers/net/sfc: Correct code taking the size of a
 pointer
Date: Sun, 13 Dec 2009 12:41:29 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0912131241130.24267@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: linux-net-drivers@solarflare.com,
	Steve Hodgson <shodgson@solarflare.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-jan
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:39091 "HELO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752644AbZLMLlb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Dec 2009 06:41:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

The function efx_iterate_state contains the code
memcpy(&payload->msg, payload_msg, sizeof(payload_msg));
This is the only use of payload_msg.  The type of payload_msg is
changed from a pointer to an array, so that the result of sizeof really is
the length of the string.

A simplified version of the semantic patch that finds this problem is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@@
expression *x;
expression f;
type T;
@@

*f(...,(T)x,...)
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/net/sfc/selftest.c          |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index 14949bb..af39335 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -47,7 +47,7 @@ static const unsigned char payload_source[ETH_ALEN] = {
 	0x00, 0x0f, 0x53, 0x1b, 0x1b, 0x1b,
 };
 
-static const char *payload_msg =
+static const char payload_msg[] =
 	"Hello world! This is an Efx loopback test in progress!";
 
 /**
