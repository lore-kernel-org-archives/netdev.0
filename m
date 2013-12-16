From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net 0/9] Fixes for server entries and server filter entries for Chelsio T4/T5
Date: Mon, 16 Dec 2013 17:42:09 +0530
Message-ID: <1387195938-3531-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com, dm@chelsio.com,
	swise@opengridcomputing.com, leedom@chelsio.com,
	santosh@chelsio.com, kumaras@chelsio.com, hariprasad@chelsio.com,
	nirranjan@chelsio.com
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:7255 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753900Ab3LPMTu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 07:19:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

This patch series provides miscelleneous fixes for Chelsio T4/T5 adapters
related to server entries and server filter entries.

Also, fixes a bug in ULD (Upper Level Driver) like iw_cxgb4 where-in it
calculates wrong tuple values
on T5 adapter. So, a new API cxgb4_select_ntuple is exported so as to enable
Upper Lever Drivers like iw_cxgb4 to correctly calculate tuple values.

The patches series is created agains David Miller's 'net' tree.
And includes patches on cxgb4 and iw_cxgb4 driver.

Patch 9/9 (RDMA-cxgb4-Use-cxgb4_select_ntuple-to-correctly-calc.patch)
has a build dependency on Patch 6/9
(cxgb4-Add-API-to-correctly-calculate-tuple-fields.patch).

Also, Patch 7/9 (RDMA-cxgb4-Calculate-the-filter-server-TID-properly.patch) has
a functional
dependency on Patch 5/9 (cxgb4-Assign-filter-server-TIDs-properly.patch)

We would like to request this patch series to get merged via David Miller's
'net' tree.

We have included all the maintainers of respective drivers. Kindly review the
change and let us know in case of any review comments.

Thanks

Kumar Sanghvi (9):
  cxgb4: Properly account for server filter entries
  cxgb4: Reserve stid 0 for T4/T5 adapters
  cxgb4: Include TCP as protocol when creating server filters
  cxgb4: Account for stid entries properly in case of IPv6
  cxgb4: Assign filter server TIDs properly
  cxgb4: Add API to correctly calculate tuple fields
  RDMA/cxgb4: Calculate the filter server TID properly
  RDMA/cxgb4: Server filters are supported only for IPv4
  RDMA/cxgb4: Use cxgb4_select_ntuple to correctly calculate ntuple
    fields

 drivers/infiniband/hw/cxgb4/cm.c                |  78 +++++-------------
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |  21 +++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |  65 ++++++++++-----
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h  |  10 ++-
 drivers/net/ethernet/chelsio/cxgb4/l2t.c        |  35 ++++++++
 drivers/net/ethernet/chelsio/cxgb4/l2t.h        |   3 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      | 103 ++++++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h    |  80 ++++++++++++++++++
 8 files changed, 315 insertions(+), 80 deletions(-)

-- 
1.8.0
