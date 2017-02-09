From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/7] mlxsw: Identical routes handling
Date: Thu,  9 Feb 2017 10:28:37 +0100
Message-ID: <1486632524-5588-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35540 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752274AbdBIJ2r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 04:28:47 -0500
Received: by mail-wm0-f65.google.com with SMTP id u63so1906728wmu.2
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 01:28:46 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Ido says:

The kernel can store several FIB aliases that share the same prefix and
length. These aliases can differ in other parameters such as TOS and
metric, which are taken into account during lookup.

Offloading devices might not have the same flexibility, allowing only a
single route with the same prefix and length to be reflected. mlxsw is
one such device.

This patchset aims to correctly handle this situation in the mlxsw
driver. The first four patches introduce small changes in the IPv4 FIB
code, so that listeners of the FIB notification chain will be able to
correctly handle identical routes.

The last three patches build on top of previous work and introduce the
necessary changes in the mlxsw driver. The biggest change is the
introduction of a FIB node, where identical routes are chained, instead
of a primitive reference counting. This is explained in detail in the
fifth patch.

Ido Schimmel (7):
  ipv4: fib: Only flush FIB aliases belonging to currently flushed table
  ipv4: fib: Send deletion notification with actual FIB alias type
  ipv4: fib: Send notification before deleting FIB alias
  ipv4: fib: Add events for FIB replace and append
  mlxsw: spectrum_router: Correctly handle identical routes
  mlxsw: spectrum_router: Add support for route append
  mlxsw: spectrum_router: Add support for route replace

 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 644 +++++++++++++++------
 include/net/ip_fib.h                               |   3 +-
 net/ipv4/fib_trie.c                                |  42 +-
 3 files changed, 489 insertions(+), 200 deletions(-)

-- 
2.7.4
