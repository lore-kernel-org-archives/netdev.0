From: Andrew Morton <akpm@linux-foundation.org>
Subject: Fw: [PATCH] allow VLAN interface on top of bridge interface
Date: Thu, 12 Apr 2007 14:34:56 -0700
Message-ID: <20070412143456.2e4019f0.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jerome Borsboom <j.borsboom@erasmusmc.nl>,
	Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:32976 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751948AbXDLVfA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Apr 2007 17:35:00 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Thu, 12 Apr 2007 21:50:00 +0200 (CEST)
From: Jerome Borsboom <j.borsboom@erasmusmc.nl>
To: linux-kernel@vger.kernel.org
Subject: [PATCH] allow VLAN interface on top of bridge interface


When a VLAN interface is created on top of a bridge interface and 
netfilter is enabled to see the bridged packets, the packets can be 
corrupted when passing through the netfilter code. This is caused by the 
VLAN driver not setting the 'protocol' and 'nh' members of the sk_buff 
structure. In general, this is no problem as the VLAN interface is mostly 
connected to a physical ethernet interface which does not use the 
'protocol' and 'nh' members. For a bridge interface, however, these 
members do matter.

Signed-off-by: Jerome Borsboom <j.borsboom@erasmusmc.nl>


--- linux-2.6.20/net/8021q/vlan_dev.c 2007-02-04 19:44:54.000000000 +0100 
+++ linux-2.6.20/net/8021q/vlan_dev.c 2007-04-12 21:12:17.000000000 +0200 
@@ -380,6 +380,9 @@
  		} else {
  			vhdr->h_vlan_encapsulated_proto = htons(len);
  		}
+
+		skb->protocol = htons(ETH_P_8021Q);
+		skb->nh.raw = skb->data;
  	}

  	/* Before delegating work to the lower layer, enter our MAC-address */
-
To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/
