From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] gre: eliminate holes in ip_tunnel
Date: Wed, 13 Apr 2016 17:02:21 -0700
Message-ID: <20160413170221.6f158a74@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:35209 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932080AbcDNACJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2016 20:02:09 -0400
Received: by mail-pf0-f178.google.com with SMTP id n1so39896980pfn.2
        for <netdev@vger.kernel.org>; Wed, 13 Apr 2016 17:02:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The structure can be packed denser by doing minor rearrangement
of existing elements.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/include/net/ip_tunnels.h	2016-04-11 13:42:06.654666930 -0700
+++ b/include/net/ip_tunnels.h	2016-04-13 16:47:59.821692189 -0700
@@ -105,24 +105,23 @@ struct ip_tunnel {
 	struct net_device	*dev;
 	struct net		*net;	/* netns for packet i/o */
 
-	int		err_count;	/* Number of arrived ICMP errors */
 	unsigned long	err_time;	/* Time when the last ICMP error
 					 * arrived */
+	int		err_count;	/* Number of arrived ICMP errors */
 
 	/* These four fields used only by GRE */
 	u32		i_seqno;	/* The last seen seqno	*/
 	u32		o_seqno;	/* The last output seqno */
 	int		tun_hlen;	/* Precalculated header length */
-	int		mlink;
 
 	struct dst_cache dst_cache;
 
 	struct ip_tunnel_parm parms;
 
+	int		mlink;
 	int		encap_hlen;	/* Encap header length (FOU,GUE) */
-	struct ip_tunnel_encap encap;
-
 	int		hlen;		/* tun_hlen + encap_hlen */
+	struct ip_tunnel_encap encap;
 
 	/* for SIT */
 #ifdef CONFIG_IPV6_SIT_6RD
