From: Chuck Ebbert <cebbert@redhat.com>
Subject: [Fwd: [PATCH] allow VLAN interface on top of bridge interface]
Date: Thu, 12 Apr 2007 16:54:50 -0400
Message-ID: <461E9C9A.5010404@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:53554 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753504AbXDLUyw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Apr 2007 16:54:52 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l3CKspqO020834
	for <netdev@vger.kernel.org>; Thu, 12 Apr 2007 16:54:51 -0400
Received: from mail.boston.redhat.com (mail.boston.redhat.com [172.16.76.12])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l3CKsoOV007854
	for <netdev@vger.kernel.org>; Thu, 12 Apr 2007 16:54:50 -0400
Received: from [172.16.83.145] (dhcp83-145.boston.redhat.com [172.16.83.145])
	by mail.boston.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id l3CKsoD0030335
	for <netdev@vger.kernel.org>; Thu, 12 Apr 2007 16:54:50 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Date: Thu, 12 Apr 2007 21:50:00 +0200 (CEST)
From: Jerome Borsboom <j.borsboom@erasmusmc.nl>
To: linux-kernel@vger.kernel.org
Subject: [PATCH] allow VLAN interface on top of bridge interface
Message-ID: <Pine.LNX.4.64.0704122136330.3170@knorkaan.xs4all.nl>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: linux-kernel-owner@vger.kernel.org
Precedence: bulk

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

