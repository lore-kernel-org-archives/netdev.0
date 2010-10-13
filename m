From: Kumar A Sanghvi <kumar.sanghvi@stericsson.com>
Subject: [PATCH] Documentation: Update Phonet doc for Pipe controller changes
Date: Wed, 13 Oct 2010 11:47:25 +0530
Message-ID: <1286950645-21902-1-git-send-email-kumar.sanghvi@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linus.walleij@stericsson.com>, <gulshan.karmani@stericsson.com>,
	<sudeep.divakaran@stericssonc.com>,
	Kumar Sanghvi <kumar.sanghvi@stericsson.com>
To: <remi.denis-courmont@nokia.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog104.obsmtp.com ([207.126.144.117]:36984 "EHLO
	eu1sys200aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752840Ab0JMGSD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Oct 2010 02:18:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kumar Sanghvi <kumar.sanghvi@stericsson.com>

Updates to Phonet doc for Pipe controller 'connect' socket
implementation and changes related to socket options.

Signed-off-by: Kumar Sanghvi <kumar.sanghvi@stericsson.com>
---
 Documentation/networking/phonet.txt |   32 ++++++++++++++------------------
 1 files changed, 14 insertions(+), 18 deletions(-)

diff --git a/Documentation/networking/phonet.txt b/Documentation/networking/phonet.txt
index 2d9bc2b..24ad2ad 100644
--- a/Documentation/networking/phonet.txt
+++ b/Documentation/networking/phonet.txt
@@ -199,33 +199,29 @@ between itself and a remote pipe-end point (e.g. modem).
 
 The implementation adds socket options at SOL_PNPIPE level:
 
- PNPIPE_CREATE
-	It accepts an integer argument where-in
-		lower order 16 bits: pn_dev and pn_port pair for remote pep.
-		higher order 16 bits: 8 bit pipe-handle
-
-	It sends a PNS_PEP_CONNECT_REQ on sequenced socket itself. On getting
-	PNS_PEP_CONNECT_RESP, it sends PNS_PEP_CONNECT_REQ to remote pep. On
-	getting response from remote pep, it selects the best possible Flow
-	control mechanism supported by remote-pep (modem) and then it sends
-	PNS_PEP_CREATED_IND to the sequenced socket and to the remote pep.
-
-	It then updates the pipe state associated with the sequenced socket to
-	be PIPE_DISABLED.
+ PNPIPE_PIPE_HANDLE
+	It accepts an integer argument for setting value of pipe handle.
 
   PNPIPE_ENABLE accepts one integer value (int). If set to zero, the pipe
     is disabled. If the value is non-zero, the pipe is enabled. If the pipe
     is not (yet) connected, ENOTCONN is error is returned.
 
-   PNPIPE_DESTROY
-	This will send out PNS_PEP_DISCONNECT_REQ on the sequenced socket and
-	the remote pep.
-	It will also update the pipe state associated with the sequenced socket
-	to PIPE_IDLE
+The implementation also adds socket 'connect'. On calling the 'connect', pipe
+will be created between the source socket and the destination, and the pipe
+state will be set to PIPE_DISABLED.
 
 After a pipe has been created and enabled successfully, the Pipe data can be
 exchanged between the host-pep and remote-pep (modem).
 
+User-space would typically follow below sequence with Pipe controller:-
+-socket
+-bind
+-setsockopt for PNPIPE_PIPE_HANDLE
+-connect
+-setsockopt for PNPIPE_ENCAP_IP
+-setsockopt for PNPIPE_ENABLE
+
+
 Authors
 -------
 
-- 
1.7.2.dirty

