From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [net-next 9/9] ixgbe: Cleanup holes in flags after removing several
 of them
Date: Thu, 19 Jul 2012 09:11:27 -0700
Message-ID: <500831AF.6020402@intel.com>
References: <1342643516-2696-1-git-send-email-jeffrey.t.kirsher@intel.com> <1342643516-2696-10-git-send-email-jeffrey.t.kirsher@intel.com> <AE90C24D6B3A694183C094C60CF0A2F6026B6F98@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:40440 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750767Ab2GSQL3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jul 2012 12:11:29 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6F98@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/19/2012 01:33 AM, David Laight wrote:
>> This change is just meant to defragment the flags as there are several
> hole
>> that have been introduced since several features, or the flags for
> them,
>> have been removed.
> Doesn't this sort of change just make it difficult for people who are
> looking at hexdumps of memory but don't have exactly the right header
> file to hand?
These are private flags held inside of the driver and never exposed
externally to user space.  If we have to go through a hexdump to try and
figure out the state of the driver I would certainly hope we have the
header file in hand.  Knowing what bits we use is kind of pointless if
we don't know where the flags are being stored within the adapter
structure itself.

> It doesn't really gain anything much either.
I never did say it gains us much.  It is mostly just housekeeping in
order to make it clear where the available bits are in the flags fields.

> I can (just) imagine reordering flags so that the commonly
> tested ones are in the low bits so that they can be tested
> with small immediate constants - saving an instruction.
> But that isn't what is being done here.
>
> 	David

On x86 it seems like gcc is converting all of the flag tests to "testb"
assembly ops and just using an offset within the flags field to access
bits 8 through 31.  It doesn't seem like there would be much of an
advantage to reordering the flags unless we need to optimize for the
cases where we are testing multiple flags.  Even in that case we would
probably just want to align things so that when we access multiple flags
they are in the same 8 bit field.

Thanks,

Alex
