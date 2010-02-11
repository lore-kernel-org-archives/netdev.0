From: Patrick McHardy <kaber@trash.net>
Subject: Re: [net-next-2.6,	v4 1/3] ethtool: Introduce n-tuple filter programming
 support
Date: Thu, 11 Feb 2010 08:53:11 +0100
Message-ID: <4B73B767.2030308@trash.net>
References: <20100210100718.10855.96567.stgit@localhost.localdomain>	 <4B7296AB.6020004@trash.net>	 <Pine.WNT.4.64.1002101533340.58956@ppwaskie-MOBL2.amr.corp.intel.com>	 <4B73A0BE.1060407@trash.net> <1265872027.4501.97.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35675 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751259Ab0BKHxX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2010 02:53:23 -0500
In-Reply-To: <1265872027.4501.97.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peter P Waskiewicz Jr wrote:
> On Wed, 2010-02-10 at 22:16 -0800, Patrick McHardy wrote:
>>> I agree that an underlying driver will have much of the same in terms of 
>>> what it generates, but it will not be restricted to how it stores the 
>>> items.  In other words, if ixgbe wanted to retrieve all 8192 filters, we 
>>> could avoid the caching altogether, and pull directly from HW when the 
>>> call is made from ethtool.  One way or another, there's going to be a big 
>>> amount of copied data from kernel space to user space.  This was the 
>>> approach I thougt would be the most useful without defining a kernel to 
>>> userspace chain of flow spec structs.
>> My main concern is that its hard for userspace to do anything with
>> this data except print it. By using a binary representation the
>> kernel code should get simpler and less prone to potential
>> inconsistencies within drivers and make it more useful to userspace
>> at the same time.
> 
> It would be easier to change ethtool in userspace to reformat data.

I'm thinking more about other potential users of this interface.

> However, some drivers/hardware may represent data in a different way for
> their filters, much like the ethtool stats (ethtool -S).  I see this as
> a hardware-specific thing, so letting the kernel provide the strings is
> the most flexible, since it's the most representative of the hardware.

I think there's a difference between stats and filters. In case of
filters, userspace already needs to know the representation without
knowing the specific driver in order to send them to the kernel, so
it needs to use a common representation unless I'm missing something.

But fair enough, I just wanted to state my concerns, which might of
course be wrong.
