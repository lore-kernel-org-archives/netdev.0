From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: Splitting e1000 (Was: Re: e1000: backport ich9 support from 7.5.5
 ?)
Date: Fri, 06 Jul 2007 17:14:49 -0700
Message-ID: <468EDAF9.3020606@intel.com>
References: <1183138159.17243.16.camel@blaa> <20070629175006.GB3917@falooley.org> <468571C6.3090305@garzik.org> <46857C08.4030303@intel.com> <20070629150350.414553d4.akpm@linux-foundation.org> <4685838D.9080108@garzik.org> <c0a09e5c0706291657kd5e4baawb113a17ca5ab2191@mail.gmail.com> <46859F3F.305@garzik.org> <4685C09B.7040908@intel.com> <20070630082520.GA20140@infradead.org> <468AD23A.4090904@intel.com> <468D8B32.9020305@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Christoph Hellwig <hch@infradead.org>,
	Andrew Grover <andy.grover@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jason Lunz <lunz@reflexsecurity.com>,
	Mark McLoughlin <markmc@redhat.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	"Ronciak, John" <john.ronciak@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	'Stephen Hemminger' <shemminger@linux-foundation.org>,
	Andy Gospodarek <andy@greyhouse.net>,
	Arjan van de Ven <arjan@linux.intel.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:54207 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752488AbXGGAPI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2007 20:15:08 -0400
In-Reply-To: <468D8B32.9020305@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Kok, Auke wrote:
>> 1a) We post an e1000e driver that implements support for all 8257x 
>> (ich8/9, es2lan etc) devices.
>> 1b) We post a patch that drops support for all of these devices in the 
>> form of a pci-ID removal (no code removed) for e1000.
>>
>> 2) we post patches that remove code support for non-8254x devices at a 
>> later stage.
>>
>> 3) we backport any and all cleanups and flags from e1000e to e1000 where 
>> applicable.
>>
>>
>> This plan leaves a significant gap that I'm worrying about: after step 
>> (1) we basically have forced everyone to switch without providing a 
>> fallback (allthough we have our out-of-tree driver, but no in-kernel 
>> version in case issues exist).
>>
>>
>> Comments?
> 
> I like the general gist of it.  My own suggestion would be
> 
> 1) Create e1001.c, which is the SMALLEST POSSIBLE "it works" driver for 
> ICH9.  No feature enablement (no TSO, no MQ, no IOAT, not even checksum 
> offload), just a rock solid, no frills driver.  Think like e100.c :)
> 
> 2) We review the hell out of e1001, and merge it.  This enables ICH9 
> users, and ONLY ICH9 users, on e1001 in the upstream kernel, allowing us 
> to blithely ignore driver->driver migration issues present with other chips.
> 
> 
> At this point, e1001 is out in the field and in the upstream kernel in 
> the absolute shortest amount of time.  Users of chips NOT found in 
> current e1000 driver, and all future chips, can be enabled with little 
> impediments, in parallel with the steps below.
> 
> (all the "3^y" steps can occur in parallel)
> 
> 3^1) Add features to e1001, enabling new gizmos on new hardware.  This 
> can proceed in parallel with any e1000 work.  This allows users to use 
> git-bisect to find driver bugs -- or even hardware bugs, since you have 
> a baseline working e1001 driver.
> 
> 3^2) Add full ICH8 (8257x?) support to e1001.
> 
> 4) Drop 8257x PCI IDs from e1000.  See who complains.  Lather, rinse, 
> repeat.
> 
> 5) Figure out how the hell to clean up the current mess that is e1000, 
> and how to make sure e1000 and e1001 stay clean, long term.


This is not acceptable and hardly fair to expect from us.

It also exposes users to endless delays and uncertainties as to a final 
resolution. Not to mention that writing a driver from scratch for (just) ich9 
will take significant time, is silly since it's almost identical to ich8 etc..

I don't think that anyone besides you and maybe one or two others are interested 
in doing this rewrite from scratch. The rest of us would rather see something 
much more similar to my original suggestion which relieves the ich9-wishes for 
everyone and provides a good starting point to go forward. Not to mention that a 
lot of that code is already there, and at least cleaned up quite a bit already.


Auke
