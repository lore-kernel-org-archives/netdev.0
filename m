From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/5] ila: Optimization to preserve value of
 early demux
Date: Thu, 03 Dec 2015 15:43:00 -0500 (EST)
Message-ID: <20151203.154300.1597761632975280766.davem@davemloft.net>
References: <1449011472-1459652-1-git-send-email-tom@herbertland.com>
	<20151203.144845.271629627276792795.davem@davemloft.net>
	<CALx6S358G5c47hUEHMYmhkZjnTqfAOD9kEEk2L92Y15TYA7=eg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46475 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751324AbbLCUnC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 15:43:02 -0500
In-Reply-To: <CALx6S358G5c47hUEHMYmhkZjnTqfAOD9kEEk2L92Y15TYA7=eg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Thu, 3 Dec 2015 11:59:31 -0800

> On Thu, Dec 3, 2015 at 11:48 AM, David Miller <davem@davemloft.net> wrote:
>> From: Tom Herbert <tom@herbertland.com>
>> Date: Tue, 1 Dec 2015 15:11:07 -0800
>>
>>> ip6tables -t mangle -A PREROUTING --dst 2001:0:0:33::/64 -j ILAIN
>>
>> The user should have to do anything like this in order to just get
>> proper working functionality of ILA.
>>
>> It should just work transparently.
> 
> This was transparent in the previously posted patch "ila: Add support
> for netfilter NF_INET_PRE_ROUTING hook", but there was significant
> pushback that NF interface was not intended for this purpose. Using an
> IP tables target like this should preserve the sanctity of the
> interfaces and does provide nice performance improvement since
> PREROUTING is done before early demux. The NF_INET_PRE_ROUTING hook is
> still better performance though and what we are using internally (just
> an incremental change on top of these patches).

You want to make a transformation before early demux, which edits the
packet.

But someone who configures ILA and just wants reasonable performance
shouldn't have to configure anything explicitly outside of the ILA
config itself.

So again, those are your operating constraints.
