From: Andi Kleen <andi@firstfloor.org>
Subject: Re: NAPI poll behavior in various Intel drivers
Date: Sat, 05 Jan 2008 14:29:05 +0100
Message-ID: <p738x348kpq.fsf@bingen.suse.de>
References: <477E92B6.8010809@katalix.com>
	<20080104.132443.25068269.davem@davemloft.net>
	<477ECCD7.8090905@katalix.com>
	<20080104.232504.238436937.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jchapman@katalix.com, netdev@vger.kernel.org,
	auke-jan.h.kok@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:45381 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754660AbYAEN3I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Jan 2008 08:29:08 -0500
In-Reply-To: <20080104.232504.238436937.davem@davemloft.net> (David Miller's message of "Fri\, 04 Jan 2008 23\:25\:04 -0800 \(PST\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: James Chapman <jchapman@katalix.com>
> Date: Sat, 05 Jan 2008 00:18:31 +0000
>
>> David Miller wrote:
>> > From: James Chapman <jchapman@katalix.com>
>> > Date: Fri, 04 Jan 2008 20:10:30 +0000
>> > 
>> >> With the latest NAPI, this code has to change. But rather than remove
>> >> the tx_cleaned logic completely, shouldn't transmit processing be
>> >> included in the work_done accounting when a driver does transmit cleanup
>> >> processing in the poll?
>> > 
>> > Most other NAPI drivers don't do this, they just process all the
>> > pending TX work unconditionally and do not account it into the NAPI
>> > poll work.
>> 
>> This will cause the interface to thrash in/out of polled mode very
>> quickly when it is doing almost all transmit work. That's something to
>> avoid, no?
>
> I see your point although I've never seen this in practice
> with tg3 or niu.

In 2.4 we used to have (haven't checked recently) performance regressions
with NAPI vs non NAPI (or versus the old BCM vendor driver) on tg3 for
some workloads that didn't fully fill the link. The theory was always
that the reason for that was something like the regular switching in
and out. So I think we saw that problem on tg3 too.

-Andi
