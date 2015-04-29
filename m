From: Fan Du <fan.du@intel.com>
Subject: [PATCH v2 0/3] RSS fix for ixgbe/ixgbevf
Date: Wed, 29 Apr 2015 10:57:38 +0800
Message-ID: <1430276261-29821-1-git-send-email-fan.du@intel.com>
Cc: alexander.h.duyck@redhat.com, emil.s.tantilov@intel.com,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	Fan Du <fan.du@intel.com>
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:46898 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031333AbbD2DEI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Apr 2015 23:04:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset provides RSS hash value for upper stack by indicating
whether it's a L3 or L4 hash. Thus other component of network
stack could utilize this hash value provided by NIC without caculating
by themselves.

Test:
* Simple iperf test using ixgbe for 82599ES
* Build test only for ixgbevf
* make C=1 CF=-D__CHECK_ENDIAN__, no warnings introduced by this patchset

Changelog:
v2:
  - Add patch3 to make all hash value from RSS part.
v1:
  - Code style issue suggeted by Tantilov, Emil S.
  - Initial version

Fan Du (3):
  ixgbe: Specify rx hash type wrt rx desc RSS type
  ixgbevf: Set rx hash type for ingress packets
  ixgbe: Don't report flow director filter's status

 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c    |    2 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |   25 ++++++++++++++++---
 drivers/net/ethernet/intel/ixgbevf/defines.h      |   12 +++++++++
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   27 +++++++++++++++++++++
 4 files changed, 60 insertions(+), 6 deletions(-)
