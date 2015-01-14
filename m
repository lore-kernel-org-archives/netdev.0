From: Prashant Sreedharan <prashant@broadcom.com>
Subject: [PATCH net 0/3 v2]tg3: synchronize_irq() should be called without taking locks
Date: Wed, 14 Jan 2015 11:33:12 -0800
Message-ID: <1421263992-23907-1-git-send-email-prashant@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <mchan@broadcom.com>,
	<peter@hurleysoftware.com>,
	Prashant Sreedharan <prashant@broadcom.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:2170 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751854AbbANTvO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 14:51:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v2: Added Reported-by, Tested-by fields and reference to the thread that
    reported the problem

This series addresses the problem reported by Peter Hurley in mail thread
https://lkml.org/lkml/2015/1/12/1082

Prashant Sreedharan (3):
  tg3_timer() should grab tp->lock before checking for tp->irq_sync
  tg3_reset_task() needs to use rtnl_lock to synchronize
  Release tp->lock before invoking synchronize_irq()

Our QA team also has validated this patch series. Thanks.

 drivers/net/ethernet/broadcom/tg3.c |   23 ++++++++++++++++++++---
 1 files changed, 20 insertions(+), 3 deletions(-)
