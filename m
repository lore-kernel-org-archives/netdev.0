From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] ipconfig wait for carrier
Date: Thu, 19 May 2011 15:35:07 -0400 (EDT)
Message-ID: <20110519.153507.578609630787612821.davem@davemloft.net>
References: <20110518.181427.1228926976939865196.davem@davemloft.net>
	<1305819120.3271.3.camel@dcbw.foobar.com>
	<4DD56E7A.3010901@neli.hopto.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dcbw@redhat.com, netdev@vger.kernel.org
To: micha@neli.hopto.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52438 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933808Ab1ESTfN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 15:35:13 -0400
In-Reply-To: <4DD56E7A.3010901@neli.hopto.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Micha Nelissen <micha@neli.hopto.org>
Date: Thu, 19 May 2011 21:24:42 +0200

> Dan Williams wrote:
>> Shouldn't the code still wait at *least* one second?  Not all drivers
>> support carrier detect, and those that don't set the carrier always-on.
>> Thus older devices that used to have 1s to get carrier in line (even if
>> they don't report it) now have only 10ms.
> 
> Btw, it does not matter much, there are 2 cases:
> 1) DHCP: dhcp will retry every few seconds, so if link is not up, then a
> later try will succeed
> 2) Static IP: an ARP request is performed every second, so the second
> request will be answered instead of the first.
> 
> Even if link is "fake up" by driver and not actually up after 10 msecs,
> things will continue to work (eventually), after a second, just like now.

But this eats one of the CONF_SEND_RETRIES attempts, which is only 6.
