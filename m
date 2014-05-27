From: Darek Marcinkiewicz <reksio@newterm.pl>
Subject: Re: [PATCH] net: ec_bhf: Add runtime dependencies
Date: Tue, 27 May 2014 22:30:59 +0200
Message-ID: <20140527203059.GA25384@newterm.pl>
References: <20140526212614.6e2610b0@endymion.delvare>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Jean Delvare <jdelvare@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.newterm.pl ([79.187.237.18]:59117 "EHLO apollo.newterm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752664AbaE0UbB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 May 2014 16:31:01 -0400
Content-Disposition: inline
In-Reply-To: <20140526212614.6e2610b0@endymion.delvare>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 26, 2014 at 09:26:14PM +0200, Jean Delvare wrote:
> The ec_bhf driver is specific to the Beckhoff CX5020, an embedded PC
> based on a 32-bit Intel Atom CPU. So we can add a dependency on
> X86_32, with COMPILE_TEST as an alternative to still allow for broader
> build-testing.
> 
> Signed-off-by: Jean Delvare <jdelvare@suse.de>
> Cc: Darek Marcinkiewicz <reksio@newterm.pl>
> Cc: David S. Miller <davem@davemloft.net>
> ---
>  drivers/net/ethernet/Kconfig |    1 +
>  1 file changed, 1 insertion(+)
> 
> --- linux-3.15-rc7.orig/drivers/net/ethernet/Kconfig	2014-05-26 09:24:00.555619955 +0200
> +++ linux-3.15-rc7/drivers/net/ethernet/Kconfig	2014-05-26 21:01:32.971410992 +0200
> @@ -39,6 +39,7 @@ source "drivers/net/ethernet/cisco/Kconf
>  config CX_ECAT
>  	tristate "Beckhoff CX5020 EtherCAT master support"
>  	depends on PCI
> +	depends on X86_32 || COMPILE_TEST
>  	---help---
>  	  Driver for EtherCAT master module located on CCAT FPGA
>  	  that can be found on Beckhoff CX5020, and possibly other of CX
> 
> 
It makes sense, just one more comment. It is pretty likely that
this driver also works with CX20** family of Beckhoff embedded PCs, which
have 64bit Intel iCore processor. Unfortunately, I haven't yet had a chance
to get my hands on any of those so cannot tell for sure. Maybe allowing
this driver also for x64 would be slightly better option?

-- 
DM
