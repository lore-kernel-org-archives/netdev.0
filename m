From: David Daney <ddaney@caviumnetworks.com>
Subject: Re: [RFC] NAPI as kobject proposal
Date: Wed, 03 Feb 2010 13:38:45 -0800
Message-ID: <4B69ECE5.7060803@caviumnetworks.com>
References: <20100129101839.36944ba5@nehalam> <1265232216.2116.46.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.caviumnetworks.com ([209.113.159.134]:17683 "EHLO
	smtp2.caviumnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932657Ab0BCVy2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 16:54:28 -0500
In-Reply-To: <1265232216.2116.46.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> On Fri, 2010-01-29 at 10:18 -0800, Stephen Hemminger wrote:
>> The NAPI interface structure in current kernels is managed by the driver.
>> As part of receive packet steering there is a requirement to add an
>> additional parameter to this for the CPU map. And this map needs to
>> have an API to set it.
>>
>> The right way to do this in the kernel model is to make NAPI into
>> a kobject and associate it back with the network device (parent).
>> This isn't wildly difficult but does change some of the API for
>> network device drivers because:
>>   1. They need to handle another possible error on setup
>>   2. NAPI object needs to be dynamically allocated
>>      separately (not as part of netdev_priv)
>>   3. Driver should pass index that can be uses as part of
>>      name (easier than scanning)
>>
>> Eventually, there will be:
>>   /sys/class/net/eth0/napi0/
>>                             weight
>>                             cpumap
> 
> I think the NAPI objects should be created as children of a bus device
> and then linked from the net device directories, e.g.
> 
> /sys/devices/.../ net/eth0/
>                            napi0 -> ../../napi/napi0
>                       eth1/
>                            napi0 -> ../../napi/napi0
>                   napi/napi0/
>                              weight
>                              cpumap
> 

This seems right.

Some drivers have a single napi object logically associated with 
multiple interfaces.  Although the current architecture forces us to 
associate the napi object with a single net_device, it would be nice to 
move towards something that allows sharing a napi object between 
multiple devices.

David Daney
