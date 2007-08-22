From: Kevin E <kevin360@yahoo.com>
Subject: Re: [RFT] sky2: yukon-ec-u phy power problems
Date: Wed, 22 Aug 2007 15:37:09 -0700 (PDT)
Message-ID: <314260.5533.qm@web38904.mail.mud.yahoo.com>
References: <20070821100713.2867dce3@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Willy Tarreau <w@1wt.eu>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web38904.mail.mud.yahoo.com ([209.191.125.110]:45608 "HELO
	web38904.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1763432AbXHVWhK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2007 18:37:10 -0400
In-Reply-To: <20070821100713.2867dce3@freepuppy.rosehill.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--- Stephen Hemminger
<shemminger@linux-foundation.org> wrote:

> The sky2 driver clears some bits in the PHY control
> register, that cause
> the PHY interface to get changed.  Some of these
> deal with voltage and power
> savings as well. This may explain some of the
> failures on Gigabyte DS-3 motherboard.
> 
> The clue to possible problem was looking at why
> loading/unloading sky2 would
> break vendor sk98lin driver (ie what registers
> changed).
> 
> 
> --- a/drivers/net/sky2.c	2007-08-21
> 09:53:41.000000000 -0700
> +++ b/drivers/net/sky2.c	2007-08-21
> 09:53:43.000000000 -0700
> @@ -696,8 +696,8 @@ static void sky2_mac_init(struct
> sky2_hw
>  	int i;
>  	const u8 *addr = hw->dev[port]->dev_addr;
>  
> -	sky2_write32(hw, SK_REG(port, GPHY_CTRL),
> GPC_RST_SET);
> -	sky2_write32(hw, SK_REG(port, GPHY_CTRL),
> GPC_RST_CLR);
> +	sky2_write8(hw, SK_REG(port, GPHY_CTRL),
> GPC_RST_SET);
> +	sky2_write8(hw, SK_REG(port, GPHY_CTRL),
> GPC_RST_CLR);
>  
>  	sky2_write8(hw, SK_REG(port, GMAC_CTRL),
> GMC_RST_CLR);
>  

This appears to have fixed the problem!  I made the
change to the kernel on the broken MB and the link
stayed up.  So I went ahead and made the change to the
kernel on the working one too.   Right now I'm using
netcat to saturate the link and make sure it stays up.
 So far it's looking good, if I have any problems I'll
let you know.

Thanks,
Kevin



       
____________________________________________________________________________________
Building a website is a piece of cake. Yahoo! Small Business gives you all the tools to get online.
http://smallbusiness.yahoo.com/webhosting 
