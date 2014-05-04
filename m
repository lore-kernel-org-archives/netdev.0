From: Vincent Bernat <vincent@bernat.im>
Subject: [PATCH] tcp: more documentation for tcp_tw_reuse and tcp_tw_recycle
Date: Sun,  4 May 2014 11:41:39 +0200
Message-ID: <1399196499-8449-2-git-send-email-vincent@bernat.im>
References: <1399196499-8449-1-git-send-email-vincent@bernat.im>
Cc: Vincent Bernat <vincent@bernat.im>
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, linux-doc@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1399196499-8449-1-git-send-email-vincent@bernat.im>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The documentation is not very helpful about what those settings
affect. We find numerous tuning guides advising to set both these
settings to 1 to reduce the number of entries in the TIME-WAIT
state. However, enabling tcp_tw_recycle will cause massive problems when
working with NAT.

The documentation is completed a bit to explain quickly what kind of
connections both those settings will affect and to encourage the use of
tcp_tw_reuse instead of tcp_tw_recycle for outgoing connections.
---
 Documentation/networking/ip-sysctl.txt | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index ab42c95f9985..d771aa064af8 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -532,14 +532,18 @@ tcp_tso_win_divisor - INTEGER
 	Default: 3
 
 tcp_tw_recycle - BOOLEAN
-	Enable fast recycling TIME-WAIT sockets. Default value is 0.
-	It should not be changed without advice/request of technical
+	Enable fast recycling TIME-WAIT sockets. Default value is
+	0. Enabling this option will cause problems when incoming
+	connections originate from NAT devices. For outgoing
+	connections, prefer the use of tcp_tw_reuse which is safer. It
+	should not be changed without advice/request of technical
 	experts.
 
 tcp_tw_reuse - BOOLEAN
-	Allow to reuse TIME-WAIT sockets for new connections when it is
-	safe from protocol viewpoint. Default value is 0.
-	It should not be changed without advice/request of technical
+	Allow to reuse TIME-WAIT sockets for new outgoing connections
+	when it is safe from protocol viewpoint. Default value is
+	0. This parameter has no effect on incoming connections.  It
+	should not be changed without advice/request of technical
 	experts.
 
 tcp_window_scaling - BOOLEAN
-- 
2.0.0.rc0

