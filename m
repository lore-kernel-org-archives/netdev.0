From: Ben Greear <greearb@candelatech.com>
Subject: Re: Linville's L2 rant... -- Re: PATCH Fix bonding active-backup
 behavior for VLAN interfaces
Date: Tue, 01 Aug 2006 09:17:15 -0700
Message-ID: <44CF7E8B.9030407@candelatech.com>
References: <44CA34D0.1070507@candelatech.com> <44CA87C5.1060905@candelatech.com> <20060730.205032.130618331.davem@davemloft.net> <200607311015.40255.Christophe.Devriese@eurid.eu> <20060731123038.GA10138@tuxdriver.com> <1154396348.5170.43.camel@jzny2> <20060801120836.GA29208@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <hadi@cyberus.ca>,
	Christophe Devriese <Christophe.Devriese@eurid.eu>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:63401 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S1750724AbWHAQR6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2006 12:17:58 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060801120836.GA29208@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> On Mon, Jul 31, 2006 at 09:39:08PM -0400, Jamal Hadi Salim wrote:
> 
>>On Mon, 2006-31-07 at 08:30 -0400, John W. Linville wrote:
> 
> 
>>>Do we hold the view that our L2 code is on par with the rest of
>>>our code?  Is there an appetite for a clean-up?  Or is it just me?
>>>
>>></rant>
>>>
>>>If you made it this far, thanks for listening...I feel better now. :-)
>>
>>Yes, I made it this far and you do make good arguement (or i may be
>>over-dosed ;->).
>>I have seen the following setups that are useful:
>>
>>1) Vlans with bridges; in which one or more vlans exist per ethernet
>>port. Broadcast packets within such vlans are restricted to just those
>>vlans by the bridge.
>>2) complicate the above a little by having multiple spanning trees. 
>>3) Add to the above link layer HA (802.1ad or otherwise as presented
>>today by Bonding).
>>
>>To answer your question; i think yes we need all 3.
> 
> 
> Oh, don't get me wrong -- I definitely think we need all three.
> 
> I'm just not sure we need every conceivable combination of a) bonds
> of vlan interfaces; b) vlan interfaces on top of bonds; c) bridged
> vlan interfaces w/ disparate vlan IDs; d) bonded vlan interfaces w/
> disparate vlan IDs; e) bonded bridge interfaces (does this work?) f)
> bonded bonds (seen customers trying to do it); g) bridged vlan
> interfaces; h) bridged bonds; i) bridged bridges (probably doesn't
> work, but someone probably wants it); j) vlan interfaces on top of
> bridges; k) vlan interfaces on top of vlans (double vlan tagging);
> and, l) what am I leaving out?

Well, if it makes you feel better, I can't see a good way to do
vlans-over-vlans cleanly, backwards compatibly, and functional with
bridging, etc.  I would not plan to add such a feature to the kernel
unless from it's moment of inclusion it could handle at least bridging,
either.  So that feature will probably not see the light of day
any time soon :)

> Most (actually all afaik) L2 networking equipment enforces some
> hierarchy on the relationship between these L2 entities.  I am more
> and more convinced we should do the same, although I do acknowledge
> that the current situation does allow for some cleverness.

Very often, the answer to difficult networking issues is to 'get a linux box',
since that very flexibility is often key to interesting problems.

> I'm just not sure that cleverness is worth the headache, especially
> since the most clever things usually only work by accident...

Or, work by solid, modular design and small tweaks!

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

