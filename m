From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [net PATCH 0/2] Don't use lco_csum to compute IPv4 checksum
Date: Mon, 28 Nov 2016 10:42:18 -0500
Message-ID: <20161128153927.15466.99193.stgit@ahduyck-blue-test.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, davem@davemloft.net,
        jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:18216 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933479AbcK1Vny (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Nov 2016 16:43:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When I implemented the GSO partial support in the Intel drivers I was using
lco_csum to compute the checksum that we needed to plug into the IPv4
checksum field in order to cancel out the data that was not a part of the
IPv4 header.  However this didn't take into account that the transport
offset might be pointing to the inner transport header.

Instead of using lco_csum I have just coded around it so that we can use
the outer IP header plus the IP header length to determine where we need to
start our checksum and then just call csum_partial ourselves.

This should fix the SIT issue reported on igb interfaces as well as simliar
issues that would pop up on other Intel NICs.

---

Alexander Duyck (2):
      igb/igbvf: Don't use lco_csum to compute IPv4 checksum
      ixgbe/ixgbevf: Don't use lco_csum to compute IPv4 checksum


 drivers/net/ethernet/intel/igb/igb_main.c         |    8 ++++++--
 drivers/net/ethernet/intel/igbvf/netdev.c         |    8 ++++++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |    8 ++++++--
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |    8 ++++++--
 4 files changed, 24 insertions(+), 8 deletions(-)
