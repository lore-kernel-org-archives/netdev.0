From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.35-rc1] net-next: vmxnet3 fixes [4/5] Do not reset
 when the device is not opened
Date: Sat, 17 Jul 2010 16:35:38 -0700 (PDT)
Message-ID: <20100717.163538.137865264.davem@davemloft.net>
References: <alpine.LRH.2.00.1007151448260.25472@localhost.localdomain>
	<20100715.183210.226762655.davem@davemloft.net>
	<alpine.LRH.2.00.1007160108240.12503@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	pv-drivers@vmware.com, ronghua@vmware.com, matthieu@vmware.com
To: sbhatewara@vmware.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53248
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755825Ab0GQXfW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Jul 2010 19:35:22 -0400
In-Reply-To: <alpine.LRH.2.00.1007160108240.12503@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shreyas Bhatewara <sbhatewara@vmware.com>
Date: Fri, 16 Jul 2010 01:17:29 -0700 (PDT)

> 
> 
> On Thu, 15 Jul 2010, David Miller wrote:
> 
>> From: Shreyas Bhatewara <sbhatewara@vmware.com>
>> Date: Thu, 15 Jul 2010 18:20:52 -0700 (PDT)
>> 
>> > Is this what you suggest :
>> > 
>> > ---
>> > 
>> > Hold rtnl_lock to get the right link state.
>> 
>> It ought to work, but make sure that it is legal to take the
>> RTNL semaphore in all contexts in which this code block
>> might be called.
>> 
> 
> This code block is called only from the workqueue handler, which runs in
> process context, so it is legal to take rtnl semaphore.
> Tested this code by simulating event interrupts (which schedule this 
> code) at considerable frequency while the interface was brought up and
> down in a loop. Similar stress testing had revealed the bug originally. 

Awesome, please submit this formally.  The copy you sent lacked a commit
message and signoff.
