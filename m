From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [net-next.git 0/3 (v2)] stmmac: review driver Koptions
Date: Tue, 4 Nov 2014 15:49:31 +0100
Message-ID: <1415112574-21321-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:60193 "EHLO
	mx08-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754366AbaKDPB3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 10:01:29 -0500
Received: from pps.filterd (m0046660.ppops.net [127.0.0.1])
	by mx08-00178001.pphosted.com (8.14.5/8.14.5) with SMTP id sA4ExCbD006681
	for <netdev@vger.kernel.org>; Tue, 4 Nov 2014 16:01:26 +0100
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
	by mx08-00178001.pphosted.com with ESMTP id 1qeymsre5n-1
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 04 Nov 2014 16:01:26 +0100
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id A07F231
	for <netdev@vger.kernel.org>; Tue,  4 Nov 2014 15:00:51 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas21.st.com [10.75.90.44])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id CFC53B4D93
	for <netdev@vger.kernel.org>; Tue,  4 Nov 2014 15:01:17 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recently many Koption options have been added to have new glue logic on several
platforms.

The main goal behind this work is to guarantee that the driver built 
fine on all the branches where it is present independently of which
glue logic is selected.

IMHO, it is better to remove all the not necessary Koption(s) that can hide 
build problems when something changes in the driver and especially when 
the DT compatibility allows us to manage all the platform data.

I compiled the driver w/o any issue on net-next Git for:

  x86, arm and sh4.

In case of there are build problems on some repos now it will be
easy to catch them and cherry-pick patches from mainstream.

For sure, do not hesitate to contact me in case of issue.

Also this set removes STMMAC_DEBUG_FS and BUS_MODE_DA. The latter is useless
and the former can be replaced by DEBUG_FS (always to make safe the build).

V2: patch-set re-based on top of the latest updates for net-next

Giuseppe Cavallaro (3):
  stmmac: remove specific SoC Koption from platform.
  stmmac: remove STMMAC_DEBUG_FS
  stmmac: remove BUS_MODE_DA

 drivers/net/ethernet/stmicro/stmmac/Kconfig        |   68 +------------------
 drivers/net/ethernet/stmicro/stmmac/Makefile       |    8 +--
 .../net/ethernet/stmicro/stmmac/dwmac1000_dma.c    |    4 -
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |    9 +--
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |   14 ++--
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   10 +---
 6 files changed, 16 insertions(+), 97 deletions(-)

-- 
1.7.4.4
