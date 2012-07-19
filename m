From: Andrew Jackson <ajackson@solarflare.com>
Subject: Re: [PATCH net-next 4/7] sfc: Add support for IEEE-1588 PTP
Date: Thu, 19 Jul 2012 17:05:45 +0100
Message-ID: <50083059.7070700@solarflare.com>
References: <1342635392.2617.52.camel@bwh-desktop.uk.solarflarecom.com>  <1342635693.2617.56.camel@bwh-desktop.uk.solarflarecom.com>  <20120719142558.GB24484@localhost.localdomain> <1342708653.2617.33.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Richard Cochran <richardcochran@gmail.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-net-drivers@solarflare.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:22141 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751336Ab2GSQFw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 12:05:52 -0400
In-Reply-To: <1342708653.2617.33.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19/07/2012 15:37, Ben Hutchings wrote:
> On Thu, 2012-07-19 at 16:25 +0200, Richard Cochran wrote:
>> On Wed, Jul 18, 2012 at 07:21:33PM +0100, Ben Hutchings wrote:

>>> +/* Process times received from MC.
>>> + *
>>> + * Extract times from returned results, and establish the minimum value
>>> + * seen.  The minimum value represents the "best" possible time and events
>>> + * too much greater than this are rejected - the machine is, perhaps, too
>>> + * busy. A number of readings are taken so that, hopefully, at least one good
>>> + * synchronisation will be seen in the results.
>>> + */
>>
>> This code looks like it is trying to find the offset between two
>> clocks. Is there some reason why you cannot use <linux/timecompare.h>
>> to accomplish this?
>>
>> Also, these comments about "hopefull" synchronization make me
>> nervous. I think it might be easier just to offer RAW timestamps and
>> forget about the SYS timestamps.
>>
>> I am trying to purge the whole SYS thing (only blackfin is left)
>> because there is a much better way to go about this, namely
>> synchronizing the system time to the PHC time via an internal PPS
>> signal.
>
> Andrew, would that work for us?

I don't think so for the reason that Stu has pointed out (failed 
assumption).

The NIC's clock isn't directly accessible by the host from the PCIe bus 
and is "behind" the MC. Even when we process PPS events, we need a 
reliable way of determining the relationship between the two clocks 
(system <> NIC). We're trying to get that as accurately as we can but we 
know that some measurements will be incorrect/out of bounds because of 
loading on the system.

In retrospect, I should have phrased the comment in more statistical 
terms rather than using ambiguous phrases like "hopefully".

	Andrew
