From: Andy Fleming <afleming@freescale.com>
Subject: Re: [PATCH] MII bus API for PHY devices
Date: Thu, 18 Nov 2004 11:52:25 -0600
Message-ID: <9B0D9272-398A-11D9-96F6-000393C30512@freescale.com>
References: <069B6F33-341C-11D9-9652-000393DBC2E8@freescale.com>
Mime-Version: 1.0 (Apple Message framework v619)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <069B6F33-341C-11D9-9652-000393DBC2E8@freescale.com>
To: jason.mcmullan@timesys.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Replying this to the netdev list for their perusal.

First, I'm flattered that you've based this on the gianfar phy code, 
which I stole shamelessly from Benh's code, but Benh changed his code, 
and so I stole once more (the sungem_phy code he mentioned).  The 
current 2.6.9 gianfar driver has a completely different PHY 
infrastructure.  One which is a better model, I think, for abstraction 
than my previous code.

Which brings me to item #2: I have taken the code from the previous 
patch, and combined it with my newer PHY code, which should ease the 
way for someone to add some of the WOL features, and such.  I have 
compiled, and tested this code, and it works with the gianfar driver.

However, I've got a few questions for the network device community, on 
how best to finish this off.

The primary issue is how to classify the MII bus.  Should it be a 
proper bus, fitting within the new driver model?  This seems like the 
proper method to me, since the MII bus is, in fact, a bus.  But it's a 
bit of a strange bus.  The bus is attached at two ends.  One end has 
some number of PHY devices, and the corresponding drivers for them.  
The other end has some number of ethernet controllers, and their 
drivers.

So we have 3 implementation decisions which are affected by this:

1) How should we pass initialization information from the system to the 
bus.  Information like which irq to use for each PHY, and what the 
address space for the bus's controls is.  I would like to enforce 
encapsulation so that the ethernet drivers don't need to know this 
information, or pass it to the bus.

2) How should we reflect the dependency of the ethernet driver on the 
mii bus driver?

3) How should we bind ethernet drivers to PHY drivers?

Oh, and a 4th side-issue:
Should each PHY have its own file?  Or should we dump all the PHY 
drivers in one file?  And if so, should THAT file be separate from the 
mii bus implementation file?

Andy Fleming
Open Source Team
Freescale Semiconductor, Inc
