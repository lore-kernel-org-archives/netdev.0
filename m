From: "Hanania, Amir" <amir.hanania@intel.com>
Subject: RE: [net-2.6 v2 5/7] ixgbe: DDP last buffer size work around
Date: Fri, 28 Jan 2011 13:36:15 -0800
Message-ID: <4C5E6457CD7911469A07260381288C28CBE83195@orsmsx502.amr.corp.intel.com>
References: <1296217743-30093-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1296217743-30093-6-git-send-email-jeffrey.t.kirsher@intel.com>
 <20110128.115100.226772144.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"bphilips@novell.com" <bphilips@novell.com>
To: David Miller <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:4699 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751494Ab1A1VgR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jan 2011 16:36:17 -0500
In-Reply-To: <20110128.115100.226772144.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

Sorry I missed your mail from last night.

You are right, it should be bufflen, which is 4096 and not PAGE_SIZE.

I will fix that and resubmit.
-Amir


-----Original Message-----
From: David Miller [mailto:davem@davemloft.net] 
Sent: Friday, January 28, 2011 11:51 AM
To: Kirsher, Jeffrey T
Cc: Hanania, Amir; netdev@vger.kernel.org; gospo@redhat.com; bphilips@novell.com
Subject: Re: [net-2.6 v2 5/7] ixgbe: DDP last buffer size work around

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
