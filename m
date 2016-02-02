From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next v2 0/6] vxlan: cleanup headers and tx path
Date: Tue,  2 Feb 2016 18:09:10 +0100
Message-ID: <cover.1454432731.git.jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47095 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753357AbcBBRJY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2016 12:09:24 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (Postfix) with ESMTPS id 3EC287AE88
	for <netdev@vger.kernel.org>; Tue,  2 Feb 2016 17:09:24 +0000 (UTC)
Received: from griffin.upir.cz (ovpn-204-49.brq.redhat.com [10.40.204.49])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u12H9NSl003510
	for <netdev@vger.kernel.org>; Tue, 2 Feb 2016 12:09:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is first part of vxlan cleanup. It makes vxlan.h better organized and
removes code duplication in the tx path. There's no change in functionality.

This is in preparation for VXLAN-GPE support. Other sets will follow with
cleanup of rx path, modifications of vxlan interface setup and
cleanup/modification of fdb handling. The goal of these patchsets is to
consolidate VXLAN extension handling (right now it's scattered all around
the code) and allow vxlan to operate in L3 mode (i.e. without inner Ethernet
headers).

The full picture (all 30 patches) can be seen at:
https://github.com/jbenc/linux-vxlan/commits/master

Changelog:
v2: added patch 5/6, fixing the udp sum problem spotted by Paolo Abeni

Jiri Benc (6):
  vxlan: cleanup types
  vxlan: remove duplicated macros
  vxlan: restructure vxlan.h definitions
  vxlan: consolidate output route calculation
  vxlan: consolidate csum flag handling
  vxlan: consolidate vxlan_xmit_skb and vxlan6_xmit_skb

 drivers/net/vxlan.c | 231 ++++++++++++++++------------------------------------
 include/net/vxlan.h | 115 +++++++++++++++-----------
 2 files changed, 136 insertions(+), 210 deletions(-)

-- 
1.8.3.1
