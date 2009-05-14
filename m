From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: Kernel panic in inet_twdr_do_twkill_work
Date: Thu, 14 May 2009 10:33:20 +0200
Message-ID: <4A0BD750.4030605@free.fr>
References: <m17i0ktr4p.fsf@fess.ebiederm.org> <4A0BCE0E.3000206@free.fr> <m1y6t0nlle.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Denis V. Lunev" <den@openvz.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.17.162]:49684 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753362AbZENIdY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2009 04:33:24 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.13.1/8.13.1) with ESMTP id n4E8XP5A017952
	for <netdev@vger.kernel.org>; Thu, 14 May 2009 08:33:25 GMT
Received: from d12av03.megacenter.de.ibm.com (d12av03.megacenter.de.ibm.com [9.149.165.213])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n4E8XOgD4403306
	for <netdev@vger.kernel.org>; Thu, 14 May 2009 10:33:24 +0200
Received: from d12av03.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av03.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n4E8XOv9025170
	for <netdev@vger.kernel.org>; Thu, 14 May 2009 10:33:24 +0200
In-Reply-To: <m1y6t0nlle.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric W. Biederman wrote:
> Daniel Lezcano <daniel.lezcano@free.fr> writes:
>
>   
>> Eric W. Biederman wrote:
>>     
>>> So far I have only seen this twice.  But the backtrace looks
>>> almost identical to the one in commit d315492b1a6ba29da0fa2860759505ae1b2db857
>>>
>>> The kernels I saw this on were patched version of 2.6.28 with some
>>> network namespace backports.  commit
>>> d315492b1a6ba29da0fa2860759505ae1b2db857 was definitely present.
>>>
>>> Daniel any ideas?
>>>   
>>>       
>> Hi Eric,
>>
>> I found this one. May be it could be related to your problem:
>>
>> commit 2bad35b7c9588eb5e65c03bcae54e7eb6b1a6504
>>
>> Let me know :)
>>     
>
> "netns: oops in ip[6]_frag_reasm incrementing stats" does not look likely.
>
> There is no real ipv6 traffic currently on the our network and the panic
> is definitely in inet_twdr_do_twkill_work.
>
> Further we are getting the net of a timewait socket.  So I don't see how
> a problem with NULL devs could have anything to do with it.
>
> I really suspect the purge code is not being successful.
>   
May be you can activate the NETNS_REFCNT_DEBUG in order to check if the 
timewait socket
were destroyed at the namespace destruction ? Unfortunately it looks 
like the option is not in the Kconfig :(
