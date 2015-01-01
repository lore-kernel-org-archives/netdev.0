From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 0/7] Fixing the "Time Counter fixes and improvements"
Date: Thu,  1 Jan 2015 11:39:54 +0100
Message-ID: <cover.1420108214.git.richardcochran@gmail.com>
References: <20141231.183347.862533634176009078.davem@davemloft.net>
Cc: <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:49771 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750850AbbAAKqg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jan 2015 05:46:36 -0500
In-Reply-To: <20141231.183347.862533634176009078.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

I did not catch the missing includes in my x86 and arm testing,
because those archs somehow do include clocksource.h for the drivers
in question. Sorry.

This is how I would like to fix the header fallout. We really should
decouple the timecounter/cyclecounter code from the clocksource code
where possible.


Thanks,
Richard


Richard Cochran (7):
  timecounter: provide a macro to initialize the cyclecounter mask
    field.
  bnx2x: convert to CYCLECOUNTER_MASK macro.
  e1000e: convert to CYCLECOUNTER_MASK macro.
  igb: convert to CYCLECOUNTER_MASK macro.
  ixgbe: convert to CYCLECOUNTER_MASK macro.
  mlx4: include clocksource.h again
  microblaze: include the new timecounter header.

 arch/microblaze/kernel/timer.c                   |    1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    2 +-
 drivers/net/ethernet/intel/e1000e/netdev.c       |    2 +-
 drivers/net/ethernet/intel/igb/igb_ptp.c         |    4 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c     |    2 +-
 drivers/net/ethernet/mellanox/mlx4/en_clock.c    |    1 +
 include/linux/timecounter.h                      |    5 ++++-
 7 files changed, 11 insertions(+), 6 deletions(-)

-- 
1.7.10.4
