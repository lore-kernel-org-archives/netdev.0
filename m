From: Manfred Spraul <manfred@colorfullife.com>
Subject: Re: [PATCH] MII bus API for PHY devices
Date: Fri, 19 Nov 2004 21:18:19 +0100
Message-ID: <419E550B.7030107@colorfullife.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andy Fleming <afleming@freescale.com>,
        Jason McMullan <jason.mcmullan@timesys.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I don't like the polling/interrupt setup part:
- for a nic driver, there is no irq line that could be requested by 
mii_phy_irq_enable().
- if the mii bus driver uses it's own timers, then locking within the 
nics will be more difficult.

Could you make that part optional? For a nic driver, I would prefer if I 
could just call the ->startup part without the request_irq. If the nic 
irq handler notices that the nic got an event, then it would call an 
appropriate mii_bus function.

This also applies for something like /dev/phy/xy: With natsemi, it would 
be very tricky to add proper locking. The nic as an internal phy and an 
external mii bus. The internal phy is partially visible on the external 
bus and any accesses to the phy id of the internal phy on the external 
bus cause lockups. No big deal, I just move the internal phy around [the 
phy id doesn't matter], but I would prefer if I have to do that just for 
ethtool, not for multiple interfaces.

--
    Manfred
