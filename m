From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] tcp: turn ABC off
Date: Fri, 1 Sep 2006 13:55:15 -0700
Message-ID: <20060901135515.3f900340@localhost.localdomain>
References: <20060831151456.12a4e080@dxpl.pdx.osdl.net>
	<20060831.154428.35684218.davem@davemloft.net>
	<20060831232923.GA10036@ms2.inr.ac.ru>
	<20060831.165701.104033558.davem@davemloft.net>
	<20060901094715.GB13855@ms2.inr.ac.ru>
	<20060901110038.GA3651@2ka.mipt.ru>
	<20060901090046.69b3d583@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, alex@sectorb.msk.ru,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:53463 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750804AbWIAUzx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2006 16:55:53 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060901090046.69b3d583@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Turn Appropriate Byte Count off by default because it unfairly penalizes
applications that do small writes.
Add better documentation to describe what it is so users will understand
why they might want to turn it on.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---

 Documentation/networking/ip-sysctl.txt |   12 +++++++++---
 net/ipv4/tcp_input.c                   |    2 +-
 2 files changed, 10 insertions(+), 4 deletions(-)

3988eb0b87288c0d30c165742af7fc7a733100ab
diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 3e0c017..90ed781 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -102,9 +102,15 @@ inet_peer_gc_maxtime - INTEGER
 TCP variables: 
 
 tcp_abc - INTEGER
-	Controls Appropriate Byte Count defined in RFC3465. If set to
-	0 then does congestion avoid once per ack. 1 is conservative
-	value, and 2 is more agressive.
+	Controls Appropriate Byte Count (ABC) defined in RFC3465.
+	ABC is a way of increasing congestion window (cwnd) more slowly
+	in response to partial acknowledgments.
+	Possible values are:
+		0 increase cwnd once per acknowledgment (no ABC)
+		1 increase cwnd once per acknowledgment of full sized segment
+		2 allow increase cwnd by two if acknowledgment is
+		  of two segments to compensate for delayed acknowledgments.
+	Default: 0 (off)
 
 tcp_syn_retries - INTEGER
 	Number of times initial SYNs for an active TCP connection attempt
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 111ff39..159fa3f 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -89,7 +89,7 @@ int sysctl_tcp_frto;
 int sysctl_tcp_nometrics_save;
 
 int sysctl_tcp_moderate_rcvbuf = 1;
-int sysctl_tcp_abc = 1;
+int sysctl_tcp_abc;
 
 #define FLAG_DATA		0x01 /* Incoming frame contained data.		*/
 #define FLAG_WIN_UPDATE		0x02 /* Incoming ACK was a window update.	*/
-- 
1.2.4


-- 
VGER BF report: U 0.5
