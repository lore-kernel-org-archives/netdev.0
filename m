From: Vincent Palatin <vpalatin@chromium.org>
Subject: [PATCH v2 0/3] net: stmmac: dwmac-rk: fixes for Wake-on-Lan on RK3288
Date: Wed, 15 Jun 2016 11:32:20 -0700
Message-ID: <cover.1466015458.git.vpalatin@chromium.org>
References: <CAP_ceTxFuCsqRQJ_9GMc5PSKqczA8Qwaa0jX22wQ2Dq=+GZUuQ@mail.gmail.com>
Cc: linux-kernel@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>,
	Douglas Anderson <dianders@chromium.org>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	=?UTF-8?q?Heiko=20St=C3=BCbner?= <heiko@sntech.de>,
	Shunqian Zheng <zhengsq@rock-chips.com>,
	Vincent Palatin <vpalatin@chromium.org>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAP_ceTxFuCsqRQJ_9GMc5PSKqczA8Qwaa0jX22wQ2Dq=+GZUuQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In order to support Wake-On-Lan when using the RK3288 integrated MAC
(with an external RGMII PHY), we need to avoid shutting down the regulator
of the external PHY when the MAC is suspended as it's currently done in the MAC
platform code.
As a first step, create independant callbacks for suspend/resume rather than
re-using exit/init callbacks. So the dwmac platform driver can behave differently
on suspend where it might skip shutting the PHY and at module unloading.
Then update the dwmac-rk driver to switch off the PHY regulator only if we are
not planning to wake up from the LAN.
Finally add the PMT interrupt to the MAC device tree configuration, so we can
wake up the core from it when the PHY has received the magic packet.

Changes since v1:
  * rename 'powered_down' variable into 'suspended'.
  * fix the logic recording the PHY suspended state according to Heiko comments.

Vincent Palatin (3):
  net: stmmac: allow to split suspend/resume from init/exit callbacks
  net: stmmac: dwmac-rk: keep the PHY up for WoL
  ARM: dts: rockchip: add interrupt for Wake-on-Lan on RK3288

 arch/arm/boot/dts/rk3288.dtsi                      |  5 ++-
 drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c     | 48 +++++++++++++++++++---
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |  8 +++-
 include/linux/stmmac.h                             |  2 +
 4 files changed, 54 insertions(+), 9 deletions(-)

-- 
2.8.0.rc3.226.g39d4020
