From: ilant@mellanox.com
Subject: [PATCH net-next 0/4] CHECKSUM_COMPLETE in IPSec
Date: Thu, 22 Jun 2017 15:31:55 +0300
Message-ID: <20170622123159.8348-1-ilant@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, Ilan Tayari <ilant@mellanox.com>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr10041.outbound.protection.outlook.com ([40.107.1.41]:36016
        "EHLO EUR02-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751164AbdFVMcS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 22 Jun 2017 08:32:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ilan Tayari <ilant@mellanox.com>

This patchset adds support for RX checksum offload in IPSec.

When crypto is performed in the host, the checksum needs to
be recalculated over all the payload.

However, when crypto is performed in the NIC, the NIC may
provide useful CHECKSUM_COMPLETE value, which then only needs
to be updated to account for decapsulation.

Note: This patchset is on top of the recent two IPv6 xfrm
patches which were submitted to 'net'.

Ilan Tayari (2):
  esp4: Support RX checksum with crypto offload
  esp6: Support RX checksum with crypto offload

Yossi Kuperman (2):
  xfrm6: Fix CHECKSUM_COMPLETE after IPv6 header push
  esp6: Fix RX checksum after header pull

 net/ipv4/esp4.c         | 13 +++++++++++--
 net/ipv4/esp4_offload.c |  4 +++-
 net/ipv6/esp6.c         | 15 +++++++++++++--
 net/ipv6/esp6_offload.c |  4 +++-
 net/ipv6/xfrm6_input.c  |  4 +++-
 5 files changed, 33 insertions(+), 7 deletions(-)

-- 
2.11.0
