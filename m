From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net v2 0/4] qlcnic: Bug fixes
Date: Mon, 24 Feb 2014 08:54:45 -0500
Message-ID: <1393250089-31104-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:56427 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752484AbaBXOaR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 09:30:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

Hi David,

This patch series includes following bug fixes,

* Fix for return value handling of function qlcnic_enable_msi_legacy().
* Fix for the usage of module parameters for interrupt mode.
  Driver should use flags while checking for driver's interrupt mode instead of
  module parameters.
* Revert commit 1414abea04 (qlcnic: Restrict VF from configuring any VLAN mode),
  in order to save some multicast filters.
* Fix a bug where driver was not re-setting sds ring count to 1 when
  it falls back from MSI-x mode to legacy interrupt mode.

Please apply to net.

Change in v2 -
Dropped patch "qlcnic: reset firmware API lock during driver load" for further rework.

Thanks,
Shahed

Rajesh Borundia (1):
  qlcnic: Fix number of rings when we fall back from msix to legacy.

Shahed Shaikh (2):
  qlcnic: Fix function return error check
  qlcnic: Fix usage of use_msi and use_msi_x module parameters

Sucheta Chakraborty (1):
  qlcnic: Allow any VLAN to be configured from VF.

 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c  | 1 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c     | 5 +++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c | 9 ---------
 3 files changed, 4 insertions(+), 11 deletions(-)

-- 
1.8.1.4
