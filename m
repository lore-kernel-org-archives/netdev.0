From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH 00/16] Remove the ipv4 routing cache
Date: Fri, 27 Jul 2012 12:06:47 -0700
Message-ID: <CAKgT0UdydVv7yy-2AQ93aAKkNngC5dWwOnBS4GoDv6T84p4K4Q@mail.gmail.com>
References: <20120726.155327.947597248143903676.davem@davemloft.net>
	<CAKgT0UdhqDQSFZkWw9w8L2qsCS+MM_DLQE+Vq0mKcYZmxhs=8Q@mail.gmail.com>
	<20120726.200846.66786272076299783.davem@davemloft.net>
	<20120726.230246.219188476590178857.davem@davemloft.net>
	<1343383283.2626.12691.camel@edumazet-glaptop>
	<87boj15k8c.fsf@xmission.com>
	<1343401949.2626.13011.camel@edumazet-glaptop>
	<87mx2l41hl.fsf@xmission.com>
	<1343406533.2626.13104.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:50742 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752404Ab2G0TGr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jul 2012 15:06:47 -0400
Received: by vbbff1 with SMTP id ff1so3026028vbb.19
        for <netdev@vger.kernel.org>; Fri, 27 Jul 2012 12:06:47 -0700 (PDT)
In-Reply-To: <1343406533.2626.13104.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 27, 2012 at 9:28 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2012-07-27 at 09:23 -0700, Eric W. Biederman wrote:
>
>> I am familiar.  But does hardware prefetching make a difference
>> if your object is less than 64 bytes?
>>
>
> Apparently yes, if the prefetch touches a dirtied neighbour cache line.
>
>> I don't believe only allocating 64 bytes will be a problem,
>> as no one else well be dirtying your cache line.
>>
>> I suppose you could run into pathologies where your object
>> is 3*64 bytes in size, but your expression doesn't handle
>> that case either.
>>
>
> Sure, but in most cases fib objects are under 128 bytes.
>
>
>> The other alternative to guarantee very good cache behavior is
>> to ensure you are allocating a power of two size up to some limit,
>> perhaps page size.
>>
>
> Good idea.
>
>> My point is the magic 128 likely requires an explicatory comment and I
>> think the net result is you have encoded something fragile that is good
>> for testing but that will in the fullness of time do strange things that
>> will be easy to overlook.
>
> Sure, I'll send a v2, thanks.
>
>

I tested out v1 of your patch and didn't seem much of a change in my
test environment.  I figure I will spend most of today going through
the code trying to figure out what is causing the issues I am seeing
and why your changes had no effect on my setup.

Thanks,

Alex
