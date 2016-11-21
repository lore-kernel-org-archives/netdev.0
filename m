From: Amir Vadai <amir@vadai.me>
Subject: [PATCH iproute2 0/2] tc/cls_flower: Support for ip tunnel metadata set/release/classify
Date: Mon, 21 Nov 2016 12:20:54 +0200
Message-ID: <20161121102056.13468-1-amir@vadai.me>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Roi Dayan <roid@mellanox.com>, Amir Vadai <amir@vadai.me>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33241 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751264AbcKUKVY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2016 05:21:24 -0500
Received: by mail-wm0-f67.google.com with SMTP id u144so472892wmu.0
        for <netdev@vger.kernel.org>; Mon, 21 Nov 2016 02:21:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This short series adds support for matching and setting metadata for ip tunnel
shared device using the TC system, introduced in kernel 4.9 [1].

Applied and tested on top of commit f3f339e9590a ("cleanup debris from revert")

Example usage:

$ tc filter add dev vxlan0 protocol ip parent ffff: \
    flower \
      enc_src_ip 11.11.0.2 \
      enc_dst_ip 11.11.0.1 \
      enc_key_id 11 \
      dst_ip 11.11.11.1 \
    action tunnel_key release \
    action mirred egress redirect dev vnet0

$ tc filter add dev net0 protocol ip parent ffff: \
    flower \
      ip_proto 1 \
      dst_ip 11.11.11.2 \
    action tunnel_key set \
      src_ip 11.11.0.1 \
      dst_ip 11.11.0.2 \
      id 11 \
    action mirred egress redirect dev vxlan0

[1] - d1ba24feb466 ("Merge branch 'act_tunnel_key'")

Thanks,
Amir

Amir Vadai (2):
  tc/cls_flower: Classify packet in ip tunnels
  tc/act_tunnel: Introduce ip tunnel action

 include/linux/tc_act/tc_tunnel_key.h |  42 ++++++
 man/man8/tc-flower.8                 |  17 ++-
 man/man8/tc-tunnel_key.8             | 105 ++++++++++++++
 tc/Makefile                          |   1 +
 tc/f_flower.c                        |  85 +++++++++++-
 tc/m_tunnel_key.c                    | 259 +++++++++++++++++++++++++++++++++++
 6 files changed, 505 insertions(+), 4 deletions(-)
 create mode 100644 include/linux/tc_act/tc_tunnel_key.h
 create mode 100644 man/man8/tc-tunnel_key.8
 create mode 100644 tc/m_tunnel_key.c

-- 
2.10.2
