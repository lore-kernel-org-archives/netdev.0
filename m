From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC] EEPROM dumping/changing code for r8169 driver
Date: Sun, 21 Jul 2013 17:01:54 +0100
Message-ID: <1374422514.2804.4.camel@deadeye.wl.decadent.org.uk>
References: <1906856.2MoFjQXLhS@al>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, <netdev@vger.kernel.org>,
	"Realtek linux nic maintainers" <nic_swsd@realtek.com>
To: Peter Wu <lekensteyn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:38437 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755662Ab3GUQB6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jul 2013 12:01:58 -0400
In-Reply-To: <1906856.2MoFjQXLhS@al>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-07-19 at 11:48 +0200, Peter Wu wrote:
> Hi,
> 
> As noted in another mail, I have been working on adding EEPROM reading
> writing support for the r8169 driver. The below diff adds basic support, but it
> is not completely finished yet:
[...]
> --- a/drivers/net/ethernet/realtek/Kconfig
> +++ b/drivers/net/ethernet/realtek/Kconfig
> @@ -112,4 +112,13 @@ config R8169
>  	  To compile this driver as a module, choose M here: the module
>  	  will be called r8169.  This is recommended.
>  
> +config R8169_93CX6
> +	bool "Realtek 8169 external 93CX6 EEPROM support"
> +	depends on R8169
> +	select EEPROM_93CX6
[...]

This select is wrong as it will cause EEPROM_93CX6=y even if R8169=m.
But why make this an option at all?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
