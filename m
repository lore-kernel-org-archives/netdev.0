From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net 0/3] validate variable length ll headers
Date: Fri,  4 Mar 2016 15:44:14 -0500
Message-ID: <1457124257-31486-1-git-send-email-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, alan@linux.intel.com, hessu@hes.iki.fi,
	martin.blumenstingl@googlemail.com, linux-hams@vger.kernel.org,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f66.google.com ([209.85.192.66]:33578 "EHLO
	mail-qg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758341AbcCDUoV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 15:44:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Allow device-specific validation of link layer headers. Existing
checks drop all packets shorter than hard_header_len. For variable
length protocols, such packets can be valid.

patch 1 adds header_ops.validate and dev_validate_header
patch 2 replaces ll_header_truncated with dev_validate_header
patch 3 implements the protocol specific callback for AX25

Tested with a temporary eth_header_validate function. The AX25
code is compile-tested only at this point.

Willem de Bruijn (3):
  net: validate variable length ll headers
  packet: validate variable length ll headers
  ax25: add link layer header validation function

 include/linux/netdevice.h | 22 ++++++++++++++++++++--
 net/ax25/ax25_ip.c        | 15 +++++++++++++++
 net/packet/af_packet.c    | 38 +++++++++++++++++---------------------
 3 files changed, 52 insertions(+), 23 deletions(-)

-- 
2.7.0.rc3.207.g0ac5344
