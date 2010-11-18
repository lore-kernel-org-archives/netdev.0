From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [RFC PATCH v1 1/2] net: implement mechanism for HW based QOS
Date: Thu, 18 Nov 2010 09:31:09 -0800
Message-ID: <4CE562DD.8060904@intel.com>
References: <20101117051544.19800.97654.stgit@jf-dev1-dcblab> <20101117091828.GA14773@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, nhorman@tuxdriver.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:2873 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755489Ab0KRRbL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Nov 2010 12:31:11 -0500
In-Reply-To: <20101117091828.GA14773@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/17/2010 1:18 AM, Thomas Graf wrote:
> On Tue, Nov 16, 2010 at 09:15:45PM -0800, John Fastabend wrote:
>> This patch provides a mechanism for lower layer devices to
>> steer traffic using skb->priority to tx queues. This allows
>> for hardware based QOS schemes to use the default qdisc without
>> incurring the penalties related to global state and the qdisc
>> lock. While reliably receiving skbs on the correct tx ring
>> to avoid head of line blocking resulting from shuffling in
>> the LLD. Finally, all the goodness from txq caching and xps/rps
>> can still be leveraged.
> 
> Nice.
> 
>> If this approach seems reasonable I'll go ahead and finish
>> this up. The priority to tc mapping should probably be exposed
>> to userspace either through sysfs or rtnetlink. Any thoughts?
> 
> Please use netlink for this and add a new IFLA_ attribute. I
> suggest you put nested attributes into it so you can extend it
> later on and/or obsolete attributes:
> 
> [IFLA_TC] = {
>   [IFLA_TC_MAX_TCS]
>   [IFLA_TC_NUM_TCS]
>   [IFLA_TC_TXQCOUNT]
>   [IFLA_TC_TXQOFFSET]
>   [IFLA_TC_MAP]
> }
> 
> Or whatever is reasonable to export to userspace.

Sounds good. I'll do this and post an update.

Thanks,
John.

