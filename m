From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sysfs: add entry to indicate network
 interfaces with random MAC address
Date: Wed, 21 Jul 2010 10:32:49 -0700 (PDT)
Message-ID: <20100721.103249.107094774.davem@davemloft.net>
References: <20100721150732.GR7497@gospo.rdu.redhat.com>
	<201007210934.27986.leedom@chelsio.com>
	<20100721102816.4bef5ada@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: leedom@chelsio.com, andy@greyhouse.net, harald@redhat.com,
	bhutchings@solarflare.com, sassmann@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	gospo@redhat.com, gregory.v.rose@intel.com,
	alexander.h.duyck@intel.com
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52588
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755613Ab0GURcd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jul 2010 13:32:33 -0400
In-Reply-To: <20100721102816.4bef5ada@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 21 Jul 2010 10:28:16 -0700

> IMHO no local assigned address should be used by udev. The cxgb4 driver
> should be using random value.
> 
> Does anyone have an example of locally assigned address that has persistence
> so that udev could use it.

The cxgb4 vf addresses are not random because they are fetched from the
card's NVRAM/EEPROM/firmware/whatever and thus are persistent.

We definitely want udev to use persistent rules for them.

This whole issue only exists because of the Intel VF case, where it
lacks persistent addresses but somehow we want to assign persistent
names to it's VF interfaces.

One idea I've proposed in other discussions about this is that if the
address is not persistent (either via the MAC address bit or the sysfs
value we're thinking of providing here) we use the device's geographic
location ("device path") as the key for udev stuff.
