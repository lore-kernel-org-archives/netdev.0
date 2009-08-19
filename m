From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ibm_newemac: emac_close() needs to call
 netif_carrier_off()
Date: Wed, 19 Aug 2009 14:34:03 -0700 (PDT)
Message-ID: <20090819.143403.27319428.davem@davemloft.net>
References: <20090819210000.D56AB254211@localhost>
	<20090819141136.74f5c266@s6510>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pgynther@google.com, benh@kernel.crashing.org,
	netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53642
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752349AbZHSVdv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2009 17:33:51 -0400
In-Reply-To: <20090819141136.74f5c266@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 19 Aug 2009 14:11:36 -0700

> On Wed, 19 Aug 2009 14:00:00 -0700 (PDT)
> Petri Gynther <pgynther@google.com> wrote:
> 
>> When ibm_newemac netdev instance is shutdown with "ifconfig down",
>> the netdev interface does not go properly down. netif_carrier_ok()
>> keeps returning TRUE even after "ifconfig down".
>> 
>> The problem can be seen when ibm_newemac instances are slaves of
>> a bonding interface. The bonding interface code uses netif_carrier_ok()
>> to determine the link status of its slaves. When ibm_newemac slave is
>> shutdown with "ifconfig down", the bonding interface won't detect any
>> link status change because netif_carrier_ok() keeps returning TRUE.
> 
> Bonding should be testing for netif_running() && netif_carrier_ok().
> 
> In many devices state of carrier is undefined when device is down.

But if you check all of the drivers, ethernet in particular, the
convention is to call netif_carrier_off() in foo_close().
