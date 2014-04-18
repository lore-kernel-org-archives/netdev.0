From: Sharat Masetty <sharat04@gmail.com>
Subject: Re: Question on Lockless TX
Date: Fri, 18 Apr 2014 14:32:53 -0600
Message-ID: <CAJzFV351AoqC6_i0fz1yMNOqCS146issDhcN5D7Gkd4zYC3riA@mail.gmail.com>
References: <CAJzFV37OPJVVx3rO=L9RRZFn8NajiR1HZuZEZ8M3SepXTsMQ6A@mail.gmail.com>
	<CA+mtBx-m2zZfZ3AQOkv=4St2bWpipEEY0+O7kAJtReCa6ZkizA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:34613 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751197AbaDRUcy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2014 16:32:54 -0400
Received: by mail-wi0-f170.google.com with SMTP id bs8so1403471wib.5
        for <netdev@vger.kernel.org>; Fri, 18 Apr 2014 13:32:53 -0700 (PDT)
In-Reply-To: <CA+mtBx-m2zZfZ3AQOkv=4St2bWpipEEY0+O7kAJtReCa6ZkizA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I think this flag will work for our case, but in the documentation
section it says
"Note that the use of NETIF_F_LLTX is deprecated.  Don't use it for
new drivers." Trying to dig into this a little more but not sure why
this deprecated and should not be used.. can you shed some light here?
Are there any known issues with this flag?

I did see this thread from a while back:
https://lwn.net/Articles/121566/ but issue seems to be fairly
contained..

Regards,
Sharat


On Wed, Apr 16, 2014 at 10:51 AM, Tom Herbert <therbert@google.com> wrote:
> On Tue, Apr 15, 2014 at 9:29 PM, Sharat Masetty <sharat04@gmail.com> wrote:
>> Can someone explain to me, why would a driver choose to implement
>> Lockless TX? What are the advantages/disadvantages of choosing to do
>> so?Any performance benefits? A reference to a sample driver
>> implementation would be helpful to understand.
>>
> Locks in the TX path are needed provide mutual exclusion to the
> underlying HW queue and other structures. Some drivers either don't
> need any form of locking because their is no queue to protect (often
> the case with virtual drivers like loopback and bonding), others might
> provide their own locking at higher granularity or for other purposes.
> Generally, taking fewer locks can reduce lock contention, atomic
> operations, and cache line misses. If you grep for NETIF_F_LLTX under
> drivers/net you can find examples of drivers that support this. Also,
> please look at Documentation/networking/netdevices.txt.
>
> Tom
>
>> Thanks
>> Sharat
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
