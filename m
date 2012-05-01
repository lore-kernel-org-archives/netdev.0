From: Ben Greear <greearb@candelatech.com>
Subject: Re: [net-next v2 6/8] ixgbe: add syfs interface for to export read
 only driver information
Date: Tue, 01 May 2012 07:30:55 -0700
Message-ID: <4F9FF39F.7080205@candelatech.com>
References: <1335862269-28914-1-git-send-email-jeffrey.t.kirsher@intel.com> <1335862269-28914-7-git-send-email-jeffrey.t.kirsher@intel.com> <20120501.100241.1409452912879198250.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, donald.c.skidmore@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	bhutchings@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:50665 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753045Ab2EAObE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2012 10:31:04 -0400
In-Reply-To: <20120501.100241.1409452912879198250.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/01/2012 07:02 AM, David Miller wrote:
> From: Jeff Kirsher<jeffrey.t.kirsher@intel.com>
> Date: Tue,  1 May 2012 01:51:07 -0700
>
>> From: Don Skidmore<donald.c.skidmore@intel.com>
>>
>> This patch exports non-thermal (which was done via hwmon in an earlier
>> patch) data to sysfs which isn't readily available elsewhere.  All of the
>> fields are read only as this interface is to only export driver data.
>>
>> Signed-off-by: Don Skidmore<donald.c.skidmore@intel.com>
>> Tested-by: Stephen Ko<stephen.s.ko@intel.com>
>> Signed-off-by: Jeff Kirsher<jeffrey.t.kirsher@intel.com>
>
> I don't like it.
>
> Some of this stuff is generic and belongs somewhere like ethtool, for
> example the descriptor sizes and queue sizes.
>
> The others are reading registers, and we have an ethtool API for that
> already.
>
> But putting anything like this in sysfs is pointless, because the
> stuff that other cards have too will then go into differently named
> sysfs files which, as is oft repeated here, is a terrible user
> experience.
>
> If you want to do this right, add a new ethtool interface that allows
> the publication of card specific unchanging values, in a style like
> what we already do for statistics.  Have one query that gets the
> string list, and then another which fetches the actual values.

And if you decide to go forward with this, I have some ideas for API
and would like to discuss it.  Or, if I beat you to it, I'll post some
RFC patches when I get a chance to write them up.

Basically, I'm thinking of a get-strings(flags), get-types(flags), and get-values(flags)
API.  The types would return an array of enums that would define the data
type, like uint32, int8, etc.  Strings would be same as it is today,
just with a new type.  Values would return array of uint64 as it does now.

To each method you could specify a uint32 flags that would be device specific.
I would like to use flags in wifi to specify whether to get the underlying NIC
stats v/s just the soft-device stats, for instance.  And maybe some additional
granularity if some stats are more costly to get than others so that one could
probe expensive stats more rarely....

And while strings would still be free-form, we could at least attempt to use
the same strings for the same kinds of stats where possible.

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
