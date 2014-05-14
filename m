From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: [PATCH net v2 0/2] Altera TSE: Fix Sparse errors and misc issues
Date: Wed, 14 May 2014 14:38:35 -0500
Message-ID: <1400096317-4969-1-git-send-email-vbridgers2013@gmail.com>
Cc: vbridgers2013@gmail.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:43438 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751535AbaENTmy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 15:42:54 -0400
Received: by mail-pb0-f53.google.com with SMTP id md12so21607pbc.40
        for <netdev@vger.kernel.org>; Wed, 14 May 2014 12:42:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is version 2 of a patch series to correct sparse errors, cppcheck
warnings, and workaound a multicast filtering issue in the Altera TSE
Ethernet driver. Multicast filtering is not working as expected, so if
present in the hardware will not be used and promiscuous mode enabled
instead. This workaround will be replaced with a working solution when
completely debugged, integrated and tested. 

Version 2 is different from the first submission by breaking out the 
workaround as a seperate patch and addressing a few structure instance
declarations by making them const per review comments. 

If you find this patch acceptable, please consider this for inclusion into
the Altera TSE driver source code. 

Thank you

Vince


Vince Bridgers (2):
  Altera TSE: Fix sparse errors and warnings
  Altera TSE: Disable Multicast filtering to workaround problem

 drivers/net/ethernet/altera/Makefile             |    1 +
 drivers/net/ethernet/altera/altera_msgdma.c      |  110 ++++++-------
 drivers/net/ethernet/altera/altera_msgdmahw.h    |   13 +-
 drivers/net/ethernet/altera/altera_sgdma.c       |  181 +++++++++++-----------
 drivers/net/ethernet/altera/altera_sgdmahw.h     |   26 ++--
 drivers/net/ethernet/altera/altera_tse.h         |   47 ++++++
 drivers/net/ethernet/altera/altera_tse_ethtool.c |  108 ++++++++-----
 drivers/net/ethernet/altera/altera_tse_main.c    |  133 +++++++++-------
 drivers/net/ethernet/altera/altera_utils.c       |   20 +--
 drivers/net/ethernet/altera/altera_utils.h       |    8 +-
 10 files changed, 372 insertions(+), 275 deletions(-)

-- 
1.7.9.5
