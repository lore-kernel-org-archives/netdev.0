From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH v3 0/2] Correctly perform offloads when VNET_HDR is disabled
Date: Thu, 15 Aug 2013 13:02:51 -0400
Message-ID: <1376586173-4242-1-git-send-email-vyasevic@redhat.com>
Cc: mst@redhat.com, Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23287 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757471Ab3HORC6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Aug 2013 13:02:58 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r7FH2v03031154
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 15 Aug 2013 13:02:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is v3 of the patch.  It as been spit into 2 sperate patches as requested.
The asymetry of behavior has been removed.  Now it doesn't matter which
order the VNET_HDR and TUNSETOFFLOAD are performed.  The TUNSETOFFLOAD
ioctl always modifies the ioctl, and IFF_VNET_HDR can be turned on and off
independed of that.  What is different is that when computing features for
GSO, the value of IFF_VNET_HDR is also consulted and a different mask is used.
This way, the following sequence:
	clear IFF_VNET_HDR
	change TUNSETOFFLOAD
	set IFF_VNET_HDR
works and packet packets are delivered in correct format at all times.

Vlad Yasevich (2):
  macvtap: include all checksum offloads in TUN_OFFLOAD mask
  macvtap: Correctly set tap features when IFF_VNET_HDR is disabled.

 drivers/net/macvtap.c | 32 +++++++++++++++++++++++++-------
 1 file changed, 25 insertions(+), 7 deletions(-)

-- 
1.8.1.4
