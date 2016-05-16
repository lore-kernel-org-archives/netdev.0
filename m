From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] phy: remove irq param to fix crash in fixed_phy_add()
Date: Mon, 16 May 2016 10:26:18 -0700
Message-ID: <573A02BA.3080709@gmail.com>
References: <1463397356-5656-1-git-send-email-rabin.vincent@axis.com>
 <20160516122903.GA27725@lunn.ch>
 <20160516131134.GA31094@lnxartpec.se.axis.com>
 <20160516134042.GD27725@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Rabin Vincent <rabin.vincent@axis.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-m68k@lists.linux-m68k.org, linux-mips@linux-mips.org,
	devicetree@vger.kernel.org, Rabin Vincent <rabinv@axis.com>
To: Andrew Lunn <andrew@lunn.ch>, Rabin Vincent <rabin@rab.in>
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <20160516134042.GD27725@lunn.ch>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/16/2016 06:40 AM, Andrew Lunn wrote:
> On Mon, May 16, 2016 at 03:11:35PM +0200, Rabin Vincent wrote:
>> On Mon, May 16, 2016 at 02:29:03PM +0200, Andrew Lunn wrote:
>>> What i think is better is to make fixed_phy_add() return -EPROBE_DEFER
>>> if it is called before fixed_mdio_bus_init().
>>
>> I don't see how this will work for platforms such as ar7 and bcm47xx
>> which call fixed_phy_add() from platform code.
> 
> Ah! Not good.
> 
> fixed_phy_add() is the lower layer call. What we can do is only access
> fmb->mii_bus->irq[phy_addr] if irq != PHY_POLL. That should make ar7
> and bcm47xx work again.
> 
> The higher level function fixed_phy_register() should return
> -EPROBE_DEFER if fixed_mdio_bus_init() has not been called yet.

ar7 and bcm47xx date back from when the fixed MDIO bus needed its fixed
PHYs to be registered before the MDIO bus driver had a chance to probe
them, otherwise, you would not be able to utilize them. Things have
changed now, and your suggestion makes sense.
-- 
Florian
