From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 0/15] spidernet driver bug fixes
Date: Tue, 12 Jun 2007 20:04:18 -0400
Message-ID: <466F3482.4050305@garzik.org>
References: <20070607191707.GA7904@austin.ibm.com> <1181265151.6026.1.camel@concordia.ozlabs.ibm.com> <20070608170608.GI7904@austin.ibm.com> <20070608172020.GA31089@havoc.gtf.org> <20070611181429.GA4397@austin.ibm.com> <466F2581.2080808@garzik.org> <20070612233237.GN4397@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Ellerman <michael@ellerman.id.au>, netdev@vger.kernel.org,
	cbe-oss-dev@ozlabs.org
To: Linas Vepstas <linas@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59628 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752551AbXFMAE2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jun 2007 20:04:28 -0400
In-Reply-To: <20070612233237.GN4397@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linas Vepstas wrote:
> On Tue, Jun 12, 2007 at 07:00:17PM -0400, Jeff Garzik wrote:
>> Linas Vepstas wrote:
>>> On Fri, Jun 08, 2007 at 01:20:20PM -0400, Jeff Garzik wrote:
>>>> On Fri, Jun 08, 2007 at 12:06:08PM -0500, Linas Vepstas wrote:
>>>>> On Fri, Jun 08, 2007 at 11:12:31AM +1000, Michael Ellerman wrote:
>>>>>> On Thu, 2007-06-07 at 14:17 -0500, Linas Vepstas wrote:
>>>>>>> The major bug fixes are: 
>>>>>> I realise it's late, but shouldn't "major bugfixes" be going into 22 ?
>>>>> Yeah, I suppose, I admit I've lost track of the process. 
>>>> You need to order your bug fixes first in the queue. 
>>> OK, here are the patches, re-ordered. There is a different number
>>> than last time, as I threw out one, merged one, and got cold feet
>>> on a third one.  They still pass the tests.
>>>
>>> The first five patches focus on three serious bugs, fixing crashes or
>>> hangs.
>>>
>>> -- patch 1 -- kernel crash when ifdown while receiving packets.
>>> -- patch 2,3,4 -- device driver deadlocks on "RX ram full" mesgs.
>>>                  (kernel stays up, ifdown/up clear the problem).
>>> -- patch 5 -- misconfigured TX interrupts results in 3x-4x per
>>>              degradation for small packets.
>>>
>>> -- patch 6 -- rx stats may be mangled
>>> -- patch 7 -- hw checksum sometimes breaks ipv6 operation
>>>
>>> -- patches 8-15 -- misc tweaks, and documentation.
>>>
>>>
>>> I re-ran my stress tests with patches 1-7 applied; they pass.
>> This is a bit frustrating, because this includes many patches that you 
>> ALREADY told me to queue for 2.6.23, which I did, in 
>> netdev-2.6.git#upstream.
> 
> Sigh. I redid the series so as to avoid this problem, per the 
> previous conversation. 
> 
>> Should I just drop all spidernet patches and start over?
> 
> No. Apply the series I just sent you, dropping the one called
> "patch 6/15", the one from Florin Malita, as it appears you'd
> previously picked this up.  The rest of the patches should apply
> cleanly; I just cheked. I just did a "git pull" of 
> git://git.kernel.org/pub/scm/linux/kernel/git/jgarzik/netdev-2.6
> and checked. The result of patching is exactly as it should be.
> 
> Just in case it wasn't clear, I'd like to see patches 1-5 go
> into 2.6.22 ... as these address the most critical complaints I'd
> gotten recently.
> 
> --linas
> 
> 

As I just stated, many of the patches in the "current" patch series have 
already been applied to netdev-2.6.git#upstream:

Linas Vepstas (11):
       s2io: add PCI error recovery support
       s2io: add PCI error recovery support
       spidernet: beautify error messages
       spidernet: move a block of code around
       spidernet: zero out a pointer.
       spidernet: null out skb pointer after its been used.
       spidernet: Don't terminate the RX ring
       spidernet: enhance the dump routine
       spidernet: reset the card when an rxramfull is seen
       spidernet: service TX later.
       spidernet: increase the NAPI weight

These are clearly duplicating some of the patches in your patchseries, 
which means you are woefully out of sync with upstream.

	Jeff


