From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: tbf/htb qdisc limitations
Date: Sun, 10 Oct 2010 13:23:23 +0200
Message-ID: <4CB1A22B.9090701@gmail.com>
References: <AANLkTik6_C5pzx=yS=C0VQR2xfg0S57AZAn9WYiGvxe5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Steven Brudenell <steven.brudenell@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:65494 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752547Ab0JJLX3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Oct 2010 07:23:29 -0400
Received: by wwj40 with SMTP id 40so2723429wwj.1
        for <netdev@vger.kernel.org>; Sun, 10 Oct 2010 04:23:27 -0700 (PDT)
In-Reply-To: <AANLkTik6_C5pzx=yS=C0VQR2xfg0S57AZAn9WYiGvxe5@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Steven Brudenell wrote:
> hi folks,
> 
> i was disappointed recently to find that i can't set the "burst"
> parameters very high on the tbf or htb qdiscs. the actual limit of the
> burst parameters varies, according to the rate parameter. at the
> relatively low rate i want to set, i want to have the burst parameter
> be several gigabytes, but i'm actually limited to only a few
> megabytes.
> 
> (motivation: a fully-automated way to stay inside the monthly transfer
> limits imposed by many ISPs these days, without resorting to a
> constant rate limit. for example, comcast limits its customers to
> 250GB/month, which is about 101KB/s; many cellular data plans in the
> US limit to 5GB/month =~ 2KB/s).

I'm not sure you checked how the "burst" works, and doubt it could
help you here. Anyway, do you think: rate 2KB/s with burst 5GB
config would be useful for you?

> 
> i'll gladly code a patch, but i'd like the list's advice on whether
> this is necessary, and a little bit about how to proceed:
> 
> 1) what is the purpose of the "rate tables" used in these qdiscs --
> why use them in favor of dividing bytes by time to compute a rate? i
> assume the answer has something to do with restrictions on using
> floating point math (maybe even integer division?) at different places
> / interruptability states in the kernel. maybe this is documented on
> kernelnewbies somewhere but i couldn't find it.
> 
> 2) is there an established procedure for versioning a netlink
> interface? today the netlink interface for tbf and htb is horribly
> implementation-coupled (the "burst" parameters need to be munged
> according to the "rate" parameters and kernel tick rate). i think i
> would need to change these interfaces in order to change the
> accounting implementation in the corresponding qdisc. however, i
> probably want to remain compatible with old userspace.

My proposal is you don't bother with 1) and 2), but first do the
hack in tbf or htb directly, using or omitting rate tables, how
you like, and test this idea.

But it seems the right way is to collect monthly stats with some
userspace tool and change qdisc config dynamically. You might
look at network admins' lists for small ISPs exemplary scripts
doing such nasty things to their users, or have a look at ppp
accounting tools.
 
Jarek P.
