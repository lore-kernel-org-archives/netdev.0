From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 0/2] Follow-ups for GUEoIPv6 patches
Date: Wed, 18 May 2016 10:44:40 -0700
Message-ID: <20160518173605.2608.42484.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: tom@herbertland.com, alexander.duyck@gmail.com,
	intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, kernel-team@fb.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:33635 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753207AbcERRon (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2016 13:44:43 -0400
Received: by mail-pa0-f52.google.com with SMTP id xk12so19994493pac.0
        for <netdev@vger.kernel.org>; Wed, 18 May 2016 10:44:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series is meant to be applied after:
[PATCH v7 net-next 00/16] ipv6: Enable GUEoIPv6 and more fixes for v6 tunneling

The first patch addresses an issue we already resolved in the GREv4 and is
now present in GREv6 with the introduction of FOU/GUE for IPv6 based GRE
tunnels.

The second patch goes through and enables IPv6 tunnel offloads for the Intel
NICs that already support the IPv4 based IP-in-IP tunnel offloads.  I have
only done a bit of touch testing but have seen ~20 Gb/s over an i40e
interface using a v4-in-v6 tunnel, and I have verified IPv6 GRE is still
passing traffic at around the same rate.  I plan to do further testing but
with these patches present it should enable a wider audience to be able to
test the new features introduced in Tom's patchset with hardware offloads.

---

Alexander Duyck (2):
      ip6_gre: Do not allow segmentation offloads GRE_CSUM is enabled with FOU/GUE
      intel: Add support for IPv6 IP-in-IP offload


 drivers/net/ethernet/intel/i40e/i40e_main.c       |    1 +
 drivers/net/ethernet/intel/i40e/i40e_txrx.c       |    1 +
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c     |    1 +
 drivers/net/ethernet/intel/i40evf/i40evf_main.c   |    1 +
 drivers/net/ethernet/intel/igb/igb_main.c         |    1 +
 drivers/net/ethernet/intel/igbvf/netdev.c         |    1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |    1 +
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |    1 +
 net/ipv6/ip6_gre.c                                |   12 ++++++++----
 9 files changed, 16 insertions(+), 4 deletions(-)
