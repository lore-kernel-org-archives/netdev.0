From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: network namespace bloat
Date: Tue, 10 Feb 2015 21:18:13 -0600
Message-ID: <87d25hrv9m.fsf@x220.int.ebiederm.org>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
	<87k2zubw7l.fsf@x220.int.ebiederm.org>
	<871tlxtbhd.fsf_-_@x220.int.ebiederm.org>
	<CANn89iJ2auNoChr3FuFh-AGaPaw5_wwqfjZrtup1+xu6reVHMA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	roopa <roopa@cumulusnetworks.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Dinesh Dutt <ddutt@cumulusnetworks.com>,
	Vipin Kumar <vipin@cumulusnetworks.com>,
	Shmulik Ladkani <shmulik.ladkani@gmail.com>,
	David Ahern <dsahern@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:54326 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751368AbbBKDV5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 22:21:57 -0500
In-Reply-To: <CANn89iJ2auNoChr3FuFh-AGaPaw5_wwqfjZrtup1+xu6reVHMA@mail.gmail.com>
	(Eric Dumazet's message of "Tue, 10 Feb 2015 18:55:39 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <edumazet@google.com> writes:

> On Tue, Feb 10, 2015 at 6:42 PM, Eric W. Biederman
> <ebiederm@xmission.com> wrote:
>
>>
>> Those large hash tables impact creation speed as large memory
>> allocations require more work from the memory allocators, and they
>> affect reliability of as order > 0 pages are not reliabily available in
>> the kernel.  So from a network namespace perspective I would really like
>> to convert the per network namespace hash tables to hash tables that
>> have a single instance across all network namespaces.
>>
>
> tcp_metric can fallback to vzalloc() after commit 976a702ac9eea ?

True, although vmalloc space is limited on some architectures.

> There is nothing preventing to use a single tcp_metric, a bit like
> global TCP hash table.
>
> We only have to convert the thing...

Thanks for the confirmation, that is what I figured was going on.

> Note : At Google we do not save tcp metrics.
> We have to use it only for FastOpen cookies eventually (For clients)

Interesting.  That makes it doubly desirable to not need to allocate
a per network namespace hash table.

Eric
