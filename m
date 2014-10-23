From: Anish Bhatt <anish@chelsio.com>
Subject: [PATCH net 0/2] cxgb4 : DCBx fixes for apps/host lldp agents
Date: Thu, 23 Oct 2014 14:37:29 -0700
Message-ID: <1414100251-15702-1-git-send-email-anish@chelsio.com>
Cc: davem@davemloft.net, hariprasad@chelsio.com, leedom@chelsio.com,
	Anish Bhatt <anish@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:33431
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751791AbaJWVh6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2014 17:37:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset  contains some minor fixes for cxgb4 DCBx code. Chiefly, cxgb4 
was not cleaning up any apps added to kernel app table when link was lost.
Disabling DCBx in firmware would automatically set DCBx state to host-managed
and enabled, we now wait for an explicit enable call from an lldp agent instead

First patch was originally sent to net-next, but considering it applies to
correcting behaviour of code already in net, I think it qualifies as a bug fix.
-Anish

Anish Bhatt (2):
  cxgb4 : Improve handling of DCB negotiation or loss thereof
  cxgb4 : Handle dcb enable correctly

 drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c  | 55 +++++++++++++++++++++++--
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |  6 ++-
 2 files changed, 56 insertions(+), 5 deletions(-)

-- 
2.1.2
