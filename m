From: David Miller <davem@davemloft.net>
Subject: Re: kernel BUG at drivers/net/phy/mdio_bus.c:165!
Date: Wed, 17 Dec 2008 00:24:34 -0800 (PST)
Message-ID: <20081217.002434.127189543.davem@davemloft.net>
References: <m3ej07zg85.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: buytenh@wantstofly.org, netdev@vger.kernel.org
To: khc@pm.waw.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42994
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751757AbYLQIYe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 03:24:34 -0500
In-Reply-To: <m3ej07zg85.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krzysztof Halasa <khc@pm.waw.pl>
Date: Wed, 17 Dec 2008 03:29:46 +0100

> kernel BUG at drivers/net/phy/mdio_bus.c:165!
> Unable to handle kernel NULL pointer dereference at virtual address 00000000
> 
> How?
> 
> mdiobus_alloc() sets bus->state = MDIOBUS_ALLOCATED.
> 
> mdiobus_register() sets bus->state = MDIOBUS_REGISTERED but then can
>    fail (mdiobus_scan()) returning an error to the caller.
> 
> The caller aborts correctly with mdiobus_free() which does:
>         if (bus->state == MDIOBUS_ALLOCATED) {
>                 kfree(bus);
>                 return;
>         }
> 
>         BUG_ON(bus->state != MDIOBUS_UNREGISTERED);
> 
> Signed-off-by: Krzysztof Halasa <khc@pm.waw.pl>

Looks great, applied.

Thanks for fixing this bug Krzysztof.
