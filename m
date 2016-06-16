From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC 1/3] ipv4: make flow functions more grepable by
 removing flowi4_init_output
Date: Thu, 16 Jun 2016 23:39:12 +0200
Message-ID: <0f3516fc-9108-58a3-88fa-49a80a829acc@stressinduktion.org>
References: <6b8ad88f-db0b-3a88-197d-ed7278783bfc@cumulusnetworks.com>
 <20160615.124800.889153492414820174.davem@davemloft.net>
 <2c081044-0861-8a84-f4ae-88c60c4ddc67@cumulusnetworks.com>
 <20160616.141805.201276959937562482.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ja@ssi.bg
To: David Miller <davem@davemloft.net>, dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:55241 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754333AbcFPVjR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 17:39:17 -0400
In-Reply-To: <20160616.141805.201276959937562482.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16.06.2016 23:18, David Miller wrote:
> From: David Ahern <dsa@cumulusnetworks.com>
> Date: Wed, 15 Jun 2016 14:29:28 -0600
> 
>> On 6/15/16 1:48 PM, David Miller wrote:
>>> But if people don't use the helpers, and initialize flow structures
>>> on their own, yeah that defeats the whole mechanism and things will
>>> seem harder and "unhelpful".
>>
>> That's my point -- the flow struct does not have a consistent
>> initializer. There have been a number of bug patches over the past
>> year like 4cfc86f3dae6 to handle uninitialized elements. My suggestion
>> here is the same as 4cfc86f3dae6 which is to initialize the flow when
>> it is declared.
>>
>> Consider the recent change from Hannes for 38b7097b55b6. fl6 can be
>> initialized when it is declared with a bit of straightforward
>> refactoring -- icmp6_send has an easy split into 2.
>>
>> Seems like that is a more robust long term solution considering the
>> various init use cases.
> 
> The danger with initializers is it puts the burdon all over the tree.
> 
> So now there are many places that need to be audited when a new
> element is added.
> 
> So from my perspective, the bug is that the code in question did
> things by hand rather than using the helper function.
> 
> If everyone used the flow initializer helpers, the compiler would
> tell us every place that needs to be fixed up.
> 
> By doing initializers inline, this process of discovery is more
> difficult and error prone.

I see both sides and acknowledge the fact that we don't generate compile
errors any more when we add fields. OTOH we already have a lot of
places, probably even more, which don't use the initialization helper
functions as they just need to feed in a subset of the flowi4
information (memset and fl4.daddr = <>; and some other attributes is a
common case. Most of the time a new attribute that gets added to flow4i
only decreases the scope of the actual lookup, thus a missing attribute
doesn't necessarily indicate a bug.

In my local branch I adapted the changes from Julian so far. I will
revisit the initialization of flowi4, thanks for all the input so far.

Currently I have difficulties keeping user space behavior the same while
improving the ECN situation, as ToS simply specifies the use of the
second bit. I can't improve the ECN situation in a transparent way.

Bye,
Hannes
