From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 0/5] vxlan: implement Generic Protocol Extension (GPE)
Date: Fri, 26 Feb 2016 08:48:36 +0100
Message-ID: <cover.1456472746.git.jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39667 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753383AbcBZHsz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Feb 2016 02:48:55 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (Postfix) with ESMTPS id 37BEFC057EC9
	for <netdev@vger.kernel.org>; Fri, 26 Feb 2016 07:48:55 +0000 (UTC)
Received: from griffin.upir.cz (ovpn-204-33.brq.redhat.com [10.40.204.33])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u1Q7mrUt021506
	for <netdev@vger.kernel.org>; Fri, 26 Feb 2016 02:48:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

VXLAN-GPE can operate in two modes: with encapsulated Ethernet header
(L2 mode) or with L3 header (e.g. IP header) directly following VXLAN-GPE
header (L3 mode).

Add support for both modes. The L2 mode is simple, as it's basically the
same as plain VXLAN, only with added bits in the header. The L3 mode is more
complicated. The patches adding it follow the same model as the tun/tap
driver: depending on the chosen mode, the vxlan interface is created either
as ARPHRD_ETHER (L2 mode) or ARPHRD_NONE (L3 mode).

Note that the internal fdb control plane cannot be used together with
VXLAN-GPE and attempt to configure it will be rejected by the driver. This
in theory could be relaxed for L2 mode in the future if such need arises.

Jiri Benc (5):
  vxlan: implement GPE in L2 mode
  vxlan: move L2 mode initialization to a separate function
  vxlan: move fdb code to common location in vxlan_xmit
  vxlan: fix too large pskb_may_pull with remote checksum
  vxlan: implement GPE in L3 mode

 drivers/net/vxlan.c          | 223 ++++++++++++++++++++++++++++++++++++-------
 include/net/vxlan.h          |  63 +++++++++++-
 include/uapi/linux/if_link.h |   9 ++
 3 files changed, 258 insertions(+), 37 deletions(-)

-- 
1.8.3.1
