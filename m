From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.35-rc1] net-next: vmxnet3 fixes [3/5] Initialize
 link state at probe time
Date: Thu, 15 Jul 2010 22:44:35 -0700 (PDT)
Message-ID: <20100715.224435.45920963.davem@davemloft.net>
References: <alpine.LRH.2.00.1007131748180.32055@localhost.localdomain>
	<20100714.141054.48510602.davem@davemloft.net>
	<alpine.LRH.2.00.1007150125240.25472@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	pv-drivers@vmware.com
To: sbhatewara@vmware.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32892
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753504Ab0GPFoT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jul 2010 01:44:19 -0400
In-Reply-To: <alpine.LRH.2.00.1007150125240.25472@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shreyas Bhatewara <sbhatewara@vmware.com>
Date: Thu, 15 Jul 2010 18:20:14 -0700 (PDT)

> 
> On Wed, 14 Jul 2010, David Miller wrote:
> 
>> From: Shreyas Bhatewara <sbhatewara@vmware.com>
>> Date: Tue, 13 Jul 2010 17:48:55 -0700 (PDT)
>> 
>> > 
>> > Initialize vmxnet3 link state at probe time
>> > 
>> > This change initializes the state of link at the time when driver is
>> > loaded. The ethtool output for 'link detected' and 'link speed'
>> > is thus valid even before the interface is brought up.
>> > 
>> > Signed-off-by: Shreyas Bhatewara <sbhatewara@vmware.com>
>> 
>> You should never, ever, call netif_start_queue() on a device which has
>> not been brought up.
>> 
>> But that is what this patch is doing.
>> 
> 
> I do not understand why you say so. vmxnet3_check_link() is called in 
> probe() with affectTxQueue as false. Hence netif_start_queue() will not be 
> called before device is brought up.
> vmxnet3_check_link() is again called with affectTxQueue as true in 
> vmxnet3_activate_dev() after device was activated.

Aha, I see how the logic works now.

But still there is a problem with this patch, please remove the
driver version bump and resubmit.

You should only version bump at the last patch in a series.

Thanks.
