From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Problem with tun driver
Date: Thu, 16 Sep 2010 06:16:32 -0700
Message-ID: <m1iq256d73.fsf@fess.ebiederm.org>
References: <AANLkTinzLJia4WV-GUse0sX=3Ht8DrD-vVd3YkxUE8xO@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: =?utf-8?Q?Mart=C3=ADn?= Ferrari <martin.ferrari@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:35433 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754157Ab0IPNQh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Sep 2010 09:16:37 -0400
In-Reply-To: <AANLkTinzLJia4WV-GUse0sX=3Ht8DrD-vVd3YkxUE8xO@mail.gmail.com>
	(=?utf-8?Q?=22Mart=C3=ADn?= Ferrari"'s message of "Thu, 16 Sep 2010
 10:30:42 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mart=C3=ADn Ferrari <martin.ferrari@gmail.com> writes:

> (copying Eric as he seems to have been writing patches for tun to wor=
k
> with netns)
>
> Hello,
>
> I am seeing a strange behaviour with the TUN driver when using it
> inside a network name space, hope that somebody can help me...
>
> I still couldn' t reproduce this problem outside of my program, so it
> complicates things more. What I am doing is creating a tap device,
> moving it into a namespace and then passing the filedescriptor to
> another process which in turn starts reading from it.
>
> From strace I see that many reads succeed (Ipv6 autoconfig and arp
> requests), and at some point, read returns EBADF. I don't see the
> other processes doing anything suspicious on it at the same time. Fro=
m
> reading the kernel sources, it seems to be failing the call to
> tun_get(), but I don' t understand how that could be happening...

Is it possible all of the processes in the network namespace you have
passed the tun dev into are dying, and thus destroying the network
namespace the tun dev is in?

It sounds like you are dealing with the network namespace death case,
or that someone is closing your filedescriptor on you.

Eric
