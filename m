From: raj@tardy.usa.hp.com (Rick Jones)
Subject: [PATCH net-next] doc: Tighten-up and clarify description of tcp_fin_timeout
Date: Mon, 10 Dec 2012 13:33:00 -0800 (PST)
Message-ID: <20121210213300.9D6BB29003EA@tardy>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:14925 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751353Ab2LJVdG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2012 16:33:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>

The description for tcp_fin_timeout should be tigher and more clear.

In addition to being tighter, we should make the spelling of the
state name consistent with what utilities report, remove the now
dated reference to 2.2 and put the default in the consistent place.

Signed-off-by: Rick Jones <rick.jones2@hp.com>

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 1b830ca..f486c86 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -224,15 +224,14 @@ tcp_fack - BOOLEAN
 	The value is not used, if tcp_sack is not enabled.
 
 tcp_fin_timeout - INTEGER
-	Time to hold socket in state FIN-WAIT-2, if it was closed
-	by our side. Peer can be broken and never close its side,
-	or even died unexpectedly. Default value is 60sec.
-	Usual value used in 2.2 was 180 seconds, you may restore
-	it, but remember that if your machine is even underloaded WEB server,
-	you risk to overflow memory with kilotons of dead sockets,
-	FIN-WAIT-2 sockets are less dangerous than FIN-WAIT-1,
-	because they eat maximum 1.5K of memory, but they tend
-	to live longer.	Cf. tcp_max_orphans.
+	The length of time an orphaned (no longer referenced by any
+	application) connection will remain in the FIN_WAIT_2 state
+	before it is aborted at the local end.  While a perfectly
+	valid "receive only" state for an un-orphaned connection, an
+	orphaned connection in FIN_WAIT_2 state could otherwise wait
+	forever for the remote to close its end of the connection.
+	Cf. tcp_max_orphans
+	Default: 60 seconds
 
 tcp_frto - INTEGER
 	Enables Forward RTO-Recovery (F-RTO) defined in RFC4138.
