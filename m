From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] ipv4: Disallow non-namespace aware protocols to register.
Date: Fri, 15 Feb 2013 12:05:18 -0800
Message-ID: <87a9r5tkap.fsf@xmission.com>
References: <20130205.144302.2065386693901345213.davem@davemloft.net>
	<87pq028561.fsf@xmission.com>
	<20130215.134136.798843717749865061.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:42256 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751038Ab3BOUFc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2013 15:05:32 -0500
In-Reply-To: <20130215.134136.798843717749865061.davem@davemloft.net> (David
	Miller's message of "Fri, 15 Feb 2013 13:41:36 -0500 (EST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Thu, 14 Feb 2013 22:25:26 -0800
>
>> David Miller <davem@davemloft.net> writes:
>> 
>>> All in-tree ipv4 protocol implementations are now namespace
>>> aware.  Therefore all the run-time checks are superfluous.
>>>
>>> Reject registry of any non-namespace aware ipv4 protocol.
>>> Eventually we'll remove prot->netns_ok and this registry
>>> time check as well.
>> 
>> It has been a long time coming but this is very cool to see we have
>> finally made all of ipv4 network namespace aware.
>
> BTW, I took a look at ipv6 and unlike ipv4 there seems to be no sanity
> checks or per-protocol booleans indicating proper netns support.
>
> Is my interpretation right that ipv6 just assumes all registered
> protocols are netns aware at this point?

It looks like when the ipv6 network namespace work was done work that
check was not added to the ipv6 code :( I skimmed through the history
and I don't see any signs that anything was every done with struct
inet6_protocol.  Nor when I looked at the addition of netns support to
the ipv6 udp code were there any switches flipped.

> If so that was definitely a bug, because things like l2tp have an
> ipv6 component and were not fully netns aware until very recently.

Agreed it was a bug.

I have just read through all of the handlers registered with
inet6_add_protocol in my 3.8 development tree and it appears that
everything except l2tp has network namespace support.  And l2tp is fixed
in net-next so we appear to be good now.

Eric
