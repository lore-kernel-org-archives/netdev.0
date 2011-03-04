From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH 1/2 net-next][v2] bonding: fix incorrect transmit queue offset
Date: Fri, 04 Mar 2011 09:37:51 -0800
Message-ID: <18279.1299260271@death>
References: <20110223230844.GA16476@linuxace.com> <20110223.151357.245408084.davem@davemloft.net> <1298504269.2211.503.camel@localhost> <20110223.155451.70202591.davem@davemloft.net> <20110225225636.GA18792@linuxace.com> <20110301153135.GL11864@gospo.rdu.redhat.com> <20110302014009.GA2045@linuxace.com>
Cc: Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	netdev@vger.kernel.org
To: Phil Oester <kernel@linuxace.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:35361 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752121Ab1CDRh6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2011 12:37:58 -0500
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e39.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p24HP8ss030950
	for <netdev@vger.kernel.org>; Fri, 4 Mar 2011 10:25:08 -0700
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p24HbsYZ125236
	for <netdev@vger.kernel.org>; Fri, 4 Mar 2011 10:37:54 -0700
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p24HgaRn018016
	for <netdev@vger.kernel.org>; Fri, 4 Mar 2011 10:42:37 -0700
In-reply-to: <20110302014009.GA2045@linuxace.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Phil Oester <kernel@linuxace.com> wrote:

>On Tue, Mar 01, 2011 at 10:31:36AM -0500, Andy Gospodarek wrote:
>> > The patch works as expected.  Do we have any agreement on a final version?
>> >
>>
>> Thanks for the testing, Phil.
>>
>> I'm in favor of this patch as it does alert the admin that bonding may
>> not have enough default queues, but it is not as verbose (backtrace et
>> al) and likely to create bug reports as a message from WARN_ON.
>> +             if (net_ratelimit())
>> +                     pr_warning("%s selects invalid tx queue %d.  Consider"
>> +                                " setting module option tx_queues > %d.",
>> +                                dev->name, txq, dev->real_num_tx_queues);
>
>It is unclear why we need to alert the admin to this situation (repeatedly).  
>Say the incoming nic has 32 queues, and is headed out a bond (with 16).
>With your patch, we will log 50% of the time, no?  What benefit is this
>log spew?
>
>While WARN_ONCE may be a bit extreme due to the backtrace, perhaps we
>should at least throw a 'static bool warned' variable in there to lessen
>the nuisance?

	I'm also concerned that the log messages will be excessive.

	Should we instead create a bonding driver-private ethtool
statistics and count these events that way?

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
