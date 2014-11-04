From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net.git) 0/5] stmmac: review and fix lock and atomicity
Date: Tue, 4 Nov 2014 17:08:04 +0100
Message-ID: <1415117289-7733-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:33510 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752470AbaKDQT7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 11:19:59 -0500
Received: from pps.filterd (m0046668.ppops.net [127.0.0.1])
	by mx07-00178001.pphosted.com (8.14.5/8.14.5) with SMTP id sA4GFjFj010757
	for <netdev@vger.kernel.org>; Tue, 4 Nov 2014 17:19:58 +0100
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
	by mx07-00178001.pphosted.com with ESMTP id 1qeqj0309a-1
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 04 Nov 2014 17:19:58 +0100
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id EE54231
	for <netdev@vger.kernel.org>; Tue,  4 Nov 2014 16:19:28 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas21.st.com [10.75.90.44])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id CEE1815C6C
	for <netdev@vger.kernel.org>; Tue,  4 Nov 2014 16:19:52 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recently some issues have been reported for the driver for locking mechanism
and atomicity.

In fact, enabling DEBUG support to prove lock and to verify if sleeping while
atomic context some warnings occur at runtime. I have reproduced all on STi
platforms.

Concerning the tx path, I had provided a patch time ago but
I discarded the idea to completely remove locks; in this patch-set we can have
some useful fixes instead of.

This patch-set is to fix the atomicity in the PM stuff where I tried to collect
all the points and advice reported in the past weeks.
As final result, on my side no warnings and no problem when suspend/resume the
driver on STi boxes.

I also added a patch that fixes the locks for the EEE.
As pointed in some thread there was a design problem behind the eee
initialization and I have tried to fix that before.
As final result no issues when proving locks too.

Fabrice Gasnier (2):
  stmmac: fix stmmac_tx_avail should be called with TX locked
  stmmac: release tx lock, in case of dma mapping error.

Giuseppe Cavallaro (3):
  stmmac: fix lock in stmmac_set_rx_mode
  stmmac: fix concurrency in eee initialization.
  stmmac: fix atomicity in pm routines

 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   52 +++++++++++---------
 1 files changed, 29 insertions(+), 23 deletions(-)

-- 
1.7.4.4
