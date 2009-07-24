From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [net-next 6/10] bnx2x: Update vlan_features
Date: Fri, 24 Jul 2009 12:47:16 -0700
Message-ID: <3426.1248464836@death.nxdomain.ibm.com>
References: <1248191263.18195.49.camel@lb-tlvb-eilong> <4A683F83.1060701@trash.net> <4A68462C.1080709@Voltaire.com> <4A68479F.1000807@trash.net>
Cc: Or Gerlitz <ogerlitz@Voltaire.com>, eilong@broadcom.com,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:53123 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754085AbZGXTrP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2009 15:47:15 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n6OJh2aj005024
	for <netdev@vger.kernel.org>; Fri, 24 Jul 2009 13:43:02 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n6OJlFQm070666
	for <netdev@vger.kernel.org>; Fri, 24 Jul 2009 13:47:15 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n6OJlEns030420
	for <netdev@vger.kernel.org>; Fri, 24 Jul 2009 13:47:15 -0600
In-reply-to: <4A68479F.1000807@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy <kaber@trash.net> wrote:

>In case of bonding, its necessary to update vlan_features so it
>contains the intersection of all underlying devices. But a
>change will only take effect for existing VLANs (f.i. when
>enslaving a new device) if you call netdev_features_change().

	Patrick, can you clarify one bit about your above statment?  You
say the bonding features should be an "intersection"; is that a strict
intersection (i.e., slave1->vlan_features | slave2->vlan_features), or
does the NETIF_F_ONE_FOR_ALL logic apply for vlan_features as it does
for regular dev->features (using netdev_incrmenet_features() to combine
the feature sets)?

	In other words, if a bond has two slaves, one with, e.g.,
NETIF_F_SG in its vlan_features, and the other slave has 0 in
vlan_features, should the bond's vlan_features be NETIF_F_SG, or 0?

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
