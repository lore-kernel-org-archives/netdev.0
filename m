From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 0/8] mlxsw: Adding layer 2 multicast
Date: Sun, 10 Jan 2016 21:06:21 +0100
Message-ID: <1452456389-2833-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, corbet@lwn.net,
	stephen@networkplumber.org, sfeldma@gmail.com,
	vivien.didelot@savoirfairelinux.com, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, nikolay@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:37364 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757370AbcAJUGd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2016 15:06:33 -0500
Received: by mail-wm0-f42.google.com with SMTP id f206so240618202wmf.0
        for <netdev@vger.kernel.org>; Sun, 10 Jan 2016 12:06:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Elad says:

This patchset add Linux hardware reflection for L2 multicast offload and add
MC support in mlxsw. For every bridge MDB entry insertion, either by IGMP
snooping or by static insertion/removal, a switchdev ops is been called.
In mlxsw, a new multicast group (MID) is been created and ports are assigned.
When all ports are removed, the multicast group is been deleted.

---
v1->v2:
- GFP_ATOMIC->GFP_KERNEL change in patch 7/8

Elad Raz (8):
  switchdev: Adding MDB entry offload
  bridge: Reflect MDB entries to hardware
  mlxsw: reg: Add definition of multicast record for SFD register
  mlxsw: reg: Adding SMID register
  mlxsw: Changing the maximum number of multicast group to a define
  mlxsw: Adding VID to FID translatation
  mlxsw: Adding layer 2 multicast support
  switchdev: Adding IGMP snooping documentation

 Documentation/networking/switchdev.txt             |   8 +-
 drivers/net/ethernet/mellanox/mlxsw/reg.h          | 100 +++++++++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |   3 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  15 ++
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 206 +++++++++++++++++++--
 include/net/switchdev.h                            |  11 ++
 net/bridge/br_mdb.c                                |  23 +++
 net/switchdev/switchdev.c                          |   2 +
 8 files changed, 349 insertions(+), 19 deletions(-)

-- 
1.9.3
