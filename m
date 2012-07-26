From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH 00/16] Remove the ipv4 routing cache
Date: Thu, 26 Jul 2012 10:18:03 -0700
Message-ID: <CAKgT0UfYEBYQOAoZ77rtwctbwau=2kx4rYdTyeaPaipeMUP9aw@mail.gmail.com>
References: <1343290414.2626.11181.camel@edumazet-glaptop>
	<20120726.011853.973075299731735416.davem@davemloft.net>
	<1343291278.2626.11188.camel@edumazet-glaptop>
	<20120726.014736.1066206957795563053.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:54295 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752060Ab2GZRSF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2012 13:18:05 -0400
Received: by vbbff1 with SMTP id ff1so1878780vbb.19
        for <netdev@vger.kernel.org>; Thu, 26 Jul 2012 10:18:03 -0700 (PDT)
In-Reply-To: <20120726.014736.1066206957795563053.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 26, 2012 at 1:47 AM, David Miller <davem@davemloft.net> wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 26 Jul 2012 10:27:58 +0200
>
>> But isnt DST_NOCACHE intent reverted then ?
>>
>> like you meant :
>>
>> +       } else {
>> +               /* Routes we intend to cache in the FIB nexthop have
>> +                * the DST_NOCACHE bit unset.  However, if we are
>> +                * unsuccessful at storing this route into the cache
>> +                * we really need to set that bit.
>> +                */
>> +               rt->dst.flags |= DST_NOCACHE;
>>         }
>
> Indeed, thanks for catching this bug.
>
> Here's a new version of the patch, as I found another error.  In
> fib_semantics.c, we have to change dst_release() to dst_free() for the
> liberation the nexthop cached routes.

I tested this patch and it looks like it runs, but still has the same
performance issue.  I did some digging into the annotation for
ip_route_intput_noref and it seems like the issue is that I am hitting
the dst_hold call in  __mkroute_input.

You were correct about the ARP entry.  It looks like I had messed up
my test script and it wasn't putting the static ARP entry back in.
I'm amazed it was even working since my SmartBits system doesn't
normally even reply to ARPs.

Thanks,

Alex
