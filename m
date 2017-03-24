From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/10][pull request] 40GbE Intel Wired LAN Driver Updates 2017-03-23
Date: Thu, 23 Mar 2017 22:14:22 -0700
Message-ID: <20170324051432.79216-1-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:53066 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751205AbdCXFOg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 24 Mar 2017 01:14:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40e.txt documentation.

Jake provides all the changes in the series which are centered around
ntuple filter fixes and additional support.  Fixed the current
implementation of .set_rxnfc, where we were not reading the mask field
for filter entries which was resulting in filters not behaving as
expected and not working correctly.  When cleaning up after disabling
flow director support, ensure that the default input set is correctly
reprogrammed.  Since the hardware only supports a single input set for
all flows of that type, the driver shall only allow the input set to
change if there are no other configured filters for that flow type, so
add support to detect when we can update the input set for each flow
type.  Align the driver to other drivers to partition the ring_cookie
value into 8bits of VF index, along with 32bits of queue number instead
of using the user-def field.  Added support to parse the user-def field
into a data structure format to allow future extensions of the user-def
filed by keeping all the code that read/writes the field into a single
location.  Added support for flexible payloads passed via ethtool
user-def field.  We support a single flexible word (2byte) value per
protocol type, and we handle the FLX_PIT register using a list of
flexible entries so that each flow type may be configured separately.
Enabled flow director filters for SCTPv4 packets using the ethtool
ntuple interface to enable filters.  Updated the documentation on the
i40e driver to include the newly added support to ntuple filters.
Reduced complexity of a if-continue-else-break section of code by
taking advantage of using hlist_for_each_entry_continue() instead.

The following are changes since commit add641e7dee31b36aee83412c29e39dd1f5e0c9c:
  sched: act_csum: don't mangle TCP and UDP GSO packets
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 40GbE

Jacob Keller (10):
  i40e: correctly honor the mask fields for ETHTOOL_SRXCLSRLINS
  i40e: check current configured input set when adding ntuple filters
  i40e: restore default input set for each flow type
  i40e: allow changing input set for ntuple filters
  i40e: partition the ring_cookie to get VF index
  i40e: add parsing of flexible filter fields from userdef
  i40e: implement support for flexible word payload
  i40e: add support for SCTPv4 FDir filters
  i40e: document drivers use of ntuple filters
  i40e: make use of hlist_for_each_entry_continue

 Documentation/networking/i40e.txt              |  72 ++
 drivers/net/ethernet/intel/i40e/i40e.h         | 130 ++++
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 977 ++++++++++++++++++++++++-
 drivers/net/ethernet/intel/i40e/i40e_main.c    |  52 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c    | 107 +++
 5 files changed, 1294 insertions(+), 44 deletions(-)

-- 
2.12.0
