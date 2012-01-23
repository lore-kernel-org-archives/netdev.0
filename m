From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH 1/1] dsa: Add reporting of silicon revision for Marvell
 88E6123/88E6161/88E6165 switches.
Date: Mon, 23 Jan 2012 10:48:10 +0100
Message-ID: <4F1D2CDA.9050107@openwrt.org>
References: <1327303254-28573-1-git-send-email-cphealy@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <ben@decadent.org.uk>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	netdev@vger.kernel.org
To: Chris Healy <cphealy@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:34636 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752931Ab2AWJs3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2012 04:48:29 -0500
Received: by wics10 with SMTP id s10so1938759wic.19
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2012 01:48:28 -0800 (PST)
In-Reply-To: <1327303254-28573-1-git-send-email-cphealy@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On 01/23/12 08:20, Chris Healy wrote:
> Add reporting of silicon revision during the probe function for Marvell 88E6123/88E6161/88E6165 switches.
>
> Signed-off-by: Chris Healy<cphealy@gmail.com>
> ---
>   drivers/net/dsa/mv88e6123_61_65.c |   21 +++++++++++++++++----
>   1 files changed, 17 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/dsa/mv88e6123_61_65.c b/drivers/net/dsa/mv88e6123_61_65.c
> index c0a458f..6f23c95 100644
> --- a/drivers/net/dsa/mv88e6123_61_65.c
> +++ b/drivers/net/dsa/mv88e6123_61_65.c
> @@ -20,12 +20,25 @@ static char *mv88e6123_61_65_probe(struct mii_bus *bus, int sw_addr)
>
>   	ret = __mv88e6xxx_reg_read(bus, sw_addr, REG_PORT(0), 0x03);
>   	if (ret>= 0) {
> -		ret&= 0xfff0;
> -		if (ret == 0x1210)
> +		if (ret == 0x1212)
> +			return "Marvell 88E6123 (A1)";
> +		if (ret == 0x1213)
> +			return "Marvell 88E6123 (A2)";
> +		if ((ret&  0xfff0) == 0x1210)
>   			return "Marvell 88E6123";
> -		if (ret == 0x1610)
> +
> +		if (ret == 0x1612)
> +			return "Marvell 88E6161 (A1)";
> +		if (ret == 0x1613)
> +			return "Marvell 88E6161 (A2)";
> +		if ((ret&  0xfff0) == 0x1610)
>   			return "Marvell 88E6161";
> -		if (ret == 0x1650)
> +
> +		if (ret == 0x1652)
> +			return "Marvell 88E6165 (A1)";
> +		if (ret == 0x1653)
> +			return "Marvell 88e6165 (A2)";
> +		if ((ret&  0xfff0) == 0x1650)
>   			return "Marvell 88E6165";
>   	}

What about a switch/case here?
--
Florian
