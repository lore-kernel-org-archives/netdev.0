From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 v2 5/7] ixgbe: DDP last buffer size work around
Date: Fri, 28 Jan 2011 11:51:00 -0800 (PST)
Message-ID: <20110128.115100.226772144.davem@davemloft.net>
References: <1296217743-30093-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1296217743-30093-6-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amir.hanania@intel.com, netdev@vger.kernel.org, gospo@redhat.com,
	bphilips@novell.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56579
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752793Ab1A1Tu0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jan 2011 14:50:26 -0500
In-Reply-To: <1296217743-30093-6-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 28 Jan 2011 04:29:01 -0800

> From: Amir Hanania <amir.hanania@intel.com>
> 
> We found a hardware erratum on 82599 hardware that can lead to buffer
> overwriting if the last buffer in FCoE DDP is exactly PAGE_SIZE.
> If this is the case, we will make sure that there is no HW access to
> this buffer.
> 
> Please see the 82599 Specification Update for more information.
> 
> Signed-off-by: Amir Hanania <amir.hanania@intel.com>
> Tested-by: Ross Brattain <ross.b.brattain@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Jeff, I still think this change is bogus.

PAGE_SIZE is variable, so the chip can't possibly only BUG on that
specific value.

Maybe the condition is "any power-of-2 larger than or equal to 4096"?
Or something like that?

I pointed this out last night, and I was really hoping I'd get actual
feedback on this issue before you're respin your tree.

I'm not pulling in these changes until I get a human being telling me
what the situation is here with this bug.
