From: Sathya Perla <sathya.perla@avagotech.com>
Subject: [net-next PATCH 00/10] be2net: patch set
Date: Thu, 24 Dec 2015 04:26:22 -0500
Message-ID: <1450949192-4574-1-git-send-email-sathya.perla@avagotech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:64903 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754565AbbLXJn6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Dec 2015 04:43:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,
The following patch set contains some feature additions, code re-organization
and cleanup and a few non-critical fixes. Pls consider applying this to
the net-next tree. Thanks.

Patch 1 fixes VF link state transition from disabled to auto that did
not work due to an issue in the FW. This issue could not be fixed in FW due
to some backward compatibility issues it causes with released drivers.
The issue has been fixed by introducing a new version (v2) of the cmd
from 10.6 FW onwards. This patch adds support for v2 version of this cmd.

Patch 2 reports a EOPNOTSUPP status to ethtool when the user tries to
configure BE3/SRIOV in VEPA mode as it is not supported by the chip.

Patch 3 cleansup FW flash image related constant definitions. Many of these
definitions (such as section offset values) were defined in decimal format
rather than hexa-decimal. This makes this part of the code un-readable.
Also some defines related to BE2 are labeld "g2" and defines related to BE3
are labeled "g3".  This patch cleans up all of this to make this code more
readable.

Patch 4 moves the FW cmd code to be_cmds.c. All code relating to FW cmds
has been in be_cmds.[ch], excepting FW flash cmd related code.
This patch moves these routines from be_main.c to be_cmds.c.

Patch 5 adds a log message to report digital signature errors while
flashing a FW image. From FW version 11.0 onwards, the FW supports a new
"secure mode" feature (based on a jumper setting on the adapter.) In this
mode, the FW image when flashed is authenticated with a digital signature.

Patch 6 removes a line of code that has no effect.

Patch 7 removes some unused variables.

Patch 8 fixes port resource descriptor query via the GET_PROFILE FW cmd.
An earlier commit passed a specific pf_num while issuing this cmd as FW
returns descriptors for all functions when pf_num is zero. But, when pf_num
is set to a non-zero value, FW does not return the port resource descriptor.
This patch fixes this by setting pf_num to 0 while issuing the query cmd
and adds code to pick the correct NIC resource descriptor from the list of
descriptors returned by FW.

Patch 9 adds support for ethtool get-dump feature. In the past when this
option was not yet available, this feature was supported via the
--register-dump option as a workaround.  This patch removes support for
FW-dump via --register-dump option as it is now available via --get-dump
option. Even though the "ethtool --register-dump" cmd which used to work
earlier, will now fail with ENOTSUPP error, we feel it is not an issue as
this is used only for diagnostics purpose.

Patch 10 bumps up the driver version.

Sathya Perla (1):
  be2net: remove a line of code that has no effect

Suresh Reddy (7):
  be2net: fix VF link state transition from disabled to auto
  be2net: avoid configuring VEPA mode on BE3
  be2net: cleanup FW flash image related macro defines
  be2net: move FW flash cmd code to be_cmds.c
  be2net: log digital signature errors while flashing FW image
  be2net: fix port-res desc query of GET_PROFILE_CONFIG FW cmd
  be2net: bump up the driver version to 11.0.0.0

Venkat Duvvuru (2):
  be2net: remove unused error variables
  be2net: support ethtool get-dump option

 drivers/net/ethernet/emulex/benet/be.h         |  13 +-
 drivers/net/ethernet/emulex/benet/be_cmds.c    | 755 ++++++++++++++++++++++---
 drivers/net/ethernet/emulex/benet/be_cmds.h    | 178 +++---
 drivers/net/ethernet/emulex/benet/be_ethtool.c |  82 ++-
 drivers/net/ethernet/emulex/benet/be_main.c    | 588 +------------------
 5 files changed, 840 insertions(+), 776 deletions(-)

-- 
2.4.1
