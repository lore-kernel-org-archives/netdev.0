From: akpm@linux-foundation.org
Subject: [patch 6/6] isdn: eicon, return on error
Date: Fri, 18 Sep 2009 12:53:06 -0700
Message-ID: <200909181953.n8IJr7ew026389@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	jirislaby@gmail.com, armin@melware.de
To: isdn@linux-pingi.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:35462 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757941AbZIRUCG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2009 16:02:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Slaby <jirislaby@gmail.com>

When diva_strace_read_uint returns an error, return even from
process_idi_event, because l2_state is uninitialized.

Signed-off-by: Jiri Slaby <jirislaby@gmail.com>
Cc: Karsten Keil <isdn@linux-pingi.de>
Acked-by: Armin Schindler <armin@melware.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/isdn/hardware/eicon/maintidi.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff -puN drivers/isdn/hardware/eicon/maintidi.c~isdn-eicon-return-on-error drivers/isdn/hardware/eicon/maintidi.c
--- a/drivers/isdn/hardware/eicon/maintidi.c~isdn-eicon-return-on-error
+++ a/drivers/isdn/hardware/eicon/maintidi.c
@@ -959,8 +959,9 @@ static int process_idi_event (diva_strac
 	}
 	if (!strncmp("State\\Layer2 No1", path, pVar->path_length)) {
 		char* tmp = &pLib->lines[0].pInterface->Layer2[0];
-    dword l2_state;
-    diva_strace_read_uint (pVar, &l2_state);
+		dword l2_state;
+		if (diva_strace_read_uint(pVar, &l2_state))
+			return -1;
 
 		switch (l2_state) {
 			case 0:
_
