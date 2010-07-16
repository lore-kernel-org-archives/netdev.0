From: Shreyas Bhatewara <sbhatewara@vmware.com>
Subject: Re: [PATCH 2.6.35-rc1] net-next: vmxnet3 fixes [3/5] Initialize link
 state at probe time
Date: Thu, 15 Jul 2010 18:20:14 -0700 (PDT)
Message-ID: <alpine.LRH.2.00.1007150125240.25472@localhost.localdomain>
References: <alpine.LRH.2.00.1007070125440.4652@localhost.localdomain> <alpine.LRH.2.00.1007070202080.5939@localhost.localdomain> <alpine.LRH.2.00.1007131748180.32055@localhost.localdomain> <20100714.141054.48510602.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"pv-drivers@vmware.com" <pv-drivers@vmware.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-2.vmware.com ([65.115.85.73]:49256 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935183Ab0GPBUO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jul 2010 21:20:14 -0400
In-Reply-To: <20100714.141054.48510602.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 14 Jul 2010, David Miller wrote:

> From: Shreyas Bhatewara <sbhatewara@vmware.com>
> Date: Tue, 13 Jul 2010 17:48:55 -0700 (PDT)
> 
> > 
> > Initialize vmxnet3 link state at probe time
> > 
> > This change initializes the state of link at the time when driver is
> > loaded. The ethtool output for 'link detected' and 'link speed'
> > is thus valid even before the interface is brought up.
> > 
> > Signed-off-by: Shreyas Bhatewara <sbhatewara@vmware.com>
> 
> You should never, ever, call netif_start_queue() on a device which has
> not been brought up.
> 
> But that is what this patch is doing.
> 

I do not understand why you say so. vmxnet3_check_link() is called in 
probe() with affectTxQueue as false. Hence netif_start_queue() will not be 
called before device is brought up.
vmxnet3_check_link() is again called with affectTxQueue as true in 
vmxnet3_activate_dev() after device was activated.
