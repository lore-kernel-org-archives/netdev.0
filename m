From: Luiz Augusto von Dentz <luiz.dentz@gmail.com>
Subject: [PATCH v5 0/6] Bluetooth: 6LoWPAN: Fix lladdr length
Date: Fri, 24 Feb 2017 14:14:34 +0200
Message-ID: <20170224121440.32269-1-luiz.dentz@gmail.com>
Cc: patrik.flykt@linux.intel.com, jukka.rissanen@linux.intel.com,
        stefan@osg.samsung.com, aar@pengutronix.de,
        linux-wpan@vger.kernel.org, netdev@vger.kernel.org
To: linux-bluetooth@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f54.google.com ([209.85.215.54]:33842 "EHLO
        mail-lf0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751214AbdBXMPB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2017 07:15:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Luiz Augusto von Dentz <luiz.von.dentz@intel.com>

These patches fixes lladdr length to be 6 bytes long and not 8 which cause
neighbor advertisement to be sent with wrong lladdr including FF:FE filler
bytes for eui64.

Note: This does not fix some of the existing crashes which I hope to address
in a different set.

v2: Make all code paths that generate a link-local from lladdr use the same
code.
v3: Use lowpan_iphc_uncompress_eui48_lladdr to generate the remote ip address.
v4: Handle comments from Stefan Schmidt.
v5: Add patch to fix IID format for Bluetooth

Alexander Aring (2):
  6lowpan: iphc: override l2 packet information
  ipv6: addrconf: fix 48 bit 6lowpan autoconfiguration

Luiz Augusto von Dentz (2):
  6lowpan: Use netdev addr_len to determine lladdr len
  6lowpan: Fix IID format for Bluetooth

Patrik Flykt (2):
  bluetooth: Set 6 byte device addresses
  6lowpan: Set MAC address length according to LOWPAN_LLTYPE

 include/net/6lowpan.h   |  15 ++++++
 net/6lowpan/core.c      |  11 +++-
 net/6lowpan/iphc.c      |  57 +++++++++++++++++----
 net/bluetooth/6lowpan.c | 130 ++++++++----------------------------------------
 net/ipv6/addrconf.c     |  17 +++++--
 5 files changed, 104 insertions(+), 126 deletions(-)

-- 
2.9.3
