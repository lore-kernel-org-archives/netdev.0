From: Robby Cai <robby.cai@gmail.com>
Subject: Re: [PATCH 8/8 V2] MX27ADS: Add CS89x0 support
Date: Fri, 1 May 2009 07:10:18 +0800
Message-ID: <c8d1e6a0904301610t352bbe99jcdc24e215a57598d@mail.gmail.com>
References: <1240963177-23941-1-git-send-email-vbarinov@embeddedalley.com>
	<1240963405-24007-1-git-send-email-vbarinov@embeddedalley.com>
	<c8d1e6a0904290148h7521fa36peb9fd5b4a64b97ab@mail.gmail.com>
	<49F981E6.4050602@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, s.hauer@pengutronix.de,
	linux-arm-kernel@lists.arm.linux.org.uk
To: Vladimir Barinov <vova.barinov@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.arm.linux.org.uk>
In-Reply-To: <49F981E6.4050602@gmail.com>
List-Unsubscribe: <http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.arm.linux.org.uk?subject=unsubscribe>
List-Archive: <http://lists.arm.linux.org.uk/lurker/list/linux-arm-kernel.html>
List-Post: <mailto:linux-arm-kernel@lists.arm.linux.org.uk>
List-Help: <mailto:linux-arm-kernel-request@lists.arm.linux.org.uk?subject=help>
List-Subscribe: <http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.arm.linux.org.uk?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.arm.linux.org.uk
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.arm.linux.org.uk
List-Id: netdev.vger.kernel.org

IIRC, someone in this list recommends to do like the following(for
example), rather than always add new item at the end of the line.

  depends on MACH_IXDP2351 || ARCH_IXDP2X01 || ARCH_PNX010X ||
MACH_MX27ADS || MACH_MX31ADS

And next time if we would like to another new item, saying MACH_MX21ADS,
then the result would be

  depends on MACH_IXDP2351 || ARCH_IXDP2X01 || ARCH_PNX010X ||
MACH_MX21ADS || MACH_MX27ADS || MACH_MX31ADS

Regards,
Robby

On Thu, Apr 30, 2009 at 6:48 PM, Vladimir Barinov <vova.barinov@gmail.com>wrote:

> Hello Robby,
>
> Robby Cai wrote:
>
>> Does it make sense if we add keep the new items in the alphabetic/numeric
>> order?
>> Nowadays, seems more and more people are paying attention on this.
>>
>>  What actually do propose to line up in alphabetic/numeric order here?
> AFAIK the alphabetic order is suggested to use in Kconfig files for
> variables.
> Not sure if this valid here. In this patch you can find only added
> dependencies.
>
>  Regards,
>> Robby
>>
>> On Wed, Apr 29, 2009 at 8:03 AM, Vladimir Barinov <vova.barinov@gmail.com<mailto:
>> vova.barinov@gmail.com>> wrote:
>>
>>    Add CS89x0 net chip support for MX27ADS board
>>
>>    Signed-off-by: Vladimir Barinov <vbarinov@embeddedalley.com
>>    <mailto:vbarinov@embeddedalley.com>>
>>
>>    ---
>>     drivers/net/Kconfig  |    5 +++--
>>     drivers/net/cs89x0.c |   10 ++++++++--
>>     2 files changed, 11 insertions(+), 4 deletions(-)
>>
>>    diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
>>    index 214a92d..25fd824 100644
>>    --- a/drivers/net/Kconfig
>>    +++ b/drivers/net/Kconfig
>>    @@ -1438,7 +1438,8 @@ config FORCEDETH_NAPI
>>     config CS89x0
>>           tristate "CS89x0 support"
>>           depends on NET_ETHERNET && (ISA || EISA || MACH_IXDP2351 \
>>    -               || ARCH_IXDP2X01 || ARCH_PNX010X || MACH_MX31ADS)
>>    +               || ARCH_IXDP2X01 || ARCH_PNX010X || MACH_MX31ADS \
>>    +               || MACH_MX27ADS)
>>           ---help---
>>             Support for CS89x0 chipset based Ethernet cards. If you
>>    have a
>>             network (Ethernet) card of this type, say Y and read the
>>    @@ -1452,7 +1453,7 @@ config CS89x0
>>     config CS89x0_NONISA_IRQ
>>           def_bool y
>>           depends on CS89x0 != n
>>    -       depends on MACH_IXDP2351 || ARCH_IXDP2X01 || ARCH_PNX010X
>>    || MACH_MX31ADS
>>    +       depends on MACH_IXDP2351 || ARCH_IXDP2X01 || ARCH_PNX010X
>>    || MACH_MX31ADS || MACH_MX27ADS
>>
>>     config TC35815
>>           tristate "TOSHIBA TC35815 Ethernet support"
>>    diff --git a/drivers/net/cs89x0.c b/drivers/net/cs89x0.c
>>    index 7433b88..558f630 100644
>>    --- a/drivers/net/cs89x0.c
>>    +++ b/drivers/net/cs89x0.c
>>    @@ -195,6 +195,12 @@ static unsigned int netcard_portlist[] __used
>>    __initdata = {
>>           PBC_BASE_ADDRESS + PBC_CS8900A_IOBASE + 0x300, 0
>>     };
>>     static unsigned cs8900_irq_map[] = {EXPIO_INT_ENET_INT, 0, 0, 0};
>>    +#elif defined(CONFIG_MACH_MX27ADS)
>>    +#include <mach/board-mx27ads.h>
>>    +static unsigned int netcard_portlist[] __used __initdata = {
>>    +       PBC_CS8900A_IOBASE_REG + 0x300 + 3, 0
>>    +};
>>    +static unsigned cs8900_irq_map[] = {EXPIO_INT_ENET_INT, 0, 0, 0};
>>     #else
>>     static unsigned int netcard_portlist[] __used __initdata =
>>       { 0x300, 0x320, 0x340, 0x360, 0x200, 0x220, 0x240, 0x260,
>>    0x280, 0x2a0, 0x2c0, 0x2e0, 0};
>>    @@ -1034,7 +1040,7 @@ skip_this_frame:
>>
>>     static void __init reset_chip(struct net_device *dev)
>>     {
>>    -#if !defined(CONFIG_MACH_MX31ADS)
>>    +#if !defined(CONFIG_MACH_MX31ADS) && !defined(CONFIG_MACH_MX27ADS)
>>     #if !defined(CONFIG_MACH_IXDP2351) && !defined(CONFIG_ARCH_IXDP2X01)
>>           struct net_local *lp = netdev_priv(dev);
>>           int ioaddr = dev->base_addr;
>>    @@ -1063,7 +1069,7 @@ static void __init reset_chip(struct
>>    net_device *dev)
>>           reset_start_time = jiffies;
>>           while( (readreg(dev, PP_SelfST) & INIT_DONE) == 0 &&
>>    jiffies - reset_start_time < 2)
>>                   ;
>>    -#endif /* !CONFIG_MACH_MX31ADS */
>>    +#endif /* !CONFIG_MACH_MX31ADS && !CONFIG_MACH_MX27ADS */
>>     }
>>
>>
>>    --
>>    1.5.6
>>
>>
>>    -------------------------------------------------------------------
>>    List admin:
>>    http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel
>>    FAQ:        http://www.arm.linux.org.uk/mailinglists/faq.php
>>    Etiquette:  http://www.arm.linux.org.uk/mailinglists/etiquette.php
>>
>>
>>
>
-------------------------------------------------------------------
List admin: http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel
FAQ:        http://www.arm.linux.org.uk/mailinglists/faq.php
Etiquette:  http://www.arm.linux.org.uk/mailinglists/etiquette.php
