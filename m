From: Chris Snook <csnook@redhat.com>
Subject: Re: [PATCH] Change S390 anti-dependency to CONFIG_GENERIC_HARDIRQS
 dependency
Date: Tue, 14 Oct 2008 20:07:55 -0400
Message-ID: <48F5345B.6060108@redhat.com>
References: <2acbd3e40810141621p31ba3ccdic909fc4634b5ef26@mail.gmail.com>	<20081014.163359.110730186.davem@davemloft.net>	<48F52E89.9050104@redhat.com> <20081014.165211.53009170.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: afleming@gmail.com, afleming@freescale.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:44423 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752599AbYJOAIJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Oct 2008 20:08:09 -0400
In-Reply-To: <20081014.165211.53009170.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Chris Snook <csnook@redhat.com>
> Date: Tue, 14 Oct 2008 19:43:05 -0400
> 
>> David Miller wrote:
>>> From: "Andy Fleming" <afleming@gmail.com>
>>> Date: Tue, 14 Oct 2008 18:21:44 -0500
>>>
>>>> Argh.  From what I could see, we have request_irq, free_irq,
>>>> disable_irq, enable_irq, and disable_irq_nosync.  For the PHYLIB, it
>>>> shouldn't be difficult to modify things so that it doesn't compile in
>>>> interrupt support if the system doesn't support them.  Shouldn't, that
>>>> is, if there's some config option that tells me whether those
>>>> functions exist.
>>> I think this whole situation with s390 is rediculious.
>>> If s390 is weird and lacks these fundamental things, that's fine.
>>> What isn't fine is how we're handling this.
>>> No code should care or even be aware of this.
>>> S390 should simply provide a set of dummy DMA and interrupt interface
>>> stubs that always fail and return an error value.
>>> Then we can get rid of this S390 Kconfig stuff which has been spewed
>>> all over the place.
>> "depends on PCI" has always worked for me.  Any reason we can't use that here?
> 
> That's every worse.
> 
> What in the world does PCI have to do with the attribute we are
> trying to depend upon here?
> 
> No, it's just stupid.  Add nop do-nothing stub functions for the
> APIs an architecture doesn't support, then we need none of this.

But then it will be much more of a pain to exclude the vast swath of 
irrelevant code in the kernel tree from your builds on these exotic 
architectures.  Have you ever built a kernel on s390?  It's not exactly 
the architecture's strong suit, and cross-compilers have their own 
problems.  I don't care what it is, but we should have *some* mechanism 
for automatically excluding every PCI device driver in existence from 
our builds of s390 and any other similarly unusual architecture.

-- Chris
