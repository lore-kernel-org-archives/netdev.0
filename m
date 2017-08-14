From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/2] mlxsw: Add support for nexthop group consolidation for IPv6
Date: Mon, 14 Aug 2017 21:09:18 +0200
Message-ID: <20170814190920.9576-1-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:36935 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751515AbdHNTJX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2017 15:09:23 -0400
Received: by mail-wr0-f195.google.com with SMTP id f38so7575959wrf.4
        for <netdev@vger.kernel.org>; Mon, 14 Aug 2017 12:09:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Arkadi says:

Due to limited ASIC resources the maximum number of routes is limited by
the nexthop resource. In order to improve the routing scale nexthop
consolidation should be performed.

In case of IPv4, the kernel does the consolidation of nexthops in the form
of the fib_info struct. In that case, the driver uses the fib_info's
address as a key for the internal nexthop group representative struct
lookup. In case of IPv6, the kernel doesn't do consolidation, thus the
driver should implement it by itself.

The hash value is calculated based on the nexthop set, by performing
bitwise xor on the ifindexs of the nexthops, in a similar way to IPV4's
kernel implementation. In case of collision a full match is performed
between the sets which include address and ifindex comparison.

In order to use the same hash table in both cases (IPv4/6), the rhashtable
is changed to operate on variable length key.

Arkadi Sharshevsky (2):
  mlxsw: spectrum_router: Prepare nexthop group's hash table for IPv6
  mlxsw: spectrum_router: Add support for nexthop group consolidation
    for IPv6

 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 209 ++++++++++++++++++---
 1 file changed, 188 insertions(+), 21 deletions(-)

-- 
2.9.3
