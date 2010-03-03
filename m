From: David Miller <davem@davemloft.net>
Subject: Re: TCP Appropriate Byte Counting per default off
Date: Wed, 03 Mar 2010 00:52:03 -0800 (PST)
Message-ID: <20100303.005203.43404344.davem@davemloft.net>
References: <A7D42088-84DC-4991-A8AD-E4000B2974DA@nets.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: zimmermann@nets.rwth-aachen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53633
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754088Ab0CCIvq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Mar 2010 03:51:46 -0500
In-Reply-To: <A7D42088-84DC-4991-A8AD-E4000B2974DA@nets.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Zimmermann <zimmermann@nets.rwth-aachen.de>
Date: Wed, 03 Mar 2010 09:21:44 +0100

> I wonder why ABC is off per default? What are the reasons?
> Should we turn it on per default?

Is it so much work to do some research and look at what
was said when the default was changed to off?

Really?

There are also relevant discussions on this mailing list
during the time period surrounding when this change went
in, Sept 13th, 2006

commit b3a8a40da5751525936c88f60bbc6a007f9eee37
Author: Stephen Hemminger <shemminger@osdl.org>
Date:   Wed Sep 13 19:51:02 2006 -0700

    [TCP]: Turn ABC off.
    
    Turn Appropriate Byte Count off by default because it unfairly
    penalizes applications that do small writes.  Add better documentation
    to describe what it is so users will understand why they might want to
    turn it on.
    
    Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
    Signed-off-by: David S. Miller <davem@davemloft.net>

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
