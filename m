From: Jeremy Eder <jeder@redhat.com>
Subject: [PATCH net-next-2.6] clarify documentation for
 net.ipv4.igmp_max_memberships
Date: Mon, 15 Nov 2010 10:41:31 -0500
Message-ID: <1289835691.8257.1274.camel@jerms-wks.usersys.redhat.com>
Reply-To: jeder@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: rdunlap@xenotime.net, davem@davemloft.net, opurdila@ixiacom.com,
	apetlund@simula.no, William.Allen.Simpson@gmail.com,
	ian.campbell@citrix.com, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jiri Pirko <jpirko@redhat.com>
To: netdev@vger.kernel.org
Return-path: <linux-doc-owner@vger.kernel.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch helps clarify documentation for
net.ipv4.igmp_max_memberships by providing a formula for
calculating the maximum number of multicast groups that can be
subscribed to, plus defining the theoretical limit.





Signed-off-by: Jiri Pirko <jpirko@redhat.com>
Signed-off-by: Jeremy Eder <jeder@redhat.com>


diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index fe95105..ae55227 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -707,10 +707,28 @@ igmp_max_memberships - INTEGER
 	Change the maximum number of multicast groups we can subscribe to.
 	Default: 20
 
-conf/interface/*  changes special settings per interface (where "interface" is
-		  the name of your network interface)
-conf/all/*	  is special, changes the settings for all interfaces
+	Theoretical maximum value is bounded by having to send a membership
+	report in a single datagram (i.e. the report can't span multiple
+	datagrams, or risk confusing the switch and leaving groups you don't
+	intend to).
 
+	The number of supported groups 'M' is bounded by the number of group
+	report entries you can fit into a single datagram of 65535 bytes.
+
+	M = 65536-sizeof (ip header)/(sizeof(Group record))
+
+	Group records are variable length, with a minimum of 12 bytes.
+	So net.ipv4.igmp_max_memberships should not be set higher than:
+
+	(65536-24) / 12 = 5459
+
+	The value 5459 assumes no IP header options, so in practice
+	this number may be lower.
+
+	conf/interface/*  changes special settings per interface (where
+	"interface" is the name of your network interface)
+
+	conf/all/*	  is special, changes the settings for all interfaces
 
 log_martians - BOOLEAN
 	Log packets with impossible addresses to kernel log.


