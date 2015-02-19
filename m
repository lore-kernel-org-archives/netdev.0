From: David Miller <davem@davemloft.net>
Subject: Re: network namespace bloat
Date: Thu, 19 Feb 2015 14:49:29 -0500 (EST)
Message-ID: <20150219.144929.1003473344851168804.davem@davemloft.net>
References: <871tlxtbhd.fsf_-_@x220.int.ebiederm.org>
	<CANn89iJ2auNoChr3FuFh-AGaPaw5_wwqfjZrtup1+xu6reVHMA@mail.gmail.com>
	<87d25hrv9m.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org,
	stephen@networkplumber.org, nicolas.dichtel@6wind.com,
	roopa@cumulusnetworks.com, hannes@stressinduktion.org,
	ddutt@cumulusnetworks.com, vipin@cumulusnetworks.com,
	shmulik.ladkani@gmail.com, dsahern@gmail.com
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56781 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752387AbbBSTtd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2015 14:49:33 -0500
In-Reply-To: <87d25hrv9m.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Tue, 10 Feb 2015 21:18:13 -0600

> Eric Dumazet <edumazet@google.com> writes:
> 
>> On Tue, Feb 10, 2015 at 6:42 PM, Eric W. Biederman
>> <ebiederm@xmission.com> wrote:
>>
>>>
>>> Those large hash tables impact creation speed as large memory
>>> allocations require more work from the memory allocators, and they
>>> affect reliability of as order > 0 pages are not reliabily available in
>>> the kernel.  So from a network namespace perspective I would really like
>>> to convert the per network namespace hash tables to hash tables that
>>> have a single instance across all network namespaces.
>>>
>>
>> tcp_metric can fallback to vzalloc() after commit 976a702ac9eea ?
> 
> True, although vmalloc space is limited on some architectures.
> 
>> There is nothing preventing to use a single tcp_metric, a bit like
>> global TCP hash table.
>>
>> We only have to convert the thing...
> 
> Thanks for the confirmation, that is what I figured was going on.
> 
>> Note : At Google we do not save tcp metrics.
>> We have to use it only for FastOpen cookies eventually (For clients)
> 
> Interesting.  That makes it doubly desirable to not need to allocate
> a per network namespace hash table.

As a first step we can make the tcp_metrics hash global, but in addition
to that an rhashtable conversion is probably in order as well.
