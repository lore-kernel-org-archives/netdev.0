From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv5 net-next 0/2] Add support for IFLA_VF_MAC
Date: Thu, 11 Aug 2016 21:06:22 +0530
Message-ID: <1470929784-3882-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:54667 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751003AbcHKPap (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2016 11:30:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

We're struggling to implement the PCI SR-IOV management features for
administering Virtual Functions which represent networking devices using
the current Linux APIs. The problem is that these APIs incorporate all
sorts of assumptions which don't match chelsio networking cards.

For instance, the current APIs assume a 1-to-1 mapping of Network Ports,
Physical Functions and the SR-IOV Virtual Functions of those Physical
Functions. This is not the case with our cards where any Virtual Function
can be hooked up to any Port -- or any number of Ports the current Linux
APIs also assume only 1 Network Interface/Port can be accessed per Virtuali
Function.

Another issue is that these APIs assume that the Administrative Driver is
attached to the Physical Function Associated with a Virtual Function. This
is not the case with our card where all administration is performed by a
Driver which is not attached to any of the Physical Functions which have
SR-IOV PCI Capabilities.

Another consequence of these assumptions is the inability to utilize all
of the cards SR-IOV resources. For instance, our cards have SR-IOV
Capabilities on Physical Functions 0..3 and the administrative Driver
attaches to Physical Function 4. Each of the Physical Functions 0..3 can
support up to 16 Virtual Functions. With the current Linux APIs, a 2-Port
card would only be able to use the Virtual Functions on Physical
Function 0..1 and not allow the Virtual Functions on Physical
Functions 2..3 to be used since there are no Ports 2..3 on a 2-Port card.

Patch 1/2 adds support to create management interface for each PF to control
thier corresponding VF's. Patch 2/2 adds support for ndo_set_vf_mac.

This patch series has been created against net-next tree.

We have included all the maintainers of respective drivers. Kindly review
the change and let us know in case of any review comments.

V5: Fix warning reported by kbuild bot when CONFIG_PCI_IOV isn't defined.

V4: Handle memory allocation failure for adapter->mbox_log in init_one().
    Based on review comment by Yuval Mintz <Yuval.Mintz@qlogic.com>

V3: Based on review comment by Yuval Mintz, removed extra parameter pf
    added to IFLA_VF API's and created a net_device corresponding to
    each PF for controling their VF. Based on review comment by
    Yuval Mintz <Yuval.Mintz@qlogic.com>

V2: Fixed check for MAC address in Patch 2/2, based on review comment by
    Yuval Mintz <Yuval.Mintz@qlogic.com>

Hariprasad Shenai (2):
  cxgb4: Add control net_device for configuring PCIe VF
  cxgb4/cxgb4vf: Add set VF mac address support

 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |   3 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    | 143 ++++++++++++++++++---
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         |  41 ++++++
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |  24 ++++
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h |   3 +
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c     |  63 ++++++++-
 6 files changed, 253 insertions(+), 24 deletions(-)

-- 
2.3.4
