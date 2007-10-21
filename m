From: jamal <hadi@cyberus.ca>
Subject: [PATCH 3/3] [NET_DOC] Document some simple rules for actions
Date: Sun, 21 Oct 2007 15:22:17 -0400
Message-ID: <1192994537.4422.22.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-RB6/usrxQRwr4x72CKzL"
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.227]:9722 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751838AbXJUTWX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Oct 2007 15:22:23 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1132842wxd
        for <netdev@vger.kernel.org>; Sun, 21 Oct 2007 12:22:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-RB6/usrxQRwr4x72CKzL
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Against net-2.6

cheers,
jamal

--=-RB6/usrxQRwr4x72CKzL
Content-Disposition: attachment; filename=0003-NET_DOC-Document-some-simple-rules-for-actions.txt
Content-Type: application/mbox; name=0003-NET_DOC-Document-some-simple-rules-for-actions.txt
Content-Transfer-Encoding: 7bit

>From 553443b79e997afcc13f305f011b129dea9d8bde Mon Sep 17 00:00:00 2001
From: Jamal Hadi Salim <hadi@cyberus.ca>
Date: Sun, 21 Oct 2007 15:05:28 -0400
Subject: [PATCH 3/3] [NET_DOC] Document some simple rules for actions

This patch adds documentation on what is expected of an
action which branches away from the action-graph or when it
needs to trample on actins. It also describes what is expected of
users of such actions.
---
 Documentation/networking/tc-actions-env-rules.txt |   29 +++++++++++++++++++++
 1 files changed, 29 insertions(+), 0 deletions(-)

diff --git a/Documentation/networking/tc-actions-env-rules.txt b/Documentation/networking/tc-actions-env-rules.txt
new file mode 100644
index 0000000..c7b545a
--- /dev/null
+++ b/Documentation/networking/tc-actions-env-rules.txt
@@ -0,0 +1,29 @@
+
+The "enviromental" rules for authors of any new tc actions are:   
+
+1) If you stealeth or borroweth any packet thou shalt be branching 
+from the righteous path and thou shalt cloneth. 
+
+For example if your action queues a packet to be processed later
+or intentionaly branches by redirecting a packet then you need to 
+clone the packet. 
+There are certain fields in the skb tc_verd that need to be reset so we
+avoid loops etc. A few are generic enough so much so that skb_act_clone() 
+resets them for you. So invoke skb_act_clone() rather than skb_clone()
+
+2) If you munge any packet thou shalt call pskb_expand_head in the case
+someone else is referencing the skb. After that you "own" the skb. 
+You must also tell us if it is ok to munge the packet (TC_OK2MUNGE), 
+this way any action downstream can stomp on the packet.
+
+3) dropping packets you dont own is a nono. You simply return
+TC_ACT_SHOT to the caller and they will drop it.
+
+The "enviromental" rules for callers of actions (qdiscs etc) are:
+
+*) thou art responsible for freeing anything returned as being
+TC_ACT_SHOT/STOLEN/QUEUED. If none of TC_ACT_SHOT/STOLEN/QUEUED is
+returned then all is great and you dont need to do anything.
+
+Post on netdev if something is unclear.
+
-- 
1.4.4.1.gaed4


--=-RB6/usrxQRwr4x72CKzL--

