From: "Rosen, Rami" <rami.rosen@intel.com>
Subject: RE: [PATCH iproute2 2/2] tc/act_tunnel: Introduce ip tunnel action
Date: Mon, 21 Nov 2016 23:50:03 +0000
Message-ID: <9B0331B6EBBD0E4684FBFAEDA55776F93D345ED8@HASMSX110.ger.corp.intel.com>
References: <20161121102056.13468-1-amir@vadai.me>
 <20161121102056.13468-3-amir@vadai.me>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Roi Dayan <roid@mellanox.com>
To: Amir Vadai <amir@vadai.me>,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:8748 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752505AbcKUXuS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Nov 2016 18:50:18 -0500
In-Reply-To: <20161121102056.13468-3-amir@vadai.me>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Amir,

Following are three minor comments:

Seems that TCA_TUNNEL_KEY_PAD used anywhere:
 
+	TCA_TUNNEL_KEY_PAD,
+	__TCA_TUNNEL_KEY_MAX,
+};


Should be "and destination IP 11.11.0.2" instead of  "and destination IP 11.11.0.1":

+Tunnel ID (for example VNI in VXLAN tunnel) .TP .B src_ip Outer header 
+source IP address (IPv4 or IPv6) .TP .B dst_ip Outer header destination 
+IP address (IPv4 or IPv6) .RE .SH EXAMPLES The following example 
+encapsulates incoming ICMP packets on eth0 into a vxlan tunnel by 
+setting metadata to VNI 11, source IP 11.11.0.1 and destination IP
+11.11.0.1 by forwarding the skb with the metadata to device vxlan0, 
+which will prepare the VXLAN headers:
+
+.RS
+.EX
+#tc qdisc add dev eth0 handle ffff: ingress #tc filter add dev eth0 
+protocol ip parent ffff: \\
+  flower \\
+    ip_proto icmp \\
+  action tunnel_key set \\
+    src_ip 11.11.0.1 \\
+    dst_ip 11.11.0.2 \\
+    id 11 \\


Typo: should be "ip tunnel" instead of "ip tunel":

+ * m_tunnel_key.c	ip tunel manipulation module
+ *
+ *              This program is free software; you can redistribute it and/or

Keep on the good work!

Regards,
Rami Rosen
Intel Corporation
