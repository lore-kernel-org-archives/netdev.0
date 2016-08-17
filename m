From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net v2 00/10] mlxsw: IPv4 UC router fixes
Date: Wed, 17 Aug 2016 16:39:27 +0200
Message-ID: <1471444777-3412-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	ilant@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36677 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751495AbcHQOjk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 10:39:40 -0400
Received: by mail-wm0-f65.google.com with SMTP id i138so24726056wmf.3
        for <netdev@vger.kernel.org>; Wed, 17 Aug 2016 07:39:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Ido says:
Patches 1-3 fix a long standing problem in the driver's init sequence,
which manifests itself quite often when routing daemons try to configure
an IP address on registered netdevs that don't yet have an associated
vPort.

Patches 4-9 add missing packet traps for the router to work properly and
also fix ordering issue following the recent changes to the driver's init
sequence.

The last patch isn't related to the router, but fixes a general problem
in which under certain conditions packets aren't trapped to CPU.

v1->v2:
- Change order of patch 7
- Add patch 6 following Ilan's comment
- Add patchset name and cover letter

Elad Raz (1):
  mlxsw: spectrum: Add missing packet traps

Ido Schimmel (8):
  mlxsw: spectrum: Don't return upon error in removal path
  mlxsw: spectrum: Remove redundant errors from the code
  mlxsw: spectrum: Create PVID vPort before registering netdevice
  mlxsw: spectrum: Mark port as active before registering it
  mlxsw: spectrum: Trap loop-backed packets
  mlxsw: spectrum: Add missing rollbacks in error path
  mlxsw: spectrum: Unmap 802.1Q FID before destroying it
  mlxsw: spectrum: Allow packets to be trapped from any PG

Jiri Pirko (1):
  mlxsw: reg: Fix missing op field fill-up

 drivers/net/ethernet/mellanox/mlxsw/reg.h          |  11 +++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 110 +++++++++++----------
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |   2 -
 .../net/ethernet/mellanox/mlxsw/spectrum_buffers.c |   2 +-
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   |  42 ++------
 drivers/net/ethernet/mellanox/mlxsw/trap.h         |   4 +
 6 files changed, 83 insertions(+), 88 deletions(-)

-- 
2.5.5
