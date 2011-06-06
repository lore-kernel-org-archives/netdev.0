From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] macvlan: add VLAN filters to lowerdev
Date: Mon, 06 Jun 2011 16:44:00 -0700 (PDT)
Message-ID: <20110606.164400.1575049396635321206.davem@davemloft.net>
References: <20110606142715.2692.6311.stgit@jf-dev1-dcblab>
	<20110606.150352.392614415181146213.davem@davemloft.net>
	<4DED5857.2000408@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: john.r.fastabend@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38450 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754440Ab1FFXoC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 19:44:02 -0400
In-Reply-To: <4DED5857.2000408@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>
Date: Mon, 06 Jun 2011 15:44:39 -0700

> On 6/6/2011 3:03 PM, David Miller wrote:
>> From: John Fastabend <john.r.fastabend@intel.com>
>> Date: Mon, 06 Jun 2011 07:27:16 -0700
>> 
>>> Stacking VLANs on top of the macvlan device does not
>>> work if the lowerdev device is using vlan filters set
>>> by NETIF_F_HW_VLAN_FILTER. Add ndo ops to pass vlan
>>> calls to lowerdev.
>>>
>>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>> 
>> I think this might have unintended side-effects.
>> 
>> Much of the VLAN code makes decisions based upon whether these
>> ops are NULL or not.
>> 
>> Now, no matter what is implemented in the lower device, the VLAN
>> code will see them non-NULL in the macvlan device.
> 
> I would expect these decisions to be wrapped in the feature flag
> like this,
> 
>         if (vlan_id && (real_dev->features & NETIF_F_HW_VLAN_FILTER))
>                 ops->ndo_vlan_rx_kill_vid(real_dev, vlan_id);
> 
> Although grep found two call sites not wrapped,
 ...
> I could wrap these in feature flag checks as well but I see no harm
> in letting these fall through to the macvlan driver and failing.

Fair enough, patch applied.
