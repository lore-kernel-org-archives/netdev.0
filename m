From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH net-next 00/17] stmmac clean up for 4.3 part2
Date: Wed, 29 Jul 2015 00:08:47 +0200
Message-ID: <1438121344-5304-1-git-send-email-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, netdev@vger.kernel.org,
	b.galvani@gmail.com, arnd@arndb.de, roger.chen@rock-chips.com,
	heiko@sntech.de, wens@csie.org, dinguyen@opensource.altera.com,
	linux-rockchip@lists.infradead.org, mathieu@codeaurora.org
To: peppe.cavallaro@st.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f68.google.com ([209.85.215.68]:34244 "EHLO
	mail-la0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751509AbbG1WJV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2015 18:09:21 -0400
Received: by laef2 with SMTP id f2so5864910lae.1
        for <netdev@vger.kernel.org>; Tue, 28 Jul 2015 15:09:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set creates proper probe functions in the remaining
dwmac-* drivers, lets the drivers manage their own of match data
structure, and cleans up some of the drivers a bit. Note that
should be no functional change in any of the drivers.

First patch from Fengguang fixes a Coccinelle that was found after
the previous patch set when into next.

Probe functions are best placed just above the platform_driver
struct since it usually needs to call other functions in the
driver but this requires some code movement in the drivers. To
keep the conversion itself easier to review the code movement is
done in separate patches. This creates some extra churn but I
think it's worth it in this case.

As only a couple of drivers actually needs to use of match data
this pushed down from stmmac_platform and into the drivers. This
also makes it possible for drivers to have their own match data
structure. dwmac-rk benefits most from this.

After each driver has it's own probe function and manages it's
own match data the setup/free hooks and common match data struct
are removed.

Sorry for the slightly largish patch set this time around.


Since I can only test the core changes on my platform and not the
specific dwmac-drivers I greatly appreciate if people could test
this on their respective platforms. I did spend quite a bit of
time visually checking all these patches, but nothing beats real
hardware testing. Thanks!


Patch set based on net-next can also be picked up from here:
https://github.com/manabian/linux-lpc.git stmmac_4.3_part2

For those who want to have a look at all the patches for
v4.3 a branch based on Linus master can be found here:
https://github.com/manabian/linux-lpc.git stmmac_4.2


Previous parts can be found here:
http://www.spinics.net/lists/netdev/msg328997.html
http://www.spinics.net/lists/netdev/msg329932.html
http://www.spinics.net/lists/netdev/msg336097.html


Fengguang Wu (1):
  stmmac: fix ptr_ret.cocci warning

Joachim Eastwood (16):
  stmmac: dwmac-ipq806x: move ipq806x_gmac_fix_mac_speed function
  stmmac: dwmac-ipq806x: turn setup callback into a probe function
  stmmac: dwmac-socfpga: move socfpga_dwmac_probe function
  stmmac: dwmac-socfpga: turn setup callback into a probe function
  stmmac: dwmac-sunxi: move sun7i_gmac_setup function
  stmmac: dwmac-sunxi: turn setup callback into a probe function
  stmmac: dwmac-sti: turn setup callback into a probe function
  stmmac: dwmac-rk: create a new probe function
  stmmac: move stmmac_pltfr_probe into dwmac-generic
  stmmac: let dwmac-* drivers handle their own match data
  stmmac: dwmac-sti: use custom of match structure
  stmmac: dwmac-rk: make rk_gmac_ops structs static const
  stmmac: dwmac-rk: use rk_gmac_ops as of match data
  stmmac: remove unused stmmac_of_data struct
  stmmac: remove setup/free glue callbacks
  stmmac: dwmac-sti: refactor the init glue callbacks

 Documentation/networking/stmmac.txt                | 10 +--
 .../net/ethernet/stmicro/stmmac/dwmac-generic.c    | 42 +++++++++-
 .../net/ethernet/stmicro/stmmac/dwmac-ipq806x.c    | 50 +++++++-----
 drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c     | 73 ++++++++++-------
 .../net/ethernet/stmicro/stmmac/dwmac-socfpga.c    | 78 ++++++++++--------
 drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c    | 83 ++++++++++---------
 drivers/net/ethernet/stmicro/stmmac/dwmac-sunxi.c  | 95 ++++++++++++----------
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  | 80 +-----------------
 .../net/ethernet/stmicro/stmmac/stmmac_platform.h  |  1 -
 include/linux/stmmac.h                             | 20 -----
 10 files changed, 260 insertions(+), 272 deletions(-)

-- 
1.8.0
