From: Marcin Wojtas <mw@semihalf.com>
Subject: [PATCH 0/3] Fixes for the network driver of Marvell Armada 375 SoC
Date: Thu,  6 Aug 2015 19:00:27 +0200
Message-ID: <1438880430-5480-1-git-send-email-mw@semihalf.com>
References: <y>
Cc: davem@davemloft.net, jason@lakedaemon.net,
	thomas.petazzoni@free-electrons.com,
	gregory.clement@free-electrons.com,
	ezequiel.garcia@free-electrons.com, alior@marvell.com,
	jaz@semihalf.com, Marcin Wojtas <mw@semihalf.com>
To: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:35043 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753220AbbHFRAu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2015 13:00:50 -0400
Received: by lbbpo9 with SMTP id po9so46752221lbb.2
        for <netdev@vger.kernel.org>; Thu, 06 Aug 2015 10:00:49 -0700 (PDT)
In-Reply-To: <y>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

This is a set of three patches that fix long-lasting problems implemented in
the initial support for the Armada 375 network controller.

Due to an inappropriate concept of handling the per-CPU sent packets'
processing on TX path the driver numerous problems occured, such as RCU
stalls. Those have been fixed, of which details you can find in the commit
logs. The patches were intensively tested on top of v4.2-rc5.

I'm looking forward to any comments or remarks.

Thanks,
Marcin

Marcin Wojtas (3):
  net: mvpp2: remove excessive spinlocks from driver initialization
  net: mvpp2: enable proper per-CPU TX buffers unmapping
  net: mvpp2: replace TX coalescing interrupts with hrtimer

 drivers/net/ethernet/marvell/mvpp2.c | 244 ++++++++++++++++++++++++-----------
 1 file changed, 167 insertions(+), 77 deletions(-)

-- 
1.8.3.1
