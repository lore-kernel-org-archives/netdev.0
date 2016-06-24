From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net-next.git) 0/3] stmmac: rework and enhance the PCS support
Date: Fri, 24 Jun 2016 15:16:23 +0200
Message-ID: <1466774186-2320-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <alexandre.torgue@st.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:10121 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751317AbcFXN1o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2016 09:27:44 -0400
Received: from pps.filterd (m0046037.ppops.net [127.0.0.1])
	by m0046037.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u5ODOXQY026380
	for <netdev@vger.kernel.org>; Fri, 24 Jun 2016 15:27:42 +0200
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
	by m0046037.ppops.net with ESMTP id 23mv2thmvy-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 24 Jun 2016 15:27:42 +0200
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 32AB33F
	for <netdev@vger.kernel.org>; Fri, 24 Jun 2016 13:27:41 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas21.st.com [10.75.90.44])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id E56161B88
	for <netdev@vger.kernel.org>; Fri, 24 Jun 2016 13:27:41 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 3.xx and 4.xx synopsys gmacs have a very similar
PCS embedded module and they share almost the same registers;
for example:
  AN_Control, AN_Status, AN_Advertisement, AN_Link_Partner_Ability,
  AN_Expansion, TBI_Extended_Status.

Just the RGMII/SMII Control/Status register differs.

So these patches aim to reorganize and enhance the PCS support;
to do that, some small inline functions have been provided and
also some rework to the PCS ISR part has been done.

In the end, the SGMII for MAC2MAC connection has been introduced.

All patches have been built on top of net-next git and, as for
the previous version, not fully tested.

Giuseppe Cavallaro (3):
  drivers: net: stmmac: reworking the PCS code.
  drivers: net: stmmac: rework core ISR to better manage PCS and PMT
  drivers: net: stmmac: add port selection programming

 Documentation/devicetree/bindings/net/stmmac.txt   |   3 +
 Documentation/networking/stmmac.txt                |   1 +
 drivers/net/ethernet/stmicro/stmmac/common.h       |  19 ++-
 drivers/net/ethernet/stmicro/stmmac/dwmac1000.h    |  86 +++++------
 .../net/ethernet/stmicro/stmmac/dwmac1000_core.c   | 147 ++++++++++---------
 drivers/net/ethernet/stmicro/stmmac/dwmac4.h       |  43 ++++--
 drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c  |  96 +++++++++----
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |   1 -
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |  60 +++++---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  50 +++++--
 drivers/net/ethernet/stmicro/stmmac/stmmac_pcs.h   | 159 +++++++++++++++++++++
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   2 +
 include/linux/stmmac.h                             |   1 +
 13 files changed, 474 insertions(+), 194 deletions(-)
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/stmmac_pcs.h

-- 
2.7.4
