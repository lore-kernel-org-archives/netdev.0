From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Kernel panic in inet_twdr_do_twkill_work
Date: Thu, 14 May 2009 01:18:53 -0700
Message-ID: <m1y6t0nlle.fsf@fess.ebiederm.org>
References: <m17i0ktr4p.fsf@fess.ebiederm.org> <4A0BCE0E.3000206@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "Denis V. Lunev" <den@openvz.org>
To: Daniel Lezcano <daniel.lezcano@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:51116 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751423AbZENIS6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2009 04:18:58 -0400
In-Reply-To: <4A0BCE0E.3000206@free.fr> (Daniel Lezcano's message of "Thu\, 14 May 2009 09\:53\:50 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Lezcano <daniel.lezcano@free.fr> writes:

> Eric W. Biederman wrote:
>> So far I have only seen this twice.  But the backtrace looks
>> almost identical to the one in commit d315492b1a6ba29da0fa2860759505ae1b2db857
>>
>> The kernels I saw this on were patched version of 2.6.28 with some
>> network namespace backports.  commit
>> d315492b1a6ba29da0fa2860759505ae1b2db857 was definitely present.
>>
>> Daniel any ideas?
>>   
> Hi Eric,
>
> I found this one. May be it could be related to your problem:
>
> commit 2bad35b7c9588eb5e65c03bcae54e7eb6b1a6504
>
> Let me know :)

"netns: oops in ip[6]_frag_reasm incrementing stats" does not look likely.

There is no real ipv6 traffic currently on the our network and the panic
is definitely in inet_twdr_do_twkill_work.

Further we are getting the net of a timewait socket.  So I don't see how
a problem with NULL devs could have anything to do with it.

I really suspect the purge code is not being successful.

Eric

