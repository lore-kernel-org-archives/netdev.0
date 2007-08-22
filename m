From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH 6/7 v2] fs_enet: Be an of_platform device when CONFIG_PPC_CPM_NEW_BINDING
 is set.
Date: Wed, 22 Aug 2007 16:16:13 -0500
Message-ID: <46CCA79D.40003@freescale.com>
References: <20070817181718.GA15792@ld0162-tx32.am.freescale.net> <20070821130155.43898b68@localhost.localdomain> <46CB172D.9010807@freescale.com> <20070823010057.74e1355a@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Vitaly Bordug <vitb@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:60995 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754409AbXHVVQ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2007 17:16:26 -0400
In-Reply-To: <20070823010057.74e1355a@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Vitaly Bordug wrote:
> yes, wrong snippet what about
> 
> 
>> #ifdef CONFIG_CPM2 +	r = fs_enet_mdio_bb_init(); +	if (r != 0) +
>> goto out_mdio_bb; +#endif +#ifdef CONFIG_8xx +	r =
>> fs_enet_mdio_fec_init(); +	if (r != 0) +		goto out_mdio_fec; 
>> +#endif
> 
> 
> We had to pray and hope that 8xx would only have fec, and cpm2 has
> some bitbanged stuff. now we can inquire dts and know for sure, at
> least it seems so.

Yeah, that sucks.  We should add kconfig options for each mii type, and
let them have their own init functions.

That only affects the initcalls (and kernel size), though; it still uses 
the phy-handle to decide what mdio controller to actually talk to.

>> How is that different from the old code, where you're hosed without
>>  fep->fpi->bus_id?
>> 
> 
> 
> I wasn't defending old code, and consider "old code is POS, new one
> is just great" game meaningless. I am just stating the problem, that
> we'll have to address later. On 8xx even reference boards may be 
> without phy at all.

OK -- would it suffice to just never call any phylib functions and
always assume the link is up if the phy-handle property is undefined?

> ok, agreed, size is most serious judge here. we'll definitely have to
> revisit pin problem later too (because custom designs sometimes
> switch contradictory devices on-the-fly, disable soc parts for
> alternative function, etc.)

If it's really on-the-fly (and not jumpered/once-per-boot), then board 
code should expose some kind of API to switch the functions, acting like 
a hotplug bus.  Associating it with open/close of the device won't work 
if one of the devices is something like USB which needs to start working 
without any internal open()-like action.

-Scott
