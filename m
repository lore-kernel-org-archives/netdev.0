From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCHv2 (net-next.git) 00/18] stmmac: enhance driver performances and update the version
Date: Mon, 4 Jan 2016 14:06:45 +0100
Message-ID: <1451912823-5245-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <alexandre.torgue@st.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:59671 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751456AbcADMyB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 07:54:01 -0500
Received: from pps.filterd (m0046037.ppops.net [127.0.0.1])
	by m0046037.ppops.net (8.14.5/8.14.5) with SMTP id u04ChQ3H020143
	for <netdev@vger.kernel.org>; Mon, 4 Jan 2016 13:53:59 +0100
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
	by m0046037.ppops.net with ESMTP id 207dm7trku-1
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 13:53:59 +0100
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 1335234
	for <netdev@vger.kernel.org>; Mon,  4 Jan 2016 12:53:15 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas21.st.com [10.75.90.44])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 3243150F5
	for <netdev@vger.kernel.org>; Mon,  4 Jan 2016 12:53:58 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a subset of patches to rework the driver in order to improve its
performances and make it more robust under stress conditions.

All patches have been ported on STi mainstream kernel branch and
tested on ARM STiH4xx platforms and newer ones.

This series also updates the driver version and prepares it
to include further development to support new chips.

In detail, these patches are:

o to rework and improve the internal DMA bus settings

  Fine tuning is mandatory on some platforms for both
  performance and stability issues.

o to rework and optimize the descriptor management.

  This will help a lot on performance side and preparing
  the inclusion on the GMAC4.

o to add a set of optimizations for both xmit and rx functions.

  These will help a lot on performance side and making the driver
  more robust in case of low memory conditions and under some
  stress test, performed for example on IP-STB.

Below some throughput figures obtained on some boxes before and after
the patches.

                       nuttcp (mbps)       iperf (Mbps)
------------------------------------------------------------------
                      tcp     udp          tcp      udp
                   tx   rx   tx  rx      tx   rx   tx  rx
                    ------------------------------------------
   old             680   800 480  506    760  800   600  700
   new             830   880 540  630    840  880   700   800

==============================================================================

V2: as required, the rx_copybreak is now managed by using ethtool.

==============================================================================
Fabrice Gasnier (3):
  stmmac: merge get_rx_owner into rx_status routine.
  stmmac: optimize tx clean function
  stmmac: fix phy init when attached to a phy

Giuseppe Cavallaro (15):
  stmmac: share reset function between dwmac100 and dwmac1000
  stmmac: rework DMA bus setting and introduce new platform AXI
    structure
  stmmac: change descriptor layout
  stmmac: remove modulo in stmmac_xmit()
  stmmac: add length field to dma data
  stmmac: add last_segment field to dma data
  stmmac: add is_jumbo field to dma data
  stmmac: optimize tx desc management
  stmmac: set dirty index out of the loop
  stmmac: first frame prep at the end of xmit routine
  stmmac: perf, remove modulo in stmmac_rx()
  stmmac: do not poll phy handler when attach a switch
  stmmac: do not perform zero-copy for rx frames
  stmmac: tune rx copy via threshold.
  stmmac: update version to Oct_2015

 Documentation/devicetree/bindings/net/stmmac.txt   |   54 +++-
 drivers/net/ethernet/stmicro/stmmac/chain_mode.c   |   35 ++-
 drivers/net/ethernet/stmicro/stmmac/common.h       |   34 ++-
 drivers/net/ethernet/stmicro/stmmac/descs.h        |  330 +++++++++-----------
 drivers/net/ethernet/stmicro/stmmac/descs_com.h    |   77 ++---
 drivers/net/ethernet/stmicro/stmmac/dwmac100.h     |    1 -
 drivers/net/ethernet/stmicro/stmmac/dwmac1000.h    |    3 +-
 .../net/ethernet/stmicro/stmmac/dwmac1000_dma.c    |  111 ++++---
 drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c |   22 +--
 drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h    |   39 +++-
 drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c    |   21 ++
 drivers/net/ethernet/stmicro/stmmac/enh_desc.c     |  226 ++++++++------
 drivers/net/ethernet/stmicro/stmmac/norm_desc.c    |  150 +++++----
 drivers/net/ethernet/stmicro/stmmac/ring_mode.c    |   32 ++-
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |    7 +-
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |   41 +++-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  338 +++++++++++++------
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c   |    4 +-
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   42 +++-
 include/linux/stmmac.h                             |   17 +-
 20 files changed, 967 insertions(+), 617 deletions(-)

-- 
1.7.4.4
