From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [BUG?] the first bind() of an AF_PACKET socket to an interface
 is slow
Date: Mon, 31 Mar 2014 22:16:27 +0200
Message-ID: <5339CD1B.7040708@redhat.com>
References: <CAG-2HqXW+ULp_K-873+DG3T_4FxcxaSy5aGQ+wf6P9m=015zgQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Kay Sievers <kay@vrfy.org>
To: Tom Gundersen <teg@jklm.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:65071 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750821AbaCaUQh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Mar 2014 16:16:37 -0400
In-Reply-To: <CAG-2HqXW+ULp_K-873+DG3T_4FxcxaSy5aGQ+wf6P9m=015zgQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/31/2014 08:43 PM, Tom Gundersen wrote:
> Hi,
>
> I'm observing some strange behavior using bind().
>
> For any given process, and any given interface, the first time I bind
> a socket to the interface it takes a very long time. Subsequent binds
> to the same interface in the same process are instantaneous.
>
> The time it takes seems independent of the interface, so also affects
> the loopback interface, but binding to all interfaces (ifindex=0) is
> instantaneous.
>
> It is also peculiar to note that the time it takes to bind is
> seemingly randomly chosen on my machine from 9ms, 19ms, 29ms, 39ms,
> 49ms and 59 ms, but I never observed any other values.
>
> The attached test program illustrates the problem, binding to
> ifindex=0 (all) and ifindex=1 (loopback).
>
> Sample run:
> # strace -f -T -ebind ./bind
> bind(3, {sa_family=AF_PACKET, proto=0x800, if0, pkttype=0x40 /* ? */,
> addr(6)={1328, ffffffffffff}, 20) = 0 <0.000036>
> bind(3, {sa_family=AF_PACKET, proto=0x800, if0, pkttype=0x40 /* ? */,
> addr(6)={1328, ffffffffffff}, 20) = 0 <0.000033>
> bind(3, {sa_family=AF_PACKET, proto=0x800, if1, pkttype=0x40 /* ? */,
> addr(6)={1328, ffffffffffff}, 20) = 0 <0.059706>
> bind(3, {sa_family=AF_PACKET, proto=0x800, if1, pkttype=0x40 /* ? */,
> addr(6)={1328, ffffffffffff}, 20) = 0 <0.000111>
>
>
> Can anyone enlighten me to what is going on? Is this expected behavior
> or a bug? Any suggestions for a work-around?

Expected behaviour as you can save in some cases a synchronize_net() call:

https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=902fefb82ef72a50c78cb4a20cc954b037a98d1c

> Cheers,
>
> Tom
>
