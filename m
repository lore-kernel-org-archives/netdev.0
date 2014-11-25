From: alexander.duyck@gmail.com
Subject: [net PATCH 0/2] Fix outer UDP checksums for IPv6 VXLAN tunnels
Date: Mon, 24 Nov 2014 20:08:25 -0800
Message-ID: <20141125035808.13612.52556.stgit@ahduyck-workstation.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:62350 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751874AbaKYEI1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2014 23:08:27 -0500
Received: by mail-pd0-f177.google.com with SMTP id ft15so10987972pdb.8
        for <netdev@vger.kernel.org>; Mon, 24 Nov 2014 20:08:26 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In testing against an older kernel I found a couple issues in the IPv6
VXLAN tunnel checksum logic for the outer UDP checksum.

First the default transitioned from using an outer checksum to not using
one.  Second, sometime after that the checksum inputs were changed
resulting the checksum not being correct if it were computed.

These two issues prevented a ping from the newer kernel to the older one.
With these two changes applied I verified I was able to send traffic over
the VXLAN tunnel to a link partner on an older kernel.

The boolean flip fix can be submitted for 3.17 stable as well since the
patch that introduced the issue was included in that kernel.

---

Alexander Duyck (2):
      ip6_udp_tunnel: Fix checksum calculation
      vxlan: Fix boolean flip in VXLAN_F_UDP_ZERO_CSUM6_[TX|RX]


 drivers/net/vxlan.c       |    4 ++--
 net/ipv6/ip6_udp_tunnel.c |    4 +---
 2 files changed, 3 insertions(+), 5 deletions(-)

-- 
