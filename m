From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCHv2 0/9] macb: add support for Cadence GEM
Date: Mon, 21 Mar 2011 14:38:18 +0800
Message-ID: <4D86F25A.7060405@atmel.com>
References: <1300184096-13937-1-git-send-email-jamie@jamieiles.com> <20110316.131734.242138246.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	plagnioj@jcrosoft.com, Andrew Victor <linux@maxim.org.za>,
	Peter Korsgaard <jacmet@sunsite.dk>
To: David Miller <davem@davemloft.net>, jamie@jamieiles.com,
	Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from newsmtp5.atmel.com ([204.2.163.5]:10189 "EHLO
	sjogate2.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751771Ab1CUGip (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2011 02:38:45 -0400
In-Reply-To: <20110316.131734.242138246.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/17/2011 4:17 AM, David Miller :
> From: Jamie Iles <jamie@jamieiles.com>
> Date: Tue, 15 Mar 2011 10:14:47 +0000
> 
>> This patch series extends the Atmel MACB driver to support the Cadence
>> GEM (Gigabit Ethernet MAC) to support 10/100 operation.  The GEM is
>> based on the MACB block but has a few moved registers and bitfields.
>> This patch series attempts to use the MACB accessors where block
>> functionallity is identical and only overrides to GEM specific
>> acccessors when needed.
>>
>> This has been runtested on a board with a Cadence GEM and compile tested
>> for all at91 configurations and a number of avr32 configurations.
>>
>> Changes since v1:
>> 	- AT91 now provides a fake "hclk" and "macb_clk" has been
>> 	renamed to "pclk" to be consistent with AVR32.
>> 	- Configurable GEM receive buffer size support has been added.
>> 	- pr_foo() and dev_foo() have been converted to netdev_foo()
>> 	where appropriate.
>> 	- New conditional accessors (macb_or_gem_{read,write}l) have
>> 	been introduced that do the conditional accesses dependent on
>> 	macb/gem type.
>> 	- GEM is now dynamically detected from the module ID rather than
>> 	platform device name.
>>
>> Jean-Christophe, I haven't based this on your conditional clock patch as
>> I wasn't sure what decision had been made on that and whether the
>> at91/avr32 detection is reliable.
> 
> I'm happy to ACK this so you guys can merge this via one of the
> ARM trees:
> 
> Acked-by: David S. Miller <davem@davemloft.net>

I add my:

Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

Now, tell me if we need to setup a git tree with this and make it handled by linux-next (we do not have for at91 yet)?
or Russell can take the series in a "devel" branch?

I have tested the series with the v2 patches. It is working good with some modification that were discussed (hclk, pclk clocks). I attach modifications I have made to make it work so that you have an idea of my testbed (not a patch as you should already have this and it is on a development platform):

+/* One additional fake clock for macb interfaces */
+static struct clk hclk = {
+       .name           = "hclk",
+       .pmc_mask       = 0,
+       .type           = CLK_TYPE_PERIPHERAL,
+};

@@ -247,6 +254,7 @@ static struct clk *periph_clocks[] __initdata = {
        // irq0
        &ohci_clk,
        &tcb1_clk,
+       &hclk,
 };

[..]

                /* Clock */
-               at91_clock_associate("macb0_clk", &at91sam9x5_eth0_device.dev, "macb_clk");
+               at91_clock_associate("macb0_clk", &at91sam9x5_eth0_device.dev, "pclk");

                eth0_data = *data;
                platform_device_register(&at91sam9x5_eth0_device);

Thanks, best regards,
-- 
Nicolas Ferre

