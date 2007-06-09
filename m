From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 1/2] [RFC] NET: Implement a standard ndev_printk family
Date: Fri, 08 Jun 2007 20:18:24 -0700
Message-ID: <466A1C00.9080909@intel.com>
References: <20070608220007.31573.14931.stgit@localhost.localdomain>	<20070608162415.1481dfec@localhost.localdomain>	<4669E967.5030708@intel.com> <20070608171040.2b4a2dd7@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>, netdev@vger.kernel.org,
	jeff@garzik.org, davem@davemloft.net, arjan@linux.intel.com
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:62336 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750699AbXFIDS0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jun 2007 23:18:26 -0400
In-Reply-To: <20070608171040.2b4a2dd7@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Fri, 08 Jun 2007 16:42:31 -0700
> "Kok, Auke" <auke-jan.h.kok@intel.com> wrote:
> 
>> Stephen Hemminger wrote:
>>>>  
>>>> +#define ndev_printk(kern_level, netif_level, netdev, format, arg...) \
>>>> +	do { if ((netdev)->msg_enable & NETIF_MSG_##netif_level) { \
>>>> +		printk(kern_level "%s: " format, \
>>>> +		(netdev)->name, ## arg); } } while (0)
>>> Could you make a version that doesn't evaluate the arguments twice?
>> hmm you lost me there a bit; Do you want me to duplicate this code for all the 
>> ndev_err/ndev_info functions instead so that ndev_err doesn't direct back to 
>> ndev_printk?
> 
> It is good practice in a macro to avoid potential problems with usage
> by only touching the arguments once. Otherwise, something (bogus) like
> 	ndev_printk(KERN_DEBUG, NETIF_MSG_PKTDATA, "got %d\n",
> 		    dev++, skb->len)
> would increment dev twice.
> 
> My preference would be something more like dev_printk or even use that?

... see other reply

> You want to show both device name, and physical attachment in the message.

OK, that does make sense, and here it gets interesting and we can get creative, 
since for NETIF_MSG_HW and NETIF_MSG_PROBE messages we could add the printout of 
netdev->dev->bus_id. I have modeled and toyed around with the message format and 
did this (add bus_id to all messages) but it got messy (for LINK messages it's 
totally not needed).

However, that is going to make the macro's a bit more complex, and unlikely that 
I can make it fit without double-pass evaluation without making it a monster...

unless everyone agrees to just printing everything: both netdev->name and 
netdev->dev->bus_id for every message

Auke
