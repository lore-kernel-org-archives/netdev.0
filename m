From: "Miroslav Kratochvil" <exa.exa@gmail.com>
Subject: r8169 driver compatibility with rtl8168 [need confirm]
Date: Mon, 25 Feb 2008 23:03:58 +0100
Message-ID: <a37929f0802251403q36ef6306wa30298dbded0d8ed@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.190]:11103 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756695AbYBYWEC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2008 17:04:02 -0500
Received: by ti-out-0910.google.com with SMTP id 28so1125147tif.23
        for <netdev@vger.kernel.org>; Mon, 25 Feb 2008 14:04:00 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
Many users who have onboard Realtek 8168 network controllers in
combination with nVidia hardware (mostly nVidia graphic card and/or
nForce motherboard (MCP5x) ) experience still-not-very-explained
hangup triggered by heavy network usage which fills a tx buffer, and
(speculation) causes race condition on irq sharing, resulting in
absolute freeze (not oops/panic). On all affected machines I've seen
this fix solved the problem:

--- a/drivers/net/r8169.c   2008-02-25 22:53:01.000000000 +0100
+++ b/drivers/net/r8169.c   2008-02-25 22:54:32.000000000 +0100
@@ -86,8 +86,8 @@

 #define R8169_REGS_SIZE                256
 #define R8169_NAPI_WEIGHT      64
-#define NUM_TX_DESC    64      /* Number of Tx descriptor registers */
-#define NUM_RX_DESC    256     /* Number of Rx descriptor registers */
+#define NUM_TX_DESC    1024    /* Number of Tx descriptor registers */
+#define NUM_RX_DESC    1024    /* Number of Rx descriptor registers */
 #define RX_BUF_SIZE    1536    /* Rx Buffer size */
 #define R8169_TX_RING_BYTES    (NUM_TX_DESC * sizeof(struct TxDesc))
 #define R8169_RX_RING_BYTES    (NUM_RX_DESC * sizeof(struct RxDesc))

It's not really a fix, we do not address the real race cond. (or
whatever) problem, but it removes the hangup and causes no negative
side effects. I need someone else who can confirm that it works.

cheers,
[exa]

PS. There might already be some fixes, but I didn't manage to find them.
