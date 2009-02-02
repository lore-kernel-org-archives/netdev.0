From: Wes Chow <wchow@athenacr.com>
Subject: Re: Multicast packet loss
Date: Mon, 02 Feb 2009 16:09:33 -0500
Message-ID: <4987610D.6040902@athenacr.com>
References: <49833DBC.7040607@athenacr.com> <20090130200330.GA12659@hmsreliant.think-freely.org> <49837F56.2020502@athenacr.com> <49838213.90700@cosmosbay.com> <49859847.9010206@cosmosbay.com> <20090202134523.GA13369@hmsreliant.think-freely.org> <498725F4.2010205@cosmosbay.com> <20090202182212.GA17950@hmsreliant.think-freely.org> <loom.20090202T194942-55@post.gmane.org> <498757AA.8010101@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from li36-253.members.linode.com ([207.192.72.253]:54909 "EHLO
	shablam.senortoad.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753569AbZBBVUc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2009 16:20:32 -0500
In-Reply-To: <498757AA.8010101@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Eric Dumazet wrote:
> Wes Chow a =E9crit :
>> (I'm Kenny's colleague, and I've been doing the kernel builds)
>>
>> First I'd like to note that there were a lot of bnx2 NAPI changes be=
tween=20
>> 2.6.21 and 2.6.22. As a reminder, 2.6.21 shows tiny amounts of packe=
t loss,
>> whereas loss in 2.6.22 is significant.
>>
>> Second, some CPU affinity info: if I do like Eric and pin all of the
>> apps onto a single CPU, I see no packet loss. Also, I do *not* see
>> ksoftirqd show up on top at all!
>>
>> If I pin half the processes on one CPU and the other half on another=
 CPU, one=20
>> ksoftirqd processes shows up in top and completely pegs one CPU. My =
packet loss
>> in that case is significant (25%).
>>
>> Now, the strange case: if I pin 3 processes to one CPU and 1 process=
 to=20
>> another, I get about 25% packet loss and ksoftirqd pins one CPU. How=
ever, one
>> of the apps takes significantly less CPU than the others, and all ap=
ps lose the
>> *exact same number of packets*. In all other situations where we see=
 packet
>> loss, the actual number lost per application instance appears random=
=2E
>=20
> You see same number of packet lost because they are lost at NIC level

Understood.

I have a new observation: if I pin processes to just CPUs 0 and 1, I se=
e=20
no packet loss. Pinning to 0 and 2, I do see packet loss. Pinning 2 and=
=20
3, no packet loss. 4 & 5 - no packet loss, 6 & 7 - no packet loss. Any=20
other combination appears to produce loss (though I have not tried all=20
28 combinations, this seems to be the case).

At first I thought maybe it had to do with processes pinned to the same=
=20
CPU, but different cores. The machine is a dual quad core, which means=20
that CPUs 0-3 should be a physical CPU, correct? Pinning to 0/2 and 0/3=
=20
produce packet loss.

I've also noticed that it does not matter which of the working pairs I=20
pin to. For example, pinning 5 processes in any combination on either=20
0/1 produce no packet loss, pinning all 5 to just CPU 0 also produces n=
o=20
packet loss.

The failures are also sudden. In all of the working cases mentioned=20
above, I don't see ksoftirqd on top at all. But when I run 6 processes=20
on a single CPU, ksoftirqd shoots up to 100% and I lose a huge number o=
f=20
packets.

>=20
> Normaly, softirq runs on same cpu (the one handling hard irq)

What determines which CPU the hard irq occurs on?


Wes

