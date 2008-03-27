From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] e1000e: test MSI interrupts
Date: Thu, 27 Mar 2008 16:53:55 -0700
Message-ID: <47EC3393.5010901@intel.com>
References: <47EAB54A.1060306@intel.com><36D9DB17C6DE9E40B059440DB8D95F5204BF07F7@orsmsx418.amr.corp.intel.com><47EBF8EE.1000102@garzik.org> <20080327.150555.113590579.davem@davemloft.net> <36D9DB17C6DE9E40B059440DB8D95F5204C27573@orsmsx418.amr.corp.intel.com> <47EC2FE9.5020400@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	David Miller <davem@davemloft.net>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:15912 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752657AbYC0X7i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2008 19:59:38 -0400
In-Reply-To: <47EC2FE9.5020400@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Garzik wrote:
> Brandeburg, Jesse wrote:
>> I get your point, but this seems a maintainance problem due to not being
>> able to "future proof" the solution.  I know what is (IDs) available
>> now, but I don't know how many systems in the future IBM will release
>> with a similar bridge but a different device ID that causes the same
>> issue.
> 
> Future-proofing in that way is a pipe dream.
> 
> You hope to predict what _errata_, what out-of-spec behavior future
> hardware will have.  Trying to code for such N^M possible futures will
> lead to code bloat, depression, and eventually madness.
> 
> 
>> Should we take on the maintenance of continually having to add
>> every new bridge device that has this issue to our driver?  Users just
>> want this stuff to work when they plug it in.
> 
> As David noted, we touch quirks.c all the time for various platform
> eccentricities.  Adding a new id is easy and takes two seconds.  The
> same ease of change applies to any driver-local list of ids, too.
> 
> Anyway, I think a better question to ask is:  should we bloat up every
> driver testing for platform quirks found on a minority of platforms?
> 
> Moreover, "it doesn't work" type errata is typically fixed in future
> chip generations -- making any such generic test /less/ valuable,
> because of the lower likelihood that IBM will continue to release this
> buggy hardware for decades.
> 
> We have an existing "this bridge and MSI don't get along" list.  Adding
> an id is a one-line patch.

well it's just slightly more complex than just that... the bridge works OK with
MSI for every device except 82571

so 82572, 82573 e1000's work fine as well as all the newer pci-e e1000's, or any
of the non-e1000 hardware that uses MSI interrupts.

so disabling MSI entirely for that chipset by quirking it is not what we want to
do in the first place.

hence the test :)

the only alternative I see is that we have a quirk in the e1000 driver that acts
when the combination of an 82571 and this particular chipset is found, but I have
no information ATM on the chipset id's yet and on how to identify this configuration.

Auke
