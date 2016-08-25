From: Robert Jarzmik <robert.jarzmik@free.fr>
Subject: Re: [PATCH] smc91x: remove ARM hack for unaligned 16-bit writes
Date: Thu, 25 Aug 2016 20:02:35 +0200
Message-ID: <87inuopw04.fsf@belgarion.home>
References: <20160825144314.1850730-1-arnd@arndb.de>
        <3062310.z9h3CgCZ7p@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Russell King <linux@armlinux.org.uk>,
        linux-arm-kernel@lists.infradead.org,
        Nicolas Pitre <nico@fluxnic.net>,
        "David S. Miller" <davem@davemloft.net>,
        Yoshinori Sato <ysato@users.sourceforge.jp>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3062310.z9h3CgCZ7p@wuerfel> (Arnd Bergmann's message of "Thu, 25
        Aug 2016 16:45:12 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann <arnd@arndb.de> writes:

> On Thursday, August 25, 2016 4:43:04 PM CEST Arnd Bergmann wrote:
>>  drivers/net/ethernet/smsc/smc91x.h | 50 +++++++++++++++++++++++---------------
>>  1 file changed, 30 insertions(+), 20 deletions(-)
>> 
>> While this patch fixes one bug on Neponset, it probably doesn't address
>> the one that Russell ran into first, so this is for review only for now,
>> until the remaining problem(s) have been worked out.
>> 
>
> The comment should have been on another patch, my mistake. please
> see v2.
>
> 	Arnd

Hi Arnd,

I didn't review the patch thoroughly, but I launched your 2 patches in my pxa
little farm.

The result is that lubbock and mainstone are all right, but zylonite is broken
(ie. networkless). I removed then these 2 patches and zylonite worked again.

I have also an error message on the console on a "broken" zylonite :
  Changing smcs91x MAC address to 08:00:3e:26:0a:5b: ifconfig: SIOCSIFHWADDR:
  Device or resource busy

I reran the test twice (2 times with your patches, 2 times without), the result
looks consistent, ie. zylonite doesn't really like them.

Cheers.

-- 
Robert

PS: even if zylonite defconfig is not in the tree, it uses this driver, with :
CONFIG_SMC91X=y
...and...
static struct smc91x_platdata zylonite_smc91x_info = {
	.flags	= SMC91X_USE_8BIT | SMC91X_USE_16BIT |
		  SMC91X_NOWAIT | SMC91X_USE_DMA,
};
