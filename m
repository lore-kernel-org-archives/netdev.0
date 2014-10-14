From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net.git) 0/2] stmmac: review and fix the dwmac-sti glue-logic
Date: Tue, 14 Oct 2014 08:12:54 +0200
Message-ID: <1413267176-325-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <maxime.coquelin@st.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:36240 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754323AbaJNGRf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 02:17:35 -0400
Received: from pps.filterd (m0046670.ppops.net [127.0.0.1])
	by mx07-00178001.pphosted.com (8.14.5/8.14.5) with SMTP id s9E6FPTX011503
	for <netdev@vger.kernel.org>; Tue, 14 Oct 2014 08:17:34 +0200
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
	by mx07-00178001.pphosted.com with ESMTP id 1q0cy84gh1-1
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 14 Oct 2014 08:17:33 +0200
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 9F52E34
	for <netdev@vger.kernel.org>; Tue, 14 Oct 2014 06:17:09 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas21.st.com [10.75.90.44])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id DD9CE16A22
	for <netdev@vger.kernel.org>; Tue, 14 Oct 2014 06:17:31 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to review the whole glue logic adopted on STi SoCs that
was bugged.
In the old glue-logic there was a lot of confusion when setup the
retiming especially for STiD127 where, for example, the bits 6 and 7
(in the GMAC  control register) have a different meaning of what is
used for STiH4xx SoCs. So we cannot adopt the same glue for all these
SoCs.
Moreover, GiGa on STiD127 didn't work and, for all the SoCs, the RGMII
couldn't run when the speed was 10Mbps (because the clock was not properly
managed).
Note that the phy clock needs to be provided by the platform as well as
documented in the related binding file (updated as consequence).

The old code supported too many configurations never adopted and validated.
This made the code very complex to maintain and debug in case of issues.

The patch simplifies all the configurations as commented in the tables
inside the file and obviously it has been tested on all the boards
based on the SoCs mentioned.

With this patch, the dwmac-sti is also ready to support new configurations that
will be available on next SoC generations.

Giuseppe Cavallaro (2):
  stmmac: make the STi Layer compatible to STiH407
  stmmac: dwmac-sti: review the glue-logic for STi4xx and STiD127 SoCs

 .../devicetree/bindings/net/sti-dwmac.txt          |   91 +++---
 drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c    |  374 +++++++++++---------
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |    1 +
 3 files changed, 255 insertions(+), 211 deletions(-)

-- 
1.7.4.4
