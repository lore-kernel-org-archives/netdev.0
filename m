From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next/-mm/mainline] net/hp-plus: fix link errors
Date: Tue, 25 Nov 2008 13:41:45 -0800 (PST)
Message-ID: <20081125.134145.66227024.davem@davemloft.net>
References: <20081121.163335.255948683.davem@davemloft.net>
	<20081125095952.f25e8286.randy.dunlap@oracle.com>
	<20081125181800.7502d395@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: randy.dunlap@oracle.com, netdev@vger.kernel.org, jgarzik@pobox.com,
	akpm@linux-foundation.org, shemminger@vyatta.com
To: alan@lxorguk.ukuu.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40017
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753891AbYKYVlp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 16:41:45 -0500
In-Reply-To: <20081125181800.7502d395@lxorguk.ukuu.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Date: Tue, 25 Nov 2008 18:18:00 +0000

> > WARNING: drivers/net/8390p: 'ei_set_multicast_list' exported twice. Previous export was in drivers/net/8390.ko
> > WARNING: drivers/net/8390p: 'ei_get_stats' exported twice. Previous export was in drivers/net/8390.ko
> > WARNING: drivers/net/8390p: 'ei_start_xmit' exported twice. Previous export was in drivers/net/8390.ko
> > WARNING: drivers/net/8390p: 'ei_tx_timeout' exported twice. Previous export was in drivers/net/8390.ko
> 
> bash-3.2$ grep ei_set_multicast drivers/net/*c
> bash-3.2$ grep ei_set_multicast  drivers/net/*h
> bash-3.2$ grep ei_set_multicast  include/linux/*h
> bash-3.2$ 

Wrong tree.

We added code that splits the struct netdev function pointers out into
a seperate structure.  In order to make initialization of the
netdev_ops members work inside of the driver (and keep it const), we
exported some of these 8390 library symbols.

Anyways, Stephen you have to do something about this.
