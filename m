From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: meth: Some code cleanups for meth
Date: Sat, 17 Dec 2011 22:00:32 -0500 (EST)
Message-ID: <20111217.220032.683061606470374131.davem@davemloft.net>
References: <4EED418E.40501@gentoo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org
To: kumba@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41532 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751180Ab1LRDAn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Dec 2011 22:00:43 -0500
In-Reply-To: <4EED418E.40501@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joshua Kinard <kumba@gentoo.org>
Date: Sat, 17 Dec 2011 20:27:42 -0500

> -#define WAIT_FOR_PHY(___rval)					\
> -	while ((___rval = mace->eth.phy_data) & MDIO_BUSY) {	\
> -		udelay(25);					\
> +#define WAIT_FOR_PHY(___rval)                               \
> +	while ((___rval = mace->eth.phy_data) & MDIO_BUSY) {    \
> +		udelay(25);                                         \

I think using tabs at the end of the line to line up the "\" is much
better than what you're changing it to, that being spaces.

> -		priv->phy_addr=i;
> -		p2=mdio_read(priv,2);
> -		p3=mdio_read(priv,3);
> +
> +	for (i = 0; i < 32; i++){
> +		priv->phy_addr = i;
> +		p2 = mdio_read(priv,2);
> +		p3 = mdio_read(priv,3);

If you're going to put forth the effort to put spaces around the
"=" characters, fix up the arguments to mdio_read() as well, there
needs to be a space after the "," and right before the second
argument.

> +		if ((p2 != 0xffff) && (p2 != 0x0000)) {

There is no need for the new parenthesis you are adding here.  It
doesn't change things semantically, and it does not improve
readability, it just makes for more characters a human has to parse in
his mind.

> - * Copyright (C) 2001 Alessandro Rubini and Jonathan Corbet
> - * Copyright (C) 2001 O'Reilly & Associates
> + * Copyright (C) 2001-2003 Ilya Volynets
> + * Copyright (C) 2011 Joshua Kinard
>   *
> - * The source code in this file can be freely used, adapted,
> - * and redistributed in source or binary form, so long as an
> - * acknowledgment appears in derived source files.  The citation
> - * should list that the code comes from the book "Linux Device
> - * Drivers" by Alessandro Rubini and Jonathan Corbet, published
> - * by O'Reilly & Associates.   No warranty is attached;
> - * we cannot take responsibility for errors or fitness for use.
> + *	This program is free software; you can redistribute it and/or
> + *	modify it under the terms of the GNU General Public License
> + *	as published by the Free Software Foundation; either version
> + *	2 of the License, or (at your option) any later version.
>   */

I'm not sure at all that you have the ability to make this kind of
change to the copyright and attributions here.

There are probably a lot more problems with this patch, but I'm
exhausted look at this stuff as-is.
