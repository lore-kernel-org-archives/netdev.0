From: Alexander Duyck <aduyck@mirantis.com>
Subject: [RFC PATCH 0/5] Add GSO Partial support for devices with existing
 tunnel offloads
Date: Tue, 19 Apr 2016 15:05:50 -0400
Message-ID: <20160419185949.11723.50506.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: eugenia@mellanox.com, bruce.w.allan@intel.com, saeedm@mellanox.com,
	netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	ariel.elior@qlogic.com, mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:35447 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933162AbcDSTGA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 15:06:00 -0400
Received: by mail-pa0-f53.google.com with SMTP id fs9so9407487pac.2
        for <netdev@vger.kernel.org>; Tue, 19 Apr 2016 12:06:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set is meant to extend tunnel offload support for devices that
already support UDP or GRE tunnels to include support for those type of
tunnels with an outer checksum.  To do this I am enabling GSO partial
support for these types of tunnels which should work assuming the devices
supported by these drivers are either overwriting or ignoring checksum and
length fields contained in the IPv4/v6 and ignoring the checksum contained
in the outer L4 tunnel headers.

I don't have any of the hardware that uses the drivers that these patches
are applied do.  That was one of the motivations for submitting them as RFC.
My hope is that somebody out there with this hardware is willing to pull in
the patch and test it out in order to determine if this approach actually
works for these devices.

---

Alexander Duyck (5):
      mlx4: Add support for UDP tunnel segmentation with outer checksum offload
      mlx5: Add support for UDP tunnel segmentation with outer checksum offload
      bnx2x: Add support for segmentation of tunnels with outer checksums
      bnxt: Add support for segmentation of tunnels with outer checksums
      fm10k: Add support for UDP tunnel segmentation with outer checksum offload


 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c  |   13 ++++++++++---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c         |    9 +++++++--
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c   |   14 ++++++++++----
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c    |   17 +++++++++++++----
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |    7 ++++++-
 5 files changed, 46 insertions(+), 14 deletions(-)
