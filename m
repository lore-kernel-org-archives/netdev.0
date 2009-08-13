From: Brian Haley <brian.haley@hp.com>
Subject: Re: [RFC] ipv6: Change %pI6 format to output compacted addresses?
Date: Thu, 13 Aug 2009 16:28:21 -0400
Message-ID: <4A847765.3080102@hp.com>
References: <1250091560.6641.48.camel@fnki-nb00130> <4A836D6D.1040400@hp.com> <1250174390.6641.89.camel@fnki-nb00130> <4A843EF7.4010700@hp.com> <1250187034.28285.93.camel@Joe-Laptop.home> <48AAB7CB-8EEC-4E30-B821-3E0D84531AAA@oracle.com> <1250187662.28285.97.camel@Joe-Laptop.home> <5D6A7C11-B300-4E39-BBDF-EF18C4BAE419@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>, Jens Rosenboom <jens@mcbone.net>,
	Linux Network Developers <netdev@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:22830 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754738AbZHMU2W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 16:28:22 -0400
In-Reply-To: <5D6A7C11-B300-4E39-BBDF-EF18C4BAE419@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chuck Lever wrote:
> On Aug 13, 2009, at 2:21 PM, Joe Perches wrote:
>> On Thu, 2009-08-13 at 14:15 -0400, Chuck Lever wrote:
>>> On Aug 13, 2009, at 2:10 PM, Joe Perches wrote:
>>>> The patch allows "%p6ic" for compressed and "%p6ic4" for compressed
>>>> with ipv4 last u32.
>>>
>>> Why do these need to be separate?
>>
>> Just an option.
>> I think it possible somebody will want "1::" instead of "1::0.0.0.0"
> 
> Hrm.
> 
> Do you have a use case?  Really, it's pretty easy to tell when the
> mapped v4 presentation format should be used.  See
> ipv6_addr_v4mapped().  Otherwise the mapped v4 presentation format
> should never be used.
> 
> A problem with the existing %p[iI] implementation is that each call site
> has to have logic that figures out the address family of the address
> before calling sprintf().  This makes it difficult to use this facility
> with, for example, debugging messages, since you have to add address
> family detection logic at every debugging message call site.  Lots of
> clutter and duplicated code.
> 
> With %p6ic4, each call site now has to see that it's an IPv6 address,
> and then decide if the address is a mapped v4 address or not.  It's the
> same logic everywhere.
> 
> It seems to me it would be a lot more useful if we had a new %p6
> formatter that handled all types of IPv6 addresses properly, the way
> inet_ntop(3) does in user space.  (Or even a new formatter that could
> handle both address families).

I would agree that this could be better, maybe after playing with this
some more it will be obvious what that something is.  I'd be willing
to review any thoughts you have :)

-Brian
