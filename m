From: jamal <hadi@cyberus.ca>
Subject: [PATCH 3/3] [NET_DOC] Document some simple rules for actions
Date: Tue, 16 Oct 2007 08:33:31 -0400
Message-ID: <1192538011.4480.84.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-H+lQFj1C/e5PgFHXBQ8k"
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.232]:37249 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755916AbXJPMeC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 08:34:02 -0400
Received: by nz-out-0506.google.com with SMTP id s18so1203434nze
        for <netdev@vger.kernel.org>; Tue, 16 Oct 2007 05:34:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-H+lQFj1C/e5PgFHXBQ8k
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

cheers,
jamal


--=-H+lQFj1C/e5PgFHXBQ8k
Content-Disposition: attachment; filename=0003-NET_DOC-Document-some-simple-rules-for-actions
Content-Type: text/plain; name=0003-NET_DOC-Document-some-simple-rules-for-actions; charset=us-ascii
Content-Transfer-Encoding: 7bit

[NET_DOC] Document some simple rules for actions

This patch adds documentation on what is expected of an
action which branches away from the action-graph or when it
needs to trample on actins. It also describes what is expected of
users of such actions.

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>
---
 Documentation/networking/tc-actions-env-rules.txt |   29 +++++++++++++++++++++
 1 files changed, 29 insertions(+), 0 deletions(-)

diff --git a/Documentation/networking/tc-actions-env-rules.txt b/Documentation/networking/tc-actions-env-rules.txt
new file mode 100644
index 0000000..c684f48
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
+2) If you munge any packet thou shalt call skb_expand in the case
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


--=-H+lQFj1C/e5PgFHXBQ8k--

