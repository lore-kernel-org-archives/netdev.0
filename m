From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 08/14] pktgen: reorganize transmit loop
Date: Fri, 28 Aug 2009 09:01:04 -0700
Message-ID: <4A97FF40.70804@candelatech.com>
References: <20090827235506.624381734@vyatta.com> <20090827235705.740919364@vyatta.com> <4A975480.3080507@candelatech.com> <20090827224902.49f80920@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Robert Olsson <robert.olsson@its.uu.se>,
	netdev@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:48872 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750761AbZH1QB3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2009 12:01:29 -0400
In-Reply-To: <20090827224902.49f80920@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/27/2009 10:49 PM, Stephen Hemminger wrote:
> On Thu, 27 Aug 2009 20:52:32 -0700
> Ben Greear<greearb@candelatech.com>  wrote:
>
>> +		default: /* Drivers are not supposed to return other
>> values! */
>> +			if (net_ratelimit())
>> +				pr_info("pktgen: %s xmit error:
>> %d\n",
>> +					odev->name, ret);
>>   			pkt_dev->errors++;
>>
>> I believe this is faulty.  Things like vlans can send pkts to qdiscs
>> of the underlying device and those can return other values.
>>
>> Patric McHardy put in some patches recently to achieve this in a more
>> uniform manner:
>>
>> http://patchwork.ozlabs.org/patch/28340/
>>
>> Thanks,
>> Ben
>>
>
> Since pktgen has its own way of generating vlan tags, it
> makes no sense to use it on top of 8021q vlan driver.

Maybe someone wants to test their virtual device driver using pktgen?

Or generate traffic with lots of different vlan IDs & associated
IP, mac-addresses, etc?

Same issue applies to mac-vlans and possibly other virtual devices.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

