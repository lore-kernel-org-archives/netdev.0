From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC PATCH 03/04]: packet: Store VLAN tag in auxillary data
Date: Tue, 08 Jul 2008 12:21:13 +0200
Message-ID: <48733F99.5010901@trash.net>
References: <48733E1B.8010501@trash.net> <48733E77.20808@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070609040704030803060000"
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55014 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751638AbYGHKVQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 06:21:16 -0400
Received: from [192.168.0.100] (unknown [78.42.204.165])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by stinky.trash.net (Postfix) with ESMTP id 83158948A4
	for <netdev@vger.kernel.org>; Tue,  8 Jul 2008 12:21:15 +0200 (MEST)
In-Reply-To: <48733E77.20808@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070609040704030803060000
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Missing patch attached.


--------------070609040704030803060000
Content-Type: text/x-diff;
 name="03.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="03.diff"

commit 97a314a172d9840f9c72ef12d7456b60891b4290
Author: Patrick McHardy <kaber@trash.net>
Date:   Tue Jul 8 11:38:43 2008 +0200

    packet: Store VLAN tag in auxillary data
    
    Store the VLAN tag in the auxillary data so userspace can properly deal with
    hardware VLAN tagging/stripping.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/if_packet.h b/include/linux/if_packet.h
index ad09609..4e1fc2a 100644
--- a/include/linux/if_packet.h
+++ b/include/linux/if_packet.h
@@ -57,6 +57,7 @@ struct tpacket_auxdata
 	__u32		tp_snaplen;
 	__u16		tp_mac;
 	__u16		tp_net;
+	__u16		tp_vlan_tci;
 };
 
 struct tpacket_hdr
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index beca640..951e62e 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1107,6 +1107,7 @@ static int packet_recvmsg(struct kiocb *iocb, struct socket *sock,
 		aux.tp_snaplen = skb->len;
 		aux.tp_mac = 0;
 		aux.tp_net = skb_network_offset(skb);
+		aux.tp_vlan_tci = skb->vlan_tci;
 
 		put_cmsg(msg, SOL_PACKET, PACKET_AUXDATA, sizeof(aux), &aux);
 	}

--------------070609040704030803060000--
