From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: net: stmmac: dwmac-rk: fixes for Wake-on-Lan on RK3288
Date: Mon, 13 Jun 2016 08:46:10 +0200
Message-ID: <3d278dd6-0b61-f618-b723-52f9c302c999@st.com>
References: <bd302fc6-feae-b99a-4632-a0ff9ead0123@st.com>
 <1465606839-7722-1-git-send-email-vpalatin@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>,
	Douglas Anderson <dianders@chromium.org>,
	=?UTF-8?Q?Heiko_St=c3=bcbner?= <heiko@sntech.de>,
	Shunqian Zheng <zhengsq@rock-chips.com>,
	David Miller <davem@davemloft.net>
To: Vincent Palatin <vpalatin@chromium.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1465606839-7722-1-git-send-email-vpalatin@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/11/2016 3:00 AM, Vincent Palatin wrote:
> In order to support Wake-On-Lan when using the RK3288 integrated MAC
> (with an external RGMII PHY), we need to avoid shutting down the regulator
> of the external PHY when the MAC is suspended as it's currently done in the MAC
> platform code.
> As a first step, create independant callbacks for suspend/resume rather than
> re-using exit/init callbacks. So the dwmac platform driver can behave differently
> on suspend where it might skip shutting the PHY and at module unloading.
> Then update the dwmac-rk driver to switch off the PHY regulator only if we are
> not planning to wake up from the LAN.
> Finally add the PMT interrupt to the MAC device tree configuration, so we can
> wake up the core from it when the PHY has received the magic packet.

IMO these could be sent for net-next and also other glue logic
files should be reworked in order to use the new API for coherence.

Peppe
