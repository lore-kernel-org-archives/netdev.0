From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: Is Documentation/networking/phy.txt still up-to-date?
Date: Wed, 9 Nov 2016 09:07:08 -0800
Message-ID: <24676d24-5b07-7d26-6ffa-14e857960a52@gmail.com>
References: <582323A8.20706@laposte.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>
To: Sebastian Frias <sf84@laposte.net>, afleming@freescale.com,
        jgarzik@pobox.com,
        =?UTF-8?B?TcOlbnMgUnVsbGfDpXJk?= <mans@mansr.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <582323A8.20706@laposte.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/09/2016 05:24 AM, Sebastian Frias wrote:
> Hi,
> 
> Documentation/networking/phy.txt discusses phy_connect and states that:
> 
>  "...
> 
>  interface is a u32 which specifies the connection type used
>  between the controller and the PHY.  Examples are GMII, MII,
>  RGMII, and SGMII.  For a full list, see include/linux/phy.h
> 
>  Now just make sure that phydev->supported and phydev->advertising have any
>  values pruned from them which don't make sense for your controller (a 10/100
>  controller may be connected to a gigabit capable PHY, so you would need to
>  mask off SUPPORTED_1000baseT*).  See include/linux/ethtool.h for definitions
>  for these bitfields. Note that you should not SET any bits, or the PHY may
>  get put into an unsupported state.
> 
>  ..."
> 
> However, 'drivers/net/ethernet/aurora/nb8800.c' for example, does SETs some
> bits (in function 'nb8800_pause_adv').

All pause/flow control related bits should be set by the Ethernet MAC
driver because this is an Ethernet MAC, not PHY, thing. See this
discussion for some details:

https://www.mail-archive.com/netdev@vger.kernel.org/msg135347.html

So the nb8800 drivers does the correct thing here, but the documentation
should be updated to reflect that this applies to all bits, except the
Pause capabilities because these need to come from the Ethernet MAC.

> 
> I checked 'drivers/net/ethernet/broadcom/genet/bcmmii.c' and that one CLEARs
> bits (as per the documentation).
> 
> Does anybody knows what is the correct/recommended approach?

Both drivers do correct things, they just don't set the same things here.
-- 
Florian
