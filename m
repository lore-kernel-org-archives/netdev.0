From: ilant@mellanox.com
Subject: [PATCH net-next 0/7] IPSec offload improvements
Date: Tue,  1 Aug 2017 12:49:03 +0300
Message-ID: <20170801094910.14895-1-ilant@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ilan Tayari <ilant@mellanox.com>
To: Steffen Klassert <steffen.klassert@secunet.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr50051.outbound.protection.outlook.com ([40.107.5.51]:57152
        "EHLO EUR03-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751056AbdHAJtt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 1 Aug 2017 05:49:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ilan Tayari <ilant@mellanox.com>

Hi Steffen,

This patchset introduces several improvements to IPSec offload.
We would like to see these merged in 4.14.

Patches 1-4 add RX checksum offload support.
This gives a big performance boost.
These patches have been submitted before but were not merged.
Note that patches 1-2 changed slightly with a call to skb_pull_rcsum.

Patch 5 adds automatic loading of XFRM offload modules, but only
if crypto-offload is explicitly requested by user.
This avoid issues in the field where user forgets to load the
module manually and so crypto-offload does not happen.

Patch 6 fixes the leftover xfrm_offload in RX SKBs.
This solves some issues with forwarding.

Patch 7 allows IPSec GSO on local sockets, with or without
crypto-offload.
This also gives a large performance boost.

Thanks,
Ilan.

Ilan Tayari (4):
  esp4: Support RX checksum with crypto offload
  esp6: Support RX checksum with crypto offload
  xfrm: Auto-load xfrm offload modules
  xfrm: Clear RX SKB secpath xfrm_offload

Steffen Klassert (1):
  net: Allow IPsec GSO for local sockets

Yossi Kuperman (2):
  xfrm6: Fix CHECKSUM_COMPLETE after IPv6 header push
  esp6: Fix RX checksum after header pull

 include/net/xfrm.h      | 23 ++++++++++++++++++++++-
 net/core/sock.c         |  2 +-
 net/ipv4/esp4.c         | 14 +++++++++++---
 net/ipv4/esp4_offload.c |  5 ++++-
 net/ipv6/esp6.c         | 16 +++++++++++++---
 net/ipv6/esp6_offload.c |  5 ++++-
 net/ipv6/xfrm6_input.c  |  4 +++-
 net/xfrm/xfrm_device.c  |  2 +-
 net/xfrm/xfrm_input.c   |  2 ++
 net/xfrm/xfrm_state.c   | 16 ++++++++++++----
 net/xfrm/xfrm_user.c    |  2 +-
 11 files changed, 74 insertions(+), 17 deletions(-)

-- 
2.11.0
