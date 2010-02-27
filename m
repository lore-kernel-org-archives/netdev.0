From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/7] cxgb4: Add packet queues and packet DMA code
Date: Sat, 27 Feb 2010 01:46:18 -0800 (PST)
Message-ID: <20100227.014618.193735140.davem@davemloft.net>
References: <1267227339-8076-4-git-send-email-dm@chelsio.com>
	<1267227339-8076-5-git-send-email-dm@chelsio.com>
	<20100226155756.09c0485c@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dm@chelsio.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38632
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S968061Ab0B0JqD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2010 04:46:03 -0500
In-Reply-To: <20100226155756.09c0485c@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 26 Feb 2010 15:57:56 -0800

> On Fri, 26 Feb 2010 15:35:36 -0800
> Dimitris Michailidis <dm@chelsio.com> wrote:
> 
>> +
>> +/**
>> + *	need_skb_unmap - does the platform need unmapping of sk_buffs?
>> + *
>> + *	Returns true if the platfrom needs sk_buff unmapping.  The compiler
>> + *	optimizes away unecessary code if this returns true.
>> + */
>> +static inline int need_skb_unmap(void)
>> +{
>> +	/*
>> +	 * This structure is used to tell if the platfrom needs buffer
>> +	 * unmapping by checking if DECLARE_PCI_UNMAP_ADDR defines anything.
>> +	 */
>> +	struct dummy {
>> +		DECLARE_PCI_UNMAP_ADDR(addr);
>> +	};
>> +
>> +	return sizeof(struct dummy) != 0;
>> +}
>> +
> 
> I would prefer one code path and let the compiler decide if unmap
> should be nop; rather than this kind of trick code.

Agreed, this is rediculious.  And there is currently no platform that
matters where this will trigger.

With IOMMUs and even the swiommu layer, even bog standard x86 systems
need the unmap addresses.

Therefore optimizing this is totally unreasonable.  Just use the provided
APIs and let the compiler and the platform defines do the work.

I'm amazed at how people do stuff like this.  If it's a reasonable
opimization, maybe, JUST MAYBE, it's better to optimize it generically
so that every driver gets the benefit NOT JUST YOUR individual driver.

