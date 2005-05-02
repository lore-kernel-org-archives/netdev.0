From: "J. Simonetti" <jeroens@office.netland.nl>
Subject: icmp_unreachable uses wrong ip
Date: Mon, 02 May 2005 15:21:19 +0200
Message-ID: <1115040079.5620.11.camel@jeroens.office.netland.nl>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-Q2xJWlJ7VlmjEMgXdZYq"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-Q2xJWlJ7VlmjEMgXdZYq
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

I've recently come to notice that traceroutes through a linux router use
the wrong ip (ip of exitting interface) wich should actually be the ip
of the incomming interface.

I've found a trivial patch (attached) wich resolves this. Perhaps this
is something to include (or have a sysctl to toggle this behaviour). I
unfortunately have no knowledge of programming, so the sysctl option
would have te be done by a volunteer.

Regards,

Jeroen Simonetti
--
Netland Internet Services   http://www.netland.nl
I despise the pleasure of pleasing people whom I despise.

--=-Q2xJWlJ7VlmjEMgXdZYq
Content-Disposition: attachment; filename=icmp_traceroute.patch
Content-Type: text/x-patch; name=icmp_traceroute.patch; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

--- net/ipv4/icmp.orig   2005-05-02 04:55:53.512447464 +0200
+++ net/ipv4/icmp.c      2005-05-02 04:56:21.370212440 +0200
@@ -512,7 +512,7 @@
 
	saddr = iph->daddr;
	if (!(rt->rt_flags & RTCF_LOCAL))
-		saddr = 0;
+		saddr = inet_select_addr(skb_in->dev, 0, RT_SCOPE_LINK);
 
	tos = icmp_pointers[type].error ? ((iph->tos & IPTOS_TOS_MASK) |
					   IPTOS_PREC_INTERNETCONTROL) :

--=-Q2xJWlJ7VlmjEMgXdZYq--
