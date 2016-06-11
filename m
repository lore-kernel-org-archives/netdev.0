From: Vincent Palatin <vpalatin@chromium.org>
Subject: net: stmmac: dwmac-rk: fixes for Wake-on-Lan on RK3288
Date: Fri, 10 Jun 2016 18:00:36 -0700
Message-ID: <1465606839-7722-1-git-send-email-vpalatin@chromium.org>
References: <bd302fc6-feae-b99a-4632-a0ff9ead0123@st.com>
Cc: linux-kernel@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>,
	Douglas Anderson <dianders@chromium.org>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	=?UTF-8?q?Heiko=20St=C3=BCbner?= <heiko@sntech.de>,
	Shunqian Zheng <zhengsq@rock-chips.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <bd302fc6-feae-b99a-4632-a0ff9ead0123@st.com>
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
