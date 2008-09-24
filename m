From: Trent Piepho <tpiepho@freescale.com>
Subject: Re: [PATCH 7/9] [ETH]: Start net device with carrier down
Date: Wed, 24 Sep 2008 15:43:55 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0809241534370.7680@t2.domain.actdsltmp>
References: <e665d9ff8b50796ce65c503604453056217bfc8a.1221537369.git.tpiepho@freescale.com>
 <ebb4b9e34a594b9ca0fda9042bfa12bff9e9fac2.1221537369.git.tpiepho@freescale.com>
 <20080924.152457.13104395.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org, Fleming Andy <afleming@freescale.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:64676 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752652AbYIXWqo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2008 18:46:44 -0400
In-Reply-To: <20080924.152457.13104395.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 24 Sep 2008, David Miller wrote:
> From: Trent Piepho <tpiepho@freescale.com>
> Date: Wed, 24 Sep 2008 14:20:55 -0700
>
>> The problem is that when the device is first created and opened, the state
>> bit indicating the carrier is down isn't set, i.e. the state is wrong.
>> When the carrier comes up for the first time no netlink event is sent,
>> since the device state indicated the carrier was already up.
>
> It works properly if the device driver does as it is supposed to,
> which is invoke netif_carrier_off() in it's ->open() method in this
> situation.
>
> Please fix the drivers where this is not happening.

I tried that first, but if the carrier is already up, opening the interface
generated extra rt-netlink messages for carrier down then carrier up, even
though the carrier was up all along.

But maybe I didn't have it at the right place in the open() method.  I'll try
Stephen's suggestion to put it after allocation but before register_netdev()
and see if the problem is still there.
