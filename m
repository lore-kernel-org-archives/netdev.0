From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: smc91x: Fix device tree based configuration so
 it's usable
Date: Wed, 11 Dec 2013 15:44:26 -0500 (EST)
Message-ID: <20131211.154426.2252395344655389568.davem@davemloft.net>
References: <20131127185657.GA26766@atomide.com>
	<52A8ADE6.8010209@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tony@atomide.com, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, nico@fluxnic.net, mark.rutland@arm.com
To: nm@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59389 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750873Ab3LKUo3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 15:44:29 -0500
In-Reply-To: <52A8ADE6.8010209@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nishanth Menon <nm@ti.com>
Date: Wed, 11 Dec 2013 12:24:38 -0600

> Hi Tony,
> On 11/27/2013 12:56 PM, Tony Lindgren wrote:
>> Commit 89ce376c6bdc (drivers/net: Use of_match_ptr() macro in smc91x.c)
>> added minimal device tree support to smc91x, but it's not working on
>> many platforms because of the lack of some key configuration bits.
>> 
>> Fix the issue by parsing the necessary configuration like the
>> smc911x driver is doing. As most smc91x users seem to use 16-bit
>> access, let's default to that if no reg-io-width is specified.
>> 
>> Cc: Nicolas Pitre <nico@fluxnic.net>
>> Cc: Mark Rutland <mark.rutland@arm.com>
>> Cc: netdev@vger.kernel.org
>> Cc: devicetree@vger.kernel.org
>> Signed-off-by: Tony Lindgren <tony@atomide.com>
>> 
>> ---
>> 
>> Device tree folks, any objection to using the reg-io-width property
>> as a mask here?
>> 
>> Looks like we can use reg-io-width as a mask too if needed, it seems
>> to play fine with combinations of 1 = 8-bit, 2 = 16-bit, 4 = 32-bit
>> and so on.
>> 
>> I would like to see this merged during the -rc cycle as this makes
>> my test devices behave the same way when booted in legacy platform
>> data mode compared to when booted with device tree.
>> 
> please feel free to add my:
> Acked-by: Nishanth Menon <nm@ti.com>
> 
> Also tested on SDP2430:
> http://pastebin.mozilla.org/3756403

That patch needs changes, it adds a warning when CONFIG_OF is disabled
because the variable 'np' only gets used in the CONFIG_OF protected
code block yet is declared unconditionally.
