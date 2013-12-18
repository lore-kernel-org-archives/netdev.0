From: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH net v2 0/8] Fixes for server entries and server filter entries for Chelsio T4/T5
Date: Wed, 18 Dec 2013 16:38:18 +0530
Message-ID: <1387364906-1967-1-git-send-email-hariprasad@chelsio.com>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	santosh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi All,

This patch series provides miscelleneous fixes for Chelsio T4/T5 adapters
related to server entries and server filter entries.

Also, fixes a bug in ULD (Upper Level Driver) like iw_cxgb4 where-in it
calculates wrong tuple values
on T5 adapter. So, a new API cxgb4_select_ntuple is exported so as to enable
Upper Lever Drivers like iw_cxgb4 to correctly calculate tuple values.

The patches series is created agains David Miller's 'net' tree.
And includes patches on cxgb4 and iw_cxgb4 driver.

Patch 8/8 (RDMA-cxgb4-Use-cxgb4_select_ntuple-to-correctly-calc.patch)
has a build dependency on Patch 5/8
(cxgb4-Add-API-to-correctly-calculate-tuple-fields.patch).

Also, Patch 6/8 (RDMA-cxgb4-Calculate-the-filter-server-TID-properly.patch) has
a functional
dependency on Patch 3/8 (cxgb4-Assign-filter-server-TIDs-properly.patch)

We would like to request this patch series to get merged via David Miller's
'net' tree.

We have included all the maintainers of respective drivers. Kindly review the
change and let us know in case of any review comments.


V2 changes:
 - Removed earlier patch which added sftids_in_use counter. However, the counter
   was actually not used anywhere in this patch series.
   Thanks to David Miller for spotting this.
   We have dropped this patch in V2 and will submit a more complete patch which
   uses sftids_in_use counter later on.
 - Fixed a 'checkpatch.pl --strict' warning on Patch 5/8
   (cxgb4-Add-API-to-correctly-calculate-tuple-fields.patch).
 - Removed some un-used #defines from Patch 5/8
   (cxgb4-Add-API-to-correctly-calculate-tuple-fields.patch).

Thanks,
Hariprasad Shenai

Kumar Sanghvi (8):
  cxgb4: Reserve stid 0 for T4/T5 adapters
  cxgb4: Include TCP as protocol when creating server filters
  cxgb4: Assign filter server TIDs properly
  cxgb4: Account for stid entries properly in case of IPv6
  cxgb4: Add API to correctly calculate tuple fields
  RDMA/cxgb4: Calculate the filter server TID properly
  RDMA/cxgb4: Server filters are supported only for IPv4
  RDMA/cxgb4: Use cxgb4_select_ntuple to correctly calculate ntuple
    fields

 drivers/infiniband/hw/cxgb4/cm.c                |  78 +++++-------------
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |  21 +++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |  59 +++++++++-----
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h  |   9 ++-
 drivers/net/ethernet/chelsio/cxgb4/l2t.c        |  35 ++++++++
 drivers/net/ethernet/chelsio/cxgb4/l2t.h        |   3 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      | 103 ++++++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h    |  73 +++++++++++++++++
 8 files changed, 301 insertions(+), 80 deletions(-)

-- 
1.8.0

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
