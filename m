From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: I can tell no FIB
Date: Thu, 05 Mar 2015 15:44:33 -0800
Message-ID: <54F8EA61.9010706@redhat.com>
References: <CAE4R7bBwrB8==aYuN9gYoADwZHDwr5zYjL3tL=jqPP24p74VUw@mail.gmail.com> <CAA93jw5oMK-KC-EkG71LKThqQxsHYcft+OHuu=APzjLdWSuO4g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Dave Taht <dave.taht@gmail.com>, Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45394 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753619AbbCEXoh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Mar 2015 18:44:37 -0500
In-Reply-To: <CAA93jw5oMK-KC-EkG71LKThqQxsHYcft+OHuu=APzjLdWSuO4g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 03/05/2015 01:01 PM, Dave Taht wrote:
> On Thu, Mar 5, 2015 at 12:49 PM, Scott Feldman <sfeldma@gmail.com> wrote:
>> Hi Alex, turns out you're required to take a mandatory week-long
>> vacation after your fourth patch set to net/ipv4/fib_*.  See you in a
>> week!  Take lots of pictures.
> +10!
>
> Is anyone here working on testing the new FIB stuff on itty bitty 32
> bit platforms? It looks really promising
> but openwrt is stabilizing on 3.18 and the prospect of backporting all
> this stuff to that to test at scale is intimidating. (*I* am willing
> to wait for 4.2)
>
> But boy, could openwrt test at scale:
>
> https://downloads.openwrt.org/snapshots/trunk/

As far as what to backport I would recommend only targeting the FIB 
changes that went into 4.0.  It was low risk for causing regressions and 
significant benefit.  This is why I referred to them as "low hanging 
fruit" when I described them  in my presentation at Netdev 0.1.  The 
stuff that went into 4.0 reduced things by hundreds of nanosecnds in 
some cases, the stuff targeting net-next/4.1 is only going to reduce 
things by tens of nanoseconds.

What I am working on now is basically just trying squeeze the last bits 
of performance out of what is left.    Excluding the main/local merge I 
have been able to remove 20% (10 - 35ns depending on the test) of the 
remaining CPU overhead for the fib table look-up with what has been 
submitted since net-next reopened.  The local/main trie merge pushes 
that to somewhere around a 40% reduction from what I have seen.

- Alex
