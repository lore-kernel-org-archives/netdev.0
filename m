From: Tom Herbert <therbert@google.com>
Subject: Re: Very low latency TCP for clusters
Date: Mon, 19 Jul 2010 16:37:59 -0700
Message-ID: <AANLkTillCVWMHHBImGEeRYy2MJYqtGIvSPvacLKJnpP2@mail.gmail.com>
References: <AANLkTilNmNZbFWS8LF-UHU65QYIC32HZlgVZ7lXJHxPh@mail.gmail.com>
	<1279561319.2553.153.camel@edumazet-laptop>
	<AANLkTiniRmnwG4vT-MrQQHQjrdQ4sfOn6Uxi42Dsr8nu@mail.gmail.com>
	<1279576980.2458.56.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:8731 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754522Ab0GSXiE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jul 2010 19:38:04 -0400
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id o6JNc1Am023731
	for <netdev@vger.kernel.org>; Mon, 19 Jul 2010 16:38:01 -0700
Received: from pxi2 (pxi2.prod.google.com [10.243.27.2])
	by kpbe17.cbf.corp.google.com with ESMTP id o6JNbx3D007812
	for <netdev@vger.kernel.org>; Mon, 19 Jul 2010 16:38:00 -0700
Received: by pxi2 with SMTP id 2so3348196pxi.10
        for <netdev@vger.kernel.org>; Mon, 19 Jul 2010 16:37:59 -0700 (PDT)
In-Reply-To: <1279576980.2458.56.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 19, 2010 at 3:03 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le lundi 19 juillet 2010 =E0 11:44 -0700, Tom Herbert a =E9crit :
>
>> I see about 7 usecs as best number on loopback, so I believe this is
>> in the ballpark. =A0As I mentioned above, this about "best case" lat=
ency
>> of a single thread, so we assume any amount of pinning or other
>> customized configuration to that purpose.
>
> Well, given I get 29 us on a ping between two machines (Gb link, no
> process involved on receiver, only softirq), I really doubt we can re=
ach
> 5 us on a tcp test involving a user process on both side ;)
>
That's pretty pokey ;-) I see numbers around 25 usecs between to
machines, this is with TCP_NBRR.  With TCP_RR it's more like 35 usecs,
so eliminating the scheduler is already a big reduction.  That leaves
18 usecs in device time, interrupt processing, network, and cache
misses; 7 usecs in TCP processing, user space.  While 5 usecs is an
aggressive goal, I am not ready to concede that there's an
architectural limit in either NICs, TCP, or sockets that can't be
overcome.
