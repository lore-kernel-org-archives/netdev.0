From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH]: Third (final?) release of Sun Neptune driver
Date: Fri, 05 Oct 2007 19:31:39 -0400
Message-ID: <4706C95B.6080808@garzik.org>
References: <20071005.031209.57156822.davem@davemloft.net>	<20071005083556.7076dd43@freepuppy.rosehill> <20071005.155448.64007750.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	Ariel.Hendel@sun.com, greg.onufer@sun.com,
	Ashley.Saulsbury@sun.com, Matheos.Worku@sun.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59358 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761393AbXJEXbq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Oct 2007 19:31:46 -0400
In-Reply-To: <20071005.155448.64007750.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Stephen Hemminger <shemminger@linux-foundation.org>
> Date: Fri, 5 Oct 2007 08:35:56 -0700
> 
>> pr_info() ?
> 
> All corrected, thanks!
> 
>>From 11aaa8adc8e9141a440faaa3260ad5922c71eeda Mon Sep 17 00:00:00 2001
> From: David S. Miller <davem@sunset.davemloft.net>
> Date: Fri, 5 Oct 2007 15:53:21 -0700
> Subject: [PATCH] [NIU]: Use pr_info().
> 
> Suggested by Stephen Hemminger.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  drivers/net/niu.c |   78 ++++++++++++++++++++++++++--------------------------
>  1 files changed, 39 insertions(+), 39 deletions(-)

ACK

however long term, I would tend to prefer that we utilize the embedded 
struct device we have, which seems to be the way things are moving long 
term.

	struct net_device *ndev = ...;
	struct nic_private *np = netdev_priv(ndev);

	dev_printk(KERN_INFO, &ndev->dev,
		   "we all live in a %s submarine, "
		   "a %s submarine\n",
		   np->color ? "yellow" : "silly");

I say "long term" because we want netdev->dev.bus_id to match the 
net_device->name[], and it may not at this point (needs 
research/verification).


[as an aside...]  If the message isn't directly related to a net_device, 
you should go ahead and use

	struct pci_dev *pdev = ...;

	dev_printk(KERN_INFO, &pdev->dev, "my message...");

because that stuff is reasonably mature (and seemingly the preferred 
direction).

	Jeff


