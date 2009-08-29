From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 08/14] pktgen: reorganize transmit loop
Date: Fri, 28 Aug 2009 23:04:28 -0700 (PDT)
Message-ID: <20090828.230428.211927371.davem@davemloft.net>
References: <20090827235705.740919364@vyatta.com>
	<4A975480.3080507@candelatech.com>
	<20090827224902.49f80920@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, robert.olsson@its.uu.se,
	netdev@vger.kernel.org, tglx@linutronix.de
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35050
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751694AbZH2GEO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2009 02:04:14 -0400
In-Reply-To: <20090827224902.49f80920@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 27 Aug 2009 22:49:02 -0700

> On Thu, 27 Aug 2009 20:52:32 -0700
> Ben Greear <greearb@candelatech.com> wrote:
> 
>> +		default: /* Drivers are not supposed to return other
>> values! */
>> +			if (net_ratelimit())
>> +				pr_info("pktgen: %s xmit error:
>> %d\n",
>> +					odev->name, ret);
>>  			pkt_dev->errors++;
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

I think Patrick's goals are quite sound, and with his patch we
could let pktgen transmit over vlan just like any other device.

Otherwise we give no way to use pktgen to test the VLAN transmit path.
