From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ifb error path loop fix
Date: Mon, 01 Jan 2007 23:51:32 -0800 (PST)
Message-ID: <20070101.235132.85409619.davem@davemloft.net>
References: <200701020055.51805.m.kozlowski@tuxland.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org, jeff@garzik.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36925
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932947AbXABHvd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jan 2007 02:51:33 -0500
To: m.kozlowski@tuxland.pl
In-Reply-To: <200701020055.51805.m.kozlowski@tuxland.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Date: Tue, 2 Jan 2007 00:55:51 +0100

> On error we should start freeing resources at [i-1] not [i-2].
> 
> Signed-off-by: Mariusz Kozlowski <m.kozlowski@tuxland.pl>

Patch applied, thanks Mariusz.

> diff -upr linux-2.6.20-rc2-mm1-a/drivers/net/ifb.c linux-2.6.20-rc2-mm1-b/drivers/net/ifb.c
> --- linux-2.6.20-rc2-mm1-a/drivers/net/ifb.c	2006-12-24 05:00:32.000000000 +0100
> +++ linux-2.6.20-rc2-mm1-b/drivers/net/ifb.c	2007-01-02 00:25:34.000000000 +0100
> @@ -271,8 +271,7 @@ static int __init ifb_init_module(void)
>  	for (i = 0; i < numifbs && !err; i++)
>  		err = ifb_init_one(i);
>  	if (err) {
> -		i--;
> -		while (--i >= 0)
> +		while (i--)
>  			ifb_free_one(i);
>  	}

One could argue from a defensive programming perspective that
this bug comes from the fact that the ifb_init_one() loop
advances state before checking for errors ('i' is advanced before
the 'err' check due to the loop construct), and that's why the
error recovery code had to be coded specially :-)

Anyways, your fix is of course fine and I've applied it.
