From: Kumar A Sanghvi <kumar.sanghvi@stericsson.com>
Subject: [PATCH 2/2] Documentation: Update Phonet doc for Pipe Controller implementation
Date: Tue, 28 Sep 2010 11:05:06 +0530
Message-ID: <1285652106-29966-1-git-send-email-kumar.sanghvi@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <STEricsson_nomadik_linux@list.st.com>,
	<sudeep.divakaran@stericsson.com>,
	<gulshan.karmani@stericsson.com>,
	Kumar Sanghvi <kumar.sanghvi@stericsson.com>,
	Linus Walleij <linus.walleij@stericsson.com>
To: <remi.denis-courmont@nokia.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog110.obsmtp.com ([207.126.144.129]:51152 "EHLO
	eu1sys200aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752998Ab0I1Ff2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Sep 2010 01:35:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kumar Sanghvi <kumar.sanghvi@stericsson.com>

Updates the Phonet document with description related to Pipe controller
implementation

Signed-off-by: Kumar Sanghvi <kumar.sanghvi@stericsson.com>
Acked-by: Linus Walleij <linus.walleij@stericsson.com>
---
 Documentation/networking/phonet.txt |   53 +++++++++++++++++++++++++++++++++++
 1 files changed, 53 insertions(+), 0 deletions(-)

diff --git a/Documentation/networking/phonet.txt b/Documentation/networking/phonet.txt
index cf76608..cccf5ff 100644
--- a/Documentation/networking/phonet.txt
+++ b/Documentation/networking/phonet.txt
@@ -182,6 +182,59 @@ The pipe protocol provides two socket options at the SOL_PNPIPE level:
     or zero if encapsulation is off.
 
 
+Phonet Pipe-controller Implementation
+-------------------------------------
+
+Phonet Pipe-controller is enabled by selecting the CONFIG_PHONET_PIPECTRLR Kconfig
+option. It is useful when communicating with those Nokia Modems which do not
+implement Pipe controller in them e.g. Nokia Slim Modem used in ST-Ericsson
+U8500 platform.
+
+The implementation is based on the Data Connection Establishment Sequence
+depicted in 'Nokia Wireless Modem API - Wireless_modem_user_guide.pdf'
+document.
+
+It allows a phonet sequenced socket (host-pep) to initiate a Pipe connection
+between itself and a remote pipe-end point (e.g. modem).
+
+The implementation adds socket options at SOL_PNPIPE level:
+
+ PNPIPE_CREATE
+	It accepts an integer argument where-in
+		lower order 16 bits: pn_dev and pn_port pair for remote pep.
+		higher order 16 bits: 8 bit pipe-handle
+
+	It sends a PNS_PEP_CONNECT_REQ on sequenced socket itself. On getting
+	PNS_PEP_CONNECT_RESP, it sends PNS_PEP_CONNECT_REQ to remote pep. On
+	getting response from remote pep, it selects the best possible Flow
+	control mechanism supported by remote-pep (modem) and then it sends
+	PNS_PEP_CREATED_IND to the sequenced socket and to the remote pep.
+
+	It then updates the pipe state associated with the sequenced socket to
+	be PIPE_DISABLED.
+
+  PNPIPE_ENABLE
+	It follows the same sequence as above for enabling a pipe by sending
+	PNS_PEP_ENABLE_REQ initially and then sending PNS_PEP_ENABLED_IND after
+	getting responses from sequenced socket and remote-pep.
+	It will also update the pipe state associated with the sequenced socket
+	to PIPE_ENABLED.
+
+   PNPIPE_DESTROY
+	This will send out PNS_PEP_DISCONNECT_REQ on the sequenced socket and
+	the remote pep.
+	It will also update the pipe state associated with the sequenced socket
+	to PIPE_IDLE
+
+   PNPIPE_INQ
+	This getsocktopt allows the user-space running on the sequenced socket
+	to examine the pipe state associated with that socket ie. whether the
+	pipe is created (PIPE_DISABLED) or enabled (PIPE_ENABLED) or disabled
+	(PIPE_DISABLED) or no pipe exists (PIPE_IDLE).
+
+After a pipe has been created and enabled successfully, the Pipe data can be
+exchanged between the host-pep and remote-pep (modem).
+
 Authors
 -------
 
-- 
1.7.2.dirty

