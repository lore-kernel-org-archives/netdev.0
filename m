From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 1/2] [RFC] NET: Implement a standard ndev_printk family
Date: Mon, 11 Jun 2007 10:30:26 -0700
Message-ID: <466D86B2.8070504@intel.com>
References: <20070608220007.31573.14931.stgit@localhost.localdomain>	<20070608162415.1481dfec@localhost.localdomain>	<4669E967.5030708@intel.com> <20070608171040.2b4a2dd7@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, davem@davemloft.net,
	arjan@linux.intel.com
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:65088 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751014AbXFKRa5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jun 2007 13:30:57 -0400
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
> 
> My preference would be something more like dev_printk or even use that?
> You want to show both device name, and physical attachment in the message.

yes, agreed, but currently netdev->dev->bus_id is bluntly overwritten by 
net-sysfs.c making this not trivial:

+471:        strlcpy(dev->bus_id, net->name, BUS_ID_SIZE);

so now netdev->dev->bus_id contains eth%d as well. I vaguely remember that there 
is another way to get the bus_id back, so I can likely work around it, but this 
particular overwriting of information is a BUG imo, and should be fixed.

Auke
