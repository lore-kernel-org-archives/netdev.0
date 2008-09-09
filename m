From: Chris Snook <csnook@redhat.com>
Subject: Re: RFC: Nagle latency tuning
Date: Tue, 09 Sep 2008 14:40:00 -0400
Message-ID: <48C6C300.4050102@redhat.com>
References: <48C59F75.6030504@redhat.com> <48C5A9A9.9040503@hp.com>	<48C6052D.2080203@redhat.com> <87zlmhs7we.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>, Netdev <netdev@vger.kernel.org>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:56365 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754618AbYIISmL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Sep 2008 14:42:11 -0400
In-Reply-To: <87zlmhs7we.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen wrote:
> Chris Snook <csnook@redhat.com> writes:
>> I'd like to know where the 40 ms magic number comes from. 
> 
> From TCP_ATO_MIN
> 
> #define TCP_ATO_MIN     ((unsigned)(HZ/25))
> 
>> That's the
>> one that really hurts, and if we could lower that without doing
>> horrible things elsewhere in the stack, 
> 
> You can lower it (with likely some bad side effects), but I don't think it 
> would make these apps very happy in the end because they likely want
> no delay at all.
> 
> -Andi

These apps have a love/hate relationship with TCP.  They'll probably love SCTP 5 
years from now, but it's not mature enough for them yet.  They do want to 
minimize all latencies, and many of the apps explicitly set TCP_NODELAY.  The 
goal here is to improve latencies on the supporting apps that aren't quite as 
carefully optimized as the main message daemons themselves.  If we can give them 
a knob that bounds their worst-case latency to 2-3 times their average latency, 
without risking network floods that won't show up in testing, they'll be much 
happier.

-- Chris
