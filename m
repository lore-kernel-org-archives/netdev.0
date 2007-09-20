From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 7/9] [TCP] FRTO: Update sysctl documentation
Date: Thu, 20 Sep 2007 15:17:50 +0300
Message-ID: <1190290672980-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11902906724088-git-send-email-ilpo.jarvinen@helsinki.fi> <11902906721846-git-send-email-ilpo.jarvinen@helsinki.fi> <11902906723619-git-send-email-ilpo.jarvinen@helsinki.fi> <11902906723822-git-send-email-ilpo.jarvinen@helsinki.fi> <1190290672770-git-send-email-ilpo.jarvinen@helsinki.fi> <11902906721671-git-send-email-ilpo.jarvinen@helsinki.fi> <11902906723159-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:45006 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752892AbXITMRz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 08:17:55 -0400
In-Reply-To: <11902906723159-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since the SACK enhanced FRTO was added, the code has been
under test numerous times so remove "experimental" claim
from the documentation. Also be a bit more verbose about
the usage.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 Documentation/networking/ip-sysctl.txt |   17 ++++++++++++-----
 1 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/net=
working/ip-sysctl.txt
index 32c2e9d..6ae2fef 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -180,13 +180,20 @@ tcp_fin_timeout - INTEGER
 	to live longer.	Cf. tcp_max_orphans.
=20
 tcp_frto - INTEGER
-	Enables F-RTO, an enhanced recovery algorithm for TCP retransmission
+	Enables Forward RTO-Recovery (F-RTO) defined in RFC4138.
+	F-RTO is an enhanced recovery algorithm for TCP retransmission
 	timeouts.  It is particularly beneficial in wireless environments
 	where packet loss is typically due to random radio interference
-	rather than intermediate router congestion. If set to 1, basic
-	version is enabled. 2 enables SACK enhanced F-RTO, which is
-	EXPERIMENTAL. The basic version can be used also when SACK is
-	enabled for a flow through tcp_sack sysctl.
+	rather than intermediate router congestion.  FRTO is sender-side
+	only modification.  Therefore it does not require any support from
+	the peer, but in a typical case, however, where wireless link is
+	the local access link and most of the data flows downlink, the
+	faraway servers should have FRTO enabled to take advantage of it.
+	If set to 1, basic version is enabled.  2 enables SACK enhanced
+	F-RTO if flow uses SACK.  The basic version can be used also when
+	SACK is in use though scenario(s) with it exists where FRTO
+	interacts badly with the packet counting of the SACK enabled TCP
+	flow.
=20
 tcp_frto_response - INTEGER
 	When F-RTO has detected that a TCP retransmission timeout was
--=20
1.5.0.6

