From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next 0/3] validate variable length ll headers
Date: Wed,  9 Mar 2016 21:58:31 -0500
Message-ID: <1457578714-36125-1-git-send-email-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f67.google.com ([209.85.192.67]:35746 "EHLO
	mail-qg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752262AbcCJC6i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 21:58:38 -0500
Received: by mail-qg0-f67.google.com with SMTP id p68so4402681qge.2
        for <netdev@vger.kernel.org>; Wed, 09 Mar 2016 18:58:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Allow device-specific validation of link layer headers. Existing
checks drop all packets shorter than hard_header_len. For variable
length protocols, such packets can be valid.

patch 1 adds header_ops.validate and dev_validate_header
patch 2 implements the protocol specific callback for AX25
patch 3 replaces ll_header_truncated with dev_validate_header

Willem de Bruijn (3):
  net: validate variable length ll headers
  ax25: add link layer header validation function
  packet: validate variable length ll headers

 include/linux/netdevice.h | 22 ++++++++++++++++++++--
 net/ax25/ax25_ip.c        | 15 +++++++++++++++
 net/packet/af_packet.c    | 43 ++++++++++++++++++-------------------------
 3 files changed, 53 insertions(+), 27 deletions(-)

-- 
2.7.0.rc3.207.g0ac5344
