From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Subject: [PATCH 3.6.0- 0/3] NET: use module_platform_driver macro
Date: Wed, 10 Oct 2012 19:28:11 +0100
Message-ID: <1349893691-6779-1-git-send-email-srinivas.kandagatla@st.com>
Cc: srinivas.kandagatla@st.com, bordug@ru.mvista.com,
	netdev@vger.kernel.org, david.daney@cavium.com,
	linville@tuxdriver.com, kaloz@openwrt.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:39829 "EHLO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751497Ab2JJSaZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2012 14:30:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Srinivas Kandagatla <srinivas.kandagatla@st.com>

Running below Coccinelle lookup pattern like below on the 
latest kernel showed about 52 hits. This patch series is a subset 
of those 52 patches, so that it will be easy for maintainers to review.
Hopefully these patches will get rid of some code duplication in kernel.

@  @
- initfunc(void)
- { return platform_driver_register(&dr); }

...

- module_init(initfunc);
...

- exitfunc(void)
- { platform_driver_unregister(&dr); }

...

- module_exit(exitfunc);
+ module_platform_driver(dr); 


Srinivas Kandagatla (3):
  net/mdio-gpio: use module_platform_driver macro
  net/mdio-octeon: use module_platform_driver macro
  wireless/ath5k: use module_platform_driver macro

 drivers/net/phy/mdio-gpio.c          |   13 +------------
 drivers/net/phy/mdio-octeon.c        |   14 +-------------
 drivers/net/wireless/ath/ath5k/ahb.c |   16 +---------------
 3 files changed, 3 insertions(+), 40 deletions(-)
