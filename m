From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH 0/5] net: mvpp2: fixes and cleanups
Date: Thu,  8 Jun 2017 17:27:22 +0200
Message-ID: <1496935647-29670-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: Marcin Wojtas <mw@semihalf.com>,
        Stefan Chulski <stefanc@marvell.com>,
        Nadav Haklai <nadavh@marvell.com>,
        Hanna Hawa <hannah@marvell.com>,
        Yehuda Yitschak <yehuday@marvell.com>,
        Antoine Tenart <antoine.tenart@free-electrons.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Markus Elfring <elfring@users.sourceforge.net>,
        Marc Zyngier <marc.zyngier@arm.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:34598 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751782AbdFHP2B (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 11:28:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Here is a small set of fixes/improvements for the mvpp2 driver.

The first two patches are fixes: they fix bogus usage of
smp_processor_id() in a migration-enabled context. Indeed currently
the driver outputs some fat warnings in CONFIG_DEBUG_PREEMPT-enabled
kernels. Therefore, some fixes should be pushed to stable.

The last three patches are cleanups and not needed for stable, but
they stack on top of the fixes.

Thanks,

Thomas

Thomas Petazzoni (5):
  net: mvpp2: remove mvpp2_bm_cookie_{build,pool_get}
  net: mvpp2: use {get,put}_cpu() instead of smp_processor_id()
  net: mvpp2: add comments about smp_processor_id() usage
  net: mvpp2: remove unused mvpp2_bm_cookie_pool_set() function
  net: mvpp2: remove mvpp2_pool_refill()

 drivers/net/ethernet/marvell/mvpp2.c | 126 +++++++++++++++++------------------
 1 file changed, 60 insertions(+), 66 deletions(-)

-- 
2.7.4
