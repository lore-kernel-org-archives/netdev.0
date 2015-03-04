From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 0/3] be2net: patch set
Date: Wed, 4 Mar 2015 00:44:31 -0500
Message-ID: <1425447874-5406-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.emulex.com ([138.239.224.99]:7417 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753861AbbCDFlZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 00:41:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave, the following patch set includes three feature additions relating
to SR-IOV to be2net. 

Patch 1 avoid creating a non-RSS default RXQ when FW allows it.
This prevents wasting one RXQ for each VF.

Patch 2 adds support for evenly distributing all queue & filter resources
across VFs. The FW informs the driver as to which resources are distributable.

Patch 3 implements the sriov_configure PCI method to allow runtime
enablement of VFs via sysfs.

Pls consider applying this patch-set to the net-next tree. Thanks!

Vasundhara Volam (3):
  be2net: avoid creating the non-RSS default RXQ if FW allows to
  be2net: re-distribute SRIOV resources allowed by FW
  be2net: implement .sriov_configure() PCI callback

 drivers/net/ethernet/emulex/benet/be.h         |   9 +-
 drivers/net/ethernet/emulex/benet/be_cmds.c    | 114 +++++++----
 drivers/net/ethernet/emulex/benet/be_cmds.h    |  23 ++-
 drivers/net/ethernet/emulex/benet/be_ethtool.c |   2 +-
 drivers/net/ethernet/emulex/benet/be_main.c    | 260 +++++++++++++++++--------
 5 files changed, 285 insertions(+), 123 deletions(-)

-- 
2.2.0
