From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ptp: increase the maximum number of clocks
Date: Sat, 23 Mar 2013 19:53:01 -0400 (EDT)
Message-ID: <20130323.195301.955074293040961923.davem@davemloft.net>
References: <d219aa87bd5b3e2fa42449720d845a7110f642f0.1363893841.git.jbenc@redhat.com>
	<20130321.172017.1499060411785395307.davem@davemloft.net>
	<20130323175915.GA3036@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jbenc@redhat.com, netdev@vger.kernel.org
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35416 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752457Ab3CWXxD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Mar 2013 19:53:03 -0400
In-Reply-To: <20130323175915.GA3036@netboy.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Sat, 23 Mar 2013 18:59:15 +0100

> On Thu, Mar 21, 2013 at 05:20:17PM -0400, David Miller wrote:
>> 
>> This really needs to be dynamic, and it shows what a bad idea it was
>> to use character drivers for this which introduces arbitrary device
>> arity limitations.
> 
> If a clock is not a character device, what then should it be? Network
> interface?  Block device?  sysfs apparition?
> 
> IIRC, the RTCs appear as char devices. In any case, we are better off
> with char devices than with an enumeration of SYSV clock IDs.

It should be an abstract device created/deleted/changed by netlink
operations.

Then there are no limitations.  PTP devices are then referened by
string names, rather than some bogus set of character device minor
numbers which have no meaning and have arbitrary limitations
wrt. arity.

If, in theory, we can have as many PTP devices as network devices,
we damn well better be able to create as many PTP devices as
network devices.

That means they must have the same capabilities as far as how many
of them you can create.
