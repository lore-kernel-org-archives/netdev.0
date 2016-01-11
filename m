From: Alexander Duyck <aduyck@mirantis.com>
Subject: [next PATCH 0/4] Add support for generic Tx checksums to igb, ixgbe,
 igbvf, ixgbevf
Date: Mon, 11 Jan 2016 09:53:50 -0800
Message-ID: <20160111173724.4101.35798.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, netdev@vger.kernel.org
To: intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:33208 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760803AbcAKRxv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 12:53:51 -0500
Received: by mail-pf0-f176.google.com with SMTP id e65so48195558pfe.0
        for <netdev@vger.kernel.org>; Mon, 11 Jan 2016 09:53:51 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It turns out we were doing far more than we needed to in the Tx checksum
functions for the drivers.  As a result it hid the fact that the hardware
is actually much more capable of handling generic offloads then previously
realized.

This patch series enables generic Tx checksum support for igb and ixgbe
based Intel server adapters.  In addition it adds a number of other items
such as:
  Inner checksum support for MPLS
  Encapsulated checksum support for igb, igbvf, and ixgbevf
  SCTP CRC offload support for VLAN tunnels, and VFs
  IPv6 extension header support for igb and igbvf

---

Alexander Duyck (4):
      ixgbe: Add support for generic Tx checksums
      ixgbevf: Add support for generic Tx checksums
      igb: Add support for generic Tx checksums
      igbvf: Add support for generic Tx checksums


 drivers/net/ethernet/intel/igb/igb_main.c         |  114 ++++++---------
 drivers/net/ethernet/intel/igbvf/netdev.c         |  142 ++++++++++--------
 drivers/net/ethernet/intel/igbvf/vf.h             |    1 
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |  163 ++++++++-------------
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  104 ++++++-------
 5 files changed, 231 insertions(+), 293 deletions(-)
