From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/6] net: davinci_emac: Free clock after checking the
 frequency
Date: Tue, 13 Jan 2015 16:05:22 -0500 (EST)
Message-ID: <20150113.160522.558845761776458001.davem@davemloft.net>
References: <1421177368-19756-4-git-send-email-tony@atomide.com>
	<54B57688.6000908@amd.com>
	<20150113195415.GG2419@atomide.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: thomas.lendacky@amd.com, netdev@vger.kernel.org,
	linux-omap@vger.kernel.org, b.hutchman@gmail.com, balbi@ti.com
To: tony@atomide.com
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <20150113195415.GG2419@atomide.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tony Lindgren <tony@atomide.com>
Date: Tue, 13 Jan 2015 11:54:16 -0800

> * Tom Lendacky <thomas.lendacky@amd.com> [150113 11:51]:
>> On 01/13/2015 01:29 PM, Tony Lindgren wrote:
>> >We only use clk_get() to get the frequency, the rest is done by
>> >the runtime PM calls. Let's free the clock too.
>> >
>> >Cc: Brian Hutchinson <b.hutchman@gmail.com>
>> >Cc: Felipe Balbi <balbi@ti.com>
>> >Signed-off-by: Tony Lindgren <tony@atomide.com>
>> >---
>> >  drivers/net/ethernet/ti/davinci_emac.c | 1 +
>> >  1 file changed, 1 insertion(+)
>> >
>> >diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
>> >index deb43b3..e9efc74 100644
>> >--- a/drivers/net/ethernet/ti/davinci_emac.c
>> >+++ b/drivers/net/ethernet/ti/davinci_emac.c
>> >@@ -1881,6 +1881,7 @@ static int davinci_emac_probe(struct platform_device *pdev)
>> >  		return -EBUSY;
>> >  	}
>> >  	emac_bus_frequency = clk_get_rate(emac_clk);
>> >+	clk_put(emac_clk);
>> 
>> The devm_clk_get call is used to get the clock so either a devm_clk_put
>> needs to be used here or just let the devm_ call do its thing and
>> automatically do the put when the module is unloaded.
> 
> Thanks good catch, updated patch below.

Please, once all the feedback has been addressed, repost the entire
series.

THanks.
