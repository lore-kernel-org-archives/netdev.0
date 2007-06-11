From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 1/2] [RFC] NET: Implement a standard ndev_printk family
Date: Mon, 11 Jun 2007 14:52:36 -0700
Message-ID: <466DC424.7020909@intel.com>
References: <20070611213721.23014.4812.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, davem@davemloft.net,
	arjan@linux.intel.com, joe@perches.com,
	shemminger@linux-foundation.org
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:26949 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751418AbXFKVw6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jun 2007 17:52:58 -0400
In-Reply-To: <20070611213721.23014.4812.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> A lot of netdevices implement their own variant of printk and use
> use variations of dev_printk, printk or others that use msg_enable,
> which has been an eyesore with countless variations across drivers.

<snip>

> +#define ndev_err(netdev, level, format, arg...) \
> +	do { if ((netdev)->msg_enable & NETIF_MSG_##level) { \
> +		printk(KERN_ERR "%s: %s: " format, (netdev)->name, \
> +		(netdev)->dev.parent->bus_id, ## arg); } } while (0)

so now the only question is whether we want the ndev_printk() stuff to format as 
much as possible like dev_printk. dev_printk also prints dev_driver_string(dev), 
which is what above macro omits. To make this as much similar as possible, we
could do:

 > +#define ndev_err(netdev, level, format, arg...) \
 > +	do { if ((netdev)->msg_enable & NETIF_MSG_##level) { \
 > +		printk(KERN_ERR "%s: %s %s: " format, (netdev)->name, \
 > +		dev_driver_string(netdev)-dev), (netdev)->dev.parent->bus_id, \
 > +             ## arg); } } while (0)

it would (e.g. e1000) change the output from:
eth1: 0000:00:19.0: NIC Link is Down

To:
eth1: e1000 0000:00:19.0: NIC Link is Down

But I am unsure whether the addition of the driver name is useful at this point 
- most drivers already printk some sort of association out that can be used to 
track the bus_id/netdev name back to the driver easily.

So, hence I omitted doing this in this patch.

Auke
