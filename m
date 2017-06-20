From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: phy: smsc: fix buffer overflow in memcpy
Date: Tue, 20 Jun 2017 23:46:15 +0200
Message-ID: <20170620214615.GF12383@lunn.ch>
References: <20170620204059.790066-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Timur Tabi <timur@codeaurora.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170620204059.790066-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 20, 2017 at 10:40:46PM +0200, Arnd Bergmann wrote:
> The memcpy annotation triggers for a fixed-length buffer copy:
> 
> In file included from /git/arm-soc/arch/arm64/include/asm/processor.h:30:0,
>                  from /git/arm-soc/arch/arm64/include/asm/spinlock.h:21,
>                  from /git/arm-soc/include/linux/spinlock.h:87,
>                  from /git/arm-soc/include/linux/seqlock.h:35,
>                  from /git/arm-soc/include/linux/time.h:5,
>                  from /git/arm-soc/include/linux/stat.h:21,
>                  from /git/arm-soc/include/linux/module.h:10,
>                  from /git/arm-soc/drivers/net/phy/smsc.c:20:
> In function 'memcpy',
>     inlined from 'smsc_get_strings' at /git/arm-soc/drivers/net/phy/smsc.c:166:3:
> /git/arm-soc/include/linux/string.h:309:4: error: call to '__read_overflow2' declared with attribute error: detected read beyond size of object passed as 2nd parameter
> 
> Using strncpy instead of memcpy should do the right thing here.

Hi Arnd

You will find this pattern in number of phy drivers:

bcm-phy-lib.c:	   	   memcpy(data + i * ETH_GSTRING_LEN,
marvell.c:			       		   memcpy(data + i * ETH_GSTRING_LEN,
micrel.c:   		memcpy(data + i * ETH_GSTRING_LEN,
smsc.c:				    memcpy(data + i * ETH_GSTRING_LEN,

They probably all need the same fix.

     Andrew
