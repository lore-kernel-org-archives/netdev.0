From: Shreyas Bhatewara <sbhatewara@vmware.com>
Subject: Re: [PATCH 2.6.35-rc1] net-next: vmxnet3 fixes [4/5] Do not reset
 when the device is not opened
Date: Fri, 16 Jul 2010 01:17:29 -0700 (PDT)
Message-ID: <alpine.LRH.2.00.1007160108240.12503@localhost.localdomain>
References: <alpine.LRH.2.00.1007131749030.32055@localhost.localdomain> <20100714.140718.115934967.davem@davemloft.net> <alpine.LRH.2.00.1007151448260.25472@localhost.localdomain> <20100715.183210.226762655.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"pv-drivers@vmware.com" <pv-drivers@vmware.com>,
	Ronghua Zhang <ronghua@vmware.com>,
	Matthieu Bucchianeri <matthieu@vmware.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-2.vmware.com ([65.115.85.73]:61781 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935847Ab0GPIRa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jul 2010 04:17:30 -0400
In-Reply-To: <20100715.183210.226762655.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Thu, 15 Jul 2010, David Miller wrote:

> From: Shreyas Bhatewara <sbhatewara@vmware.com>
> Date: Thu, 15 Jul 2010 18:20:52 -0700 (PDT)
> 
> > Is this what you suggest :
> > 
> > ---
> > 
> > Hold rtnl_lock to get the right link state.
> 
> It ought to work, but make sure that it is legal to take the
> RTNL semaphore in all contexts in which this code block
> might be called.
> 

This code block is called only from the workqueue handler, which runs in
process context, so it is legal to take rtnl semaphore.
Tested this code by simulating event interrupts (which schedule this 
code) at considerable frequency while the interface was brought up and
down in a loop. Similar stress testing had revealed the bug originally. 
