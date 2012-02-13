From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: [BUG?] bonding, slave selection, carrier loss, etc.
Date: Mon, 13 Feb 2012 12:16:59 -0600
Message-ID: <4F39539B.5060507@genband.com>
References: <49CD5B93.7010407@nortel.com>	 <31087.1238198438@death.nxdomain.ibm.com> <4F35AC78.3010907@genband.com>	 <28766.1328925233@death.nxdomain> <1328986371.325.7.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>, andy@greyhouse.net,
	netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og113.obsmtp.com ([64.18.2.179]:52763 "EHLO
	exprod7og113.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755662Ab2BMSRY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2012 13:17:24 -0500
In-Reply-To: <1328986371.325.7.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/11/2012 12:52 PM, Ben Hutchings wrote:
> On Fri, 2012-02-10 at 17:53 -0800, Jay Vosburgh wrote:
>> Chris Friesen<chris.friesen@genband.com>  wrote:

>>> The best solution would be for bonding to just register for notification
>>> of the link going down.  Presumably most drivers should be doing that
>>> properly by now, and for devices that get interrupt-driven notification
>>> of link status changes this would allow the bonding code to react much
>>> quicker.
>>
>> 	A quick look at some drivers shows that at least acenic still
>> doesn't do netif_carrier_off, so converting entirely to a notifier-based
>> failover mechanism would break drivers that work today.
> [...]
>
> It might be worth having some sort of feature flag (in priv_flags) that
> indicates whether the driver updates the link state.  Alternately,
> disable polling of a device once you see a notification.

This makes a lot of sense to me...it is suboptimal to still be polling 
when most people that care about bonding reliability are going to be 
using ethernet hardware with interrupt-based link change notification.

Chris

-- 
Chris Friesen
Software Developer
GENBAND
chris.friesen@genband.com
www.genband.com
