From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] driver: net: smsc911x: set NOCARRIER flag in
 driver initialization
Date: Tue, 03 Jun 2014 15:24:49 -0700 (PDT)
Message-ID: <20140603.152449.715925744030919276.davem@davemloft.net>
References: <CAHPKR9KmDSgC9EstJLfhqY9SB462OSJhQCEPS7Ka=VvnqbH6iQ@mail.gmail.com>
	<20140530.134245.1805237850303710369.davem@davemloft.net>
	<CAHPKR9+H1gmJBqtO-4c7YBQrx+xbLenzWE6sky9Pq7=yF4bHUw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@shawell.net, netdev@vger.kernel.org
To: kumaran.4353@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49508 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965166AbaFCWYv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 18:24:51 -0400
In-Reply-To: <CAHPKR9+H1gmJBqtO-4c7YBQrx+xbLenzWE6sky9Pq7=yF4bHUw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Balakumaran Kannan <kumaran.4353@gmail.com>
Date: Tue, 3 Jun 2014 19:45:39 +0530

> On Sat, May 31, 2014 at 2:12 AM, David Miller <davem@davemloft.net> wrote:
>> From: Balakumaran Kannan <kumaran.4353@gmail.com>
>> Date: Fri, 30 May 2014 18:35:43 +0530
>>
>>> All these drivers call netif_carrier_off function after registering
>>> the network device using register_netdev.
>>
>> I can quote more counter-examples than your list, starting with the
>> Broadcom tg3 driver.
> 
> Thank you David for this information. I'll send updated patch as version-2.
> 
> Still I couldn't understand the reason behind this. I should be grateful if you
> would explain me little bit.

At the moment you call register_netdev() the device is visible, notifications
are sent to userspace, and userland tools can try to bring the interface up
and see the incorrect link state, before you do the netif_carrier_off().

Said another way, between the register_netdev() and netif_carrier_off() call,
userspace can see the device in an inconsistent state.
