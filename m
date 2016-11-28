From: Amir Vadai <amir@vadai.me>
Subject: [PATCH iproute2 V2 0/2] tc/cls_flower: Support for ip tunnel metadata set/unset/classify
Date: Mon, 28 Nov 2016 14:51:34 +0200
Message-ID: <20161128125136.3393-1-amir@vadai.me>
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Jiri Benc <jbenc@redhat.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Roi Dayan <roid@mellanox.com>, Amir Vadai <amir@vadai.me>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34480 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754388AbcK1MwG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 07:52:06 -0500
Received: by mail-wm0-f65.google.com with SMTP id g23so18850841wme.1
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 04:52:05 -0800 (PST)
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

Changes from V1:
- Updated Patch 2/2 ("tc/act_tunnel: Introduce ip tunnel action") commit log
	and the man page tc-tunnel_key to reflect the fact that 'unset' operation is
	no mandatory.
	And describe when it might be needed.
- Rename the 'release' operation to 'unset'

Amir Vadai (2):
  tc/cls_flower: Classify packet in ip tunnels
  tc/act_tunnel: Introduce ip tunnel action

 include/linux/tc_act/tc_tunnel_key.h |  42 ++++++
 man/man8/tc-flower.8                 |  17 ++-
 man/man8/tc-tunnel_key.8             | 113 +++++++++++++++
 tc/Makefile                          |   1 +
 tc/f_flower.c                        |  85 +++++++++++-
 tc/m_tunnel_key.c                    | 259 +++++++++++++++++++++++++++++++++++
 6 files changed, 513 insertions(+), 4 deletions(-)
 create mode 100644 include/linux/tc_act/tc_tunnel_key.h
 create mode 100644 man/man8/tc-tunnel_key.8
 create mode 100644 tc/m_tunnel_key.c

-- 
2.10.2
