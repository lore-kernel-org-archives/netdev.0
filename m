From: Chris Snook <chris.snook@gmail.com>
Subject: Re: Fwd: a Great Idea - include Kademlia networking protocol in
 kernel -- REVISITED
Date: Mon, 15 Nov 2010 05:55:33 -0500
Message-ID: <AANLkTinSCz_VZFr=52wOqSfkz-fJfo=1OHSqSvEuZKV-@mail.gmail.com>
References: <AANLkTi=VgBQ5rwkjZeo2zsRx1dSBy+4PBXeLLPQ4LRES@mail.gmail.com>
 <AANLkTinWUmQ91cCULC8ZXFLwSKz6SNt3BpszrBEhbgcu@mail.gmail.com>
 <1289724643.2743.58.camel@edumazet-laptop> <AANLkTimkPpWob8ANySeWBvDE+Pq2wy4SQWJOSYzbS7QG@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Stephen Guerin <stephen@sfcomplex.org>
To: Marcos <stalkingtime@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:45387 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932067Ab0KOKzz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Nov 2010 05:55:55 -0500
Received: by wyb28 with SMTP id 28so4266852wyb.19
        for <netdev@vger.kernel.org>; Mon, 15 Nov 2010 02:55:54 -0800 (PST)
In-Reply-To: <AANLkTimkPpWob8ANySeWBvDE+Pq2wy4SQWJOSYzbS7QG@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 14, 2010 at 4:14 AM, Marcos <stalkingtime@gmail.com> wrote:
>> I have no idea why and how kademlia would be added to "linux kernel"
>>
>> Its a protocol based on UDP, and probably already done on userland.
>>
>> What am I missing ?
>
> The idea is to tightly couple it to the operating system to create a
> sort of "super operating system" that is seamless to the application
> layers above. =A0Just like memory stores are tightly integrated as to=
 be
> unnoticeable....

According to Google, you're not an experienced kernel developer, so
let me explain what happens when you take userspace code and implement
it in the kernel:

1) You restrict development of the feature to a specialized subset of C=
 only.
2) You lose the simple filesystem interface enjoyed by userspace.
3) You lose the simple memory allocation enjoyed by userspace.
4) You lose the BSD network socket interface enjoyed by userspace.
5) You lose the ability to call recursive functions such as quicksort.
6) You lose the ability to call nearly every library ever written.
7) You freeze your ABI, making it much more difficult to fix your
mistakes without breaking huge amounts of userspace code, which pisses
off users, though they'll also be pissed if you *don't* fix your
mistakes.
8) You make debugging 10x harder.
9) You piss off your users 100x more when it breaks.
10) You make any security holes in your code 1000x worse.

There are plenty more drawbacks, but I think I've made the point.  We
don't put things in the kernel unless userspace is inadequate.  In
fact, we've done a lot of work over the years to provide kernel
infrastructure to allow us to move things *out* of the kernel and into
userspace.  If you think this feature would benefit from
filesystem-level integration, try implementing it as a FUSE module.
At least then you'll be able to use libraries and the language of your
choice.  None of the drawbacks of FUSE relative to the core kernel
apply in this case, so if it doesn't work with FUSE, it certainly
won't work in the kernel.

-- Chris
