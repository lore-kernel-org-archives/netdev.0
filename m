From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 0/5] vxlan: consolidate rx handling
Date: Tue, 23 Feb 2016 18:02:54 +0100
Message-ID: <cover.1456246786.git.jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42062 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752858AbcBWRDH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Feb 2016 12:03:07 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (Postfix) with ESMTPS id A5113AED25
	for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 17:03:07 +0000 (UTC)
Received: from griffin.upir.cz (ovpn-204-63.brq.redhat.com [10.40.204.63])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u1NH36AD008009
	for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 12:03:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, vxlan_rcv is just called at the end of vxlan_udp_encap_recv,
continuing the rx processing where vxlan_udp_encap_recv left it. There's no
clear border between those two functions. This patchset moves
vxlan_udp_encap_recv and vxlan_rcv into a single function.

This also allows to do some simplification in error path.

The VXLAN-GPE implementation that will follow up this set can be seen at:
https://github.com/jbenc/linux-vxlan/commits/master

Jiri Benc (5):
  vxlan: consolidate GBP handling even more
  vxlan: move inner L2 header processing to a separate function
  vxlan: move ECN decapsulation to a separate function
  vxlan: consolidate rx handling to a single function
  vxlan: simplify metadata_dst usage in vxlan_rcv

 drivers/net/vxlan.c | 131 +++++++++++++++++++++++++---------------------------
 1 file changed, 64 insertions(+), 67 deletions(-)

-- 
1.8.3.1
