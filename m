From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Subject: Re: [PATCH v7] ethernet/arc/arc_emac - Add new driver
Date: Fri, 21 Jun 2013 10:53:47 +0000
Message-ID: <4881796E12491D4BB15146FE0209CE643F5F587E@DE02WEMBXB.internal.synopsys.com>
References: <1371799241-27771-1-git-send-email-abrodkin@synopsys.com>
 <1371810775.19215.30.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Alexey Brodkin <Alexey.Brodkin@synopsys.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Andy Shevchenko <andy.shevchenko@gmail.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Vineet Gupta <Vineet.Gupta1@synopsys.com>,
	Mischa Jonker <Mischa.Jonker@synopsys.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Grant Likely <grant.likely@linaro.org>,
	"Rob Herring" <rob.herring@calxeda.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>,
	Florian Fainelli <florian@openwrt.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/21/2013 02:32 PM, Joe Perches wrote:
> On Fri, 2013-06-21 at 11:20 +0400, Alexey Brodkin wrote:
>> Driver for non-standard on-chip ethernet device ARC EMAC 10/100,
>> instantiated in some legacy ARC (Synopsys) FPGA Boards such as
>> ARCAngel4/ML50x.
>
> Looks fine to me.
>
> One nit you could fix later and a question.
>
>> diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
> []
>> +static int arc_emac_rx(struct net_device *ndev, int budget)
>> +{
> []
>> +			if (net_ratelimit())
>> +				netdev_err(ndev, "incomplete packed received\n");
>
> s/packed/packet/

Ooops. Thanks for noticing this subtle misspelling.

>> +		rxbd->data = (unsigned char *)cpu_to_le32(rx_buff->skb->data);
>
> 32 bit only.  Should the Kconfig block have some arch_arc dependency
> so it can't get compiled for 64 bit systems?

Well, initially I add dependency on ARC in Kconfig.
But later removed it because in driver itself there're really no 
ARC-specific things. So why don't make it available for any other arch?
For example I re-used Xilinx SystemACE driver on ARC even though it was 
only targeted for PPC/Microblaze. And now I need to add another 
dependency (+ || ARC) in Kconfig for all block devices.

But your comment regarding 64-bit arches makes perfect sense. But still 
I don't know if there's a way to restrict usage on only 32-bit arches 
(independent of being x86/arc/mips/etc). I may suppose that only strict 
specification of all virtually supported 32-bit arches - which is 
nonsense I think.

Also independence of architecture makes it possible to compile driver on 
x86 for x86 with native toolchain. In other words anybody may try to 
compile it. And I thought it's if not mandatory but at least very 
welcome - if maintainer or reviewer may compile stuff and teach me how 
to eliminate all compile-time warnings/errors.

But during compilation on x86 one needs to enable OF. Which will lead to 
compilation errors in other things.

So for now I may easily add dependency on ARC if it makes acceptance of 
driver easier.

-Alexey
