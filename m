From: Roger Quadros <rogerq@ti.com>
Subject: Re: [PATCH v2 2/3] net: can: c_can: Add syscon/regmap RAMINIT mechanism
Date: Wed, 1 Oct 2014 11:45:51 +0300
Message-ID: <542BBF3F.2040803@ti.com>
References: <1410273070-22485-1-git-send-email-rogerq@ti.com> <1410273070-22485-3-git-send-email-rogerq@ti.com> <20140930132650.GN1325@katana> <542AB137.30507@ti.com> <20140930135226.GO1325@katana> <542AB6E9.9000907@ti.com> <20140930141909.GP1325@katana> <542ABC90.7010900@pengutronix.de> <20140930144950.GQ1325@katana> <542AC5B2.9040406@pengutronix.de> <20140930152550.GR1325@katana> <542AD483.2020808@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <wg@grandegger.com>, <tony@atomide.com>, <tglx@linutronix.de>,
	<mugunthanvnm@ti.com>, <george.cherian@ti.com>, <balbi@ti.com>,
	<nsekhar@ti.com>, <nm@ti.com>,
	<sergei.shtylyov@cogentembedded.com>, <linux-omap@vger.kernel.org>,
	<linux-can@vger.kernel.org>, <netdev@vger.kernel.org>
To: Marc Kleine-Budde <mkl@pengutronix.de>,
	Wolfram Sang <wsa@the-dreams.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <542AD483.2020808@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/30/2014 07:04 PM, Marc Kleine-Budde wrote:
> On 09/30/2014 05:25 PM, Wolfram Sang wrote:
>>
>>> Yes, but syscon_regmap_lookup_by_phandle() doesn't need any support for
>>> additional parameters. Have a look at:
>>>
>>> drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
>>>
>>> First get the regmap, then the 1st argument is the offset in the regmap,
>>> the 2nd and 3rd could be the bits.
>>
>> So, for one driver the extra arguments are: <reg> <start_bit> <stop_bit>
>> For another driver (the stmmac example): <reg_offset> <reg_shift>
> 
> The DCAN's "reg" is a "reg_offset" as in the stmmc.
> 
> Roger, can we derive both start and done bit from a common reg_shift?

I'm sorry I didn't understand what you meant.

<&syscon_phandl> <reg offset> <start bit> <stop bit> should work well for us.
Even though reg offset is the same for both the DCAN instances.

> 
>> Phew... Then we should really have a "syscon-raminit" property probably,
>> so that at least plain "syscon" has a consistent syntax?
> 
> I think^whope we can have the same syntax as the stmmc :D

I agree too.

> 
>>>> So, I'd rather drop additional arguments.
>>>>
>>>> Why would you like to have it encoded in DT?
>>>
>>> Where put the information then? Into the driver, but where do you get
>>> the reference which instance of the DCAN you are, so that you can look
>>> up the correct bits?
>>
>> Agreed. I thought we had this information in the driver already, but we
>> haven't...
>>
> 
> The current driver relies on the of_alias_get_id(), which isn't
> considered best practice, is it? So I want to avoid this when switching
> to syscon.

cheers,
-roger
