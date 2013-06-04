From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 0/4] Mellanox driver fixes June 4th, 2013
Date: Tue,  4 Jun 2013 18:13:25 +0300
Message-ID: <1370358809-7484-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:46759 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755632Ab3FDPTG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Jun 2013 11:19:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This short series has one bugfix to the adaptive moderation code
and three SRIOV fixes. 

The patch from Jack Morgenstein follows the suggestion made over this thread
https://patchwork.kernel.org/patch/2569591/ by Ben H. to simply return -EPROBE_DEFER 
when a VF relalizes they can't do their probe now. Other two patches from me treat
issues in the VF and PF driver relating to handling VF MAC addresses.

Series done against net tree, commit 01cb71d2d "net_sched: restore "overhead xxx" handling"

Or.

This is what happens when Jack's patch is applied, so the PCI 
code relalized we ask for deferred probe and things work just OK.

mlx4_core: Mellanox ConnectX core driver v1.1 (Dec, 2011)
mlx4_core: Initializing 0000:06:00.0
mlx4_core 0000:06:00.0: Enabling SR-IOV with 2 VFs
pci 0000:06:00.1: [15b3:1002] type 00 class 0x028000
mlx4_core: Initializing 0000:06:00.1
mlx4_core 0000:06:00.1: enabling device (0000 -> 0002)
mlx4_core 0000:06:00.1: Detected virtual function - running in slave mode
mlx4_core 0000:06:00.1: Sending reset
mlx4_core 0000:06:00.1: slave is currently in the middle of FLR. Deferring probe.
pci 0000:06:00.1: Driver mlx4_core requests probe deferral


Jack Morgenstein (1):
  net/mlx4_core: Return -EPROBE_DEFER when a VF is probed before PF is
    sufficiently initialized

Or Gerlitz (2):
  net/mlx4_en: Handle unassigned VF MAC address correctly
  net/mlx4_core: Keep VF assigned MAC in the PF admin table

Sagi Grimberg (1):
  net/mlx4_en: Fix adaptive moderation cq update

 drivers/net/ethernet/mellanox/mlx4/cmd.c       |    2 --
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   17 +++++++++++++----
 drivers/net/ethernet/mellanox/mlx4/fw.c        |   10 +++++++---
 drivers/net/ethernet/mellanox/mlx4/main.c      |   20 ++++++--------------
 4 files changed, 26 insertions(+), 23 deletions(-)
