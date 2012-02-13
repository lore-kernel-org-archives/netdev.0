From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: [BUG?] bonding, slave selection, carrier loss, etc.
Date: Mon, 13 Feb 2012 13:18:45 -0600
Message-ID: <4F396215.6080505@genband.com>
References: <49CD5B93.7010407@nortel.com>	<31087.1238198438@death.nxdomain.ibm.com>	<4F35AC78.3010907@genband.com>	<28766.1328925233@death.nxdomain>	<1328986371.325.7.camel@deadeye>	<4F39539B.5060507@genband.com> <20120213104810.158d714a@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Jay Vosburgh <fubar@us.ibm.com>, andy@greyhouse.net,
	netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og119.obsmtp.com ([64.18.2.16]:52003 "EHLO
	exprod7og119.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757656Ab2BMTUR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2012 14:20:17 -0500
In-Reply-To: <20120213104810.158d714a@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/13/2012 12:48 PM, Stephen Hemminger wrote:
> On Mon, 13 Feb 2012 12:16:59 -0600
> Chris Friesen<chris.friesen@genband.com>  wrote:
>
>> On 02/11/2012 12:52 PM, Ben Hutchings wrote:
>>> On Fri, 2012-02-10 at 17:53 -0800, Jay Vosburgh wrote:
>>>> Chris Friesen<chris.friesen@genband.com>   wrote:
>>
>>>>> The best solution would be for bonding to just register for notification
>>>>> of the link going down.  Presumably most drivers should be doing that
>>>>> properly by now, and for devices that get interrupt-driven notification
>>>>> of link status changes this would allow the bonding code to react much
>>>>> quicker.
>>>>
>>>> 	A quick look at some drivers shows that at least acenic still
>>>> doesn't do netif_carrier_off, so converting entirely to a notifier-based
>>>> failover mechanism would break drivers that work today.
>>> [...]
>>>
>>> It might be worth having some sort of feature flag (in priv_flags) that
>>> indicates whether the driver updates the link state.  Alternately,
>>> disable polling of a device once you see a notification.
>
> Just fix the drivers to update link state.
> The whole mii polling method of bonding is really leftover from the era of
> 10 years ago when network drivers were stupid and didn't handle carrier.

In the interest of getting the bonding driver fixed sooner rather than 
later, I'd prefer something that didn't require fixing up all the 
network drivers first.

Once all the drivers are fixed up (assuming people care enough about 
older drivers to do so) then we could remove the option and make it 
mandatory.

Chris

-- 
Chris Friesen
Software Developer
GENBAND
chris.friesen@genband.com
www.genband.com
