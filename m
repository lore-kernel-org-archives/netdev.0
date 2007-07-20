From: Jeff Garzik <jeff@garzik.org>
Subject: Re: ANNOUNCE: igb: Intel 82575 Gigabit Ethernet driver (PCI-Express)
Date: Fri, 20 Jul 2007 07:00:26 -0400
Message-ID: <46A095CA.8010900@garzik.org>
References: <46980ADA.5050104@intel.com> <469ED3D7.6040905@garzik.org> <469FF922.2090900@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>,
	Arjan van de Ven <arjan@linux.intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:49316 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752764AbXGTLAb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jul 2007 07:00:31 -0400
In-Reply-To: <469FF922.2090900@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> Jeff Garzik wrote:
>> Kok, Auke wrote:
>>>      http://foo-projects.org/~sofar/igb.patch       [558K]
>>>      http://foo-projects.org/~sofar/igb.patch.bz2   [98K]
>>
>> Just took a look at this.
>>
>> This has the same problem as in the other thread -- huge internal API 
>> -- except this time, the problem is emphasized by the fact that the 
>> majority of the API hooks only have a single user, making each hook 
>> and API entry point demonstrably useless overhead.
>>
>> Please remove the useless internal API and resubmit.
> 
> Why don't you accept it now and allow us the time to work on this in the 
> coming period? The driver works, performs better than all 8257x hardware 
> and uses less CPU utilization. That must be good for everyone. Keeping 
> it outside of the linux tree is just going to postpone testing the 
> non-internal API parts.


I do not know how to say it more clearly than it has been said for weeks:

	do-anything internal API is a merge stopper.

_Especially_ in igb's case, more than others, because it is obviously a 
one-user-per-hook no-op API.  Pure overhead.  100% real pork products.

Since you praise it in the following paragraphs, that demonstrates 
previous little incentive to remove it, if I merge this driver as-is.


>> PLEASE take a look at how bnx2 and tg3 are structured.
> 
> They don't use PHYlib. Nobody is perfect...
> 
> We can and we should be able to _not_ agree on certain things and live 
> together just fine. While I agree that some designs are better, the 
> current internal API design has worked really good for us and allowed us 
> to develop this driver and ixgbe in much faster rate than ever before. 
> It was most useful in silicon validation and extremely flexible for us. 
> At one point, the 82575 silicon was even supporter by the e1000 driver, 
> because this internal API made it so easy to add new hardware support. 
> For obvious reasons (differences in hw) we decided to split this driver 
> off.

This is the same argument we get from every vendor who wants to keep 
their lovely cross-OS modularization/etc. API.

igb has been submitted in OBVIOUSLY BLOATED state.  I could care less 
how useful it was in silicon validation, if this is the result:  an 
implement-any-MAC-or-PHY-in-the-world internal API where every hook... 
has precisely ONE user, thus obviating the need for the hook and API at 
all.  Simple mathematical reduction.


> It served a good purpose. We can improve it, and I sure want to do that, 
> but I think it's better to improve something *upstream*, then going back 
> working at things offline without having any certainty that you will 
> accept it after I get back, since you might just reject it on another 
> argument, etc. It will take quite some effort and convincing to make 
> this happen, and it would help a lot if we can work with/in the 
> community on that, instead of off-line.

Let us review the e1000new major merge objections (posted July 9, msgid 
<469280F5.8000909@garzik.org>):

	1) Transition plan (irrelevant to this igb thread)
	2) Internal do-anything API
	3) Lack of Intel attention to on-going driver maintenance and
	   cleanups, rather than strict focus bolting on new features
	   or fixes.

Intel is just wasting everybody's time by coming back with a new driver 
that will spark the same objection (#2) as with the previous driver. 
You then ask the Linux community to TRUST you that you will clean up a 
driver, running counter to experience associated with objection #3.

It needs to look like a lean and mean Linux driver, not a driver with 
CLEAR bloat left over from silicon validation.  Your customers -- my 
users -- deserve much better.

Here is the key:  I don't expect perfection (much to Christoph's chagrin 
:)) in a driver submission.  I want to see three key things in a new driver:

	1) it's clean

	2) it is a good foundation for the future

	3) stable, reliable, active maintainership process exists

Arjan says #3 is in place, so we will take that on faith.  It's mostly 
clean (#1), but it's mainly problem is that it's overengineered.   This 
igb driver violates one of Linux's key principles:  "do what you must, 
and no more."  That internal API, demonstrably a no-op in igb, is not a 
good foundation for the future (#2).


With regards to "certainty"...  you should know that there are never any 
promises.  I have to look at each incarnation with fresh eyes.  ASSUMING 
the driver is moving in the right direction (i.e. author accepts 
feedback), each re-review should be more rapid.  But it is key to 
understand that often initial comments and initial revisions are 
required simply to make the driver reviewable.  This is the natural 
process that every driver goes through.

But if you want certainty, I would be more than happy to take igb as-is, 
merge it into netdev-2.6.git, clean it up myself to illustrate the 
proper direction, and then push it upstream.  That would get a modified 
igb upstream sooner rather than later.  Would that be preferred?  I 
could knock that out this weekend.  Or I am happy to mentor.  Whatever 
it takes.

Whoever does it, this needs a lot of simple algabraic/logical reductions.

It needs to look like, to be, a Linux driver first and foremost.  Linux 
users should not suffer needless bloat because of the happenstance of 
the internal silicon validation process.

	Jeff


