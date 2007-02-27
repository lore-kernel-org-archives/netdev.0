From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 2/2] [TCP] Sysctl documentation: tcp_frto_response
Date: Tue, 27 Feb 2007 17:50:39 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0702271742590.19465@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-906431768-1172591031=:19465"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:53422 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751821AbXB0Puj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Feb 2007 10:50:39 -0500
Content-ID: <Pine.LNX.4.64.0702271750100.19465@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-906431768-1172591031=:19465
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0702271744221.19465@kivilampi-30.cs.helsinki.fi>

In addition, fixed minor things in tcp_frto sysctl.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 Documentation/networking/ip-sysctl.txt |   21 +++++++++++++++++++--
 1 files changed, 19 insertions(+), 2 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index d66777b..95e2a9f 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -174,15 +174,32 @@ tcp_fin_timeout - INTEGER
 	because they eat maximum 1.5K of memory, but they tend
 	to live longer.	Cf. tcp_max_orphans.
 
-tcp_frto - BOOLEAN
+tcp_frto - INTEGER
 	Enables F-RTO, an enhanced recovery algorithm for TCP retransmission
 	timeouts.  It is particularly beneficial in wireless environments
 	where packet loss is typically due to random radio interference
 	rather than intermediate router congestion. If set to 1, basic
-	version is enabled. 2 enables SACK enhanced FRTO, which is
+	version is enabled. 2 enables SACK enhanced F-RTO, which is
 	EXPERIMENTAL. The basic version can be used also when SACK is
 	enabled for a flow through tcp_sack sysctl.
 
+tcp_frto_response - INTEGER
+	When F-RTO has detected that a TCP retransmission timeout was
+	spurious (i.e, the timeout would have been avoided had TCP set a
+	longer retransmission timeout), TCP has several options what to do
+	next. Possible values are:
+		0 Rate halving based; a smooth and conservative response,
+		  results in halved cwnd and ssthresh after one RTT
+		1 Very conservative response; not recommended because even
+		  though being valid, it interacts poorly with the rest of
+		  Linux TCP, halves cwnd and ssthresh immediately
+		2 Aggressive response; undoes congestion control measures
+		  that are now known to be unnecessary (ignoring the
+		  possibility of a lost retransmission that would require
+		  TCP to be more cautious), cwnd and ssthresh are restored
+		  to the values prior timeout
+	Default: 0 (rate halving based)
+
 tcp_keepalive_time - INTEGER
 	How often TCP sends out keepalive messages when keepalive is enabled.
 	Default: 2hours.
-- 
1.4.2
---696243703-906431768-1172591031=:19465--
