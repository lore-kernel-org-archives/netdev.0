From: Nivedita Singhvi <niv@us.ibm.com>
Subject: [patch 2.5.44+] IpInUnknownProtos support
Date: Mon, 28 Oct 2002 17:18:04 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0210281713230.2033-100000@w-nivedita.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This adds the update for the SNMP MIB counter
IpInUnknownProtos (to catch all those unrecognized
sctp packets ;)) for ipv4. 

thanks,
Nivedita

diff -urN linux-2.5.44s1/net/ipv4/ip_input.c linux-2.5.44s2/net/ipv4/ip_input.c
--- linux-2.5.44s1/net/ipv4/ip_input.c	Mon Oct 28 17:05:40 2002
+++ linux-2.5.44s2/net/ipv4/ip_input.c	Mon Oct 28 17:00:58 2002
@@ -240,6 +240,7 @@
 			IP_INC_STATS_BH(IpInDelivers);
 		} else {
 			if (!raw_sk) {
+				IP_INC_STATS_BH(IpInUnknownProtos);
 				icmp_send(skb, ICMP_DEST_UNREACH,
 					  ICMP_PROT_UNREACH, 0);
 			} else
