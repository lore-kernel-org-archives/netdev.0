From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net 0/2] fix napi return value
Date: Tue, 20 Jan 2015 18:46:14 +0530
Message-ID: <1421759776-376-1-git-send-email-_govind@gmx.com>
Cc: ssujith@cisco.com, benve@cisco.com,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org, ariel.elior@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.200]:55612 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753683AbbATNRJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jan 2015 08:17:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since d75b1ade567ffab ("net: less interrupt masking in NAPI") we should return
budget for napi repoll.

In enic, we return 0 when busy_poll is happening. Fix this by returning budget.

Looks like bnx2x needs this fix as well. On bnx2x I performed compile
test only. I do not have hardware. 

Govindarajulu Varadarajan (2):
  enic: fix rx napi poll return value
  bnx2x: fix napi poll return value for repoll

 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 4 ++--
 drivers/net/ethernet/cisco/enic/enic_main.c     | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

-- 
2.2.2
