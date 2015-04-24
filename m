From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: mdio-gpio: support access that may sleep
Date: Fri, 24 Apr 2015 20:25:07 +0300
Message-ID: <553A7C73.7040002@cogentembedded.com>
References: <1429722414-18173-1-git-send-email-vivien.didelot@savoirfairelinux.com> <20150424.110455.2117537129018647564.davem@davemloft.net> <553A67B2.3040400@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com
To: Florian Fainelli <f.fainelli@gmail.com>,
	David Miller <davem@davemloft.net>,
	vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <553A67B2.3040400@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/24/2015 06:56 PM, Florian Fainelli wrote:

>>> Some systems using mdio-gpio may use gpio on message based busses, which
>>> require sleeping (e.g. gpio from an I2C I/O expander).

>>> Since this driver does not use IRQ handler, it is safe to use the
>>> _cansleep suffixed gpio accessors.

>>> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

>> Since this is down underneath the layer of an MII bus, you cannot
>> universally say that these routines are always called in a sleepable
>> context.

>> The PHY layer, and the driver itself above that, might call these
>> routines from timers, interruptes etc.

> The PHY library calls these routines from its state machine workqueue
> for that reason, or from process context (when invoked via ethtool
> ioctl). The only special case is phy_mac_interrupt() which is callable
> from interrupt context,

    It is not (as we have discussed recently) -- cancel_work_sync() may sleep.

WBR, Sergei
