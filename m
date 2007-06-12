From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] [RFC -v3] NET: Implement a standard ndev_printk family
Date: Tue, 12 Jun 2007 11:37:26 -0700
Message-ID: <466EE7E6.40100@intel.com>
References: <20070612004009.1545.12076.stgit@localhost.localdomain> <1181667121.6020.56.camel@localhost> <466ED3B3.1080300@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	davem@davemloft.net, arjan@linux.intel.com,
	shemminger@linux-foundation.org, randy.dunlap@oracle.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:14979 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755503AbXFLSh2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jun 2007 14:37:28 -0400
In-Reply-To: <466ED3B3.1080300@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Joe Perches wrote:
>> On Mon, 2007-06-11 at 17:40 -0700, Auke Kok wrote:
>>> +#define ndev_err(netdev, level, format, arg...) \
>>> +	do { \
>>> +		struct net_device *__nd = (netdev); \
>>> +		if ((__nd)->msg_enable & NETIF_MSG_##level) \
>>> +			printk(KERN_ERR "%s: %s: " format, (__nd)->name, \
>>> +				(__nd)->dev.parent->bus_id, ## arg); \
>>> +	} while (0)
>>> +
>> I think it's better to remove the macro concatenation/obfuscation
>> of the NETIF_MSG_##level argument and simply pass the appropriate
>> NETIF_MSG_<type> directly to these ndev_<level> calls.
>>
>> It would also simplify the more than 300 calls in drivers/net of
>>
>> 	if (netif_msg_<type>(ptr))
>> 		printk(foo)
>>
>> to
>>
>> 	ndev_<level>(netdev, NETIF_MSG_<type>, fmt, args)
> 
> I think this is a whole lot of iteration and effort for a non-problem.

Why do you say that? What is your motivation for that statement? Can you be a 
bit more descriptive/constructive?

I have often seen comments on drivers adding new printk's and lots of them 
completely ignore the msg_enable bits while advertising that they do thought 
some debug/ethtool way. tg3, sky2, r8169, etc... all advertise that they allow 
setting/changing msg_enable yet don't actually do _anything_ with the bits.

Only 3 other driver besides the ones I've patched get it right....

How is that a non-problem?
