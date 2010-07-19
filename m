From: Tom Herbert <therbert@google.com>
Subject: Re: Very low latency TCP for clusters
Date: Mon, 19 Jul 2010 11:44:05 -0700
Message-ID: <AANLkTiniRmnwG4vT-MrQQHQjrdQ4sfOn6Uxi42Dsr8nu@mail.gmail.com>
References: <AANLkTilNmNZbFWS8LF-UHU65QYIC32HZlgVZ7lXJHxPh@mail.gmail.com>
	<1279561319.2553.153.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:14996 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966466Ab0GSSoK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jul 2010 14:44:10 -0400
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id o6JIi7fj010588
	for <netdev@vger.kernel.org>; Mon, 19 Jul 2010 11:44:08 -0700
Received: from pxi10 (pxi10.prod.google.com [10.243.27.10])
	by wpaz37.hot.corp.google.com with ESMTP id o6JIi6bn018822
	for <netdev@vger.kernel.org>; Mon, 19 Jul 2010 11:44:06 -0700
Received: by pxi10 with SMTP id 10so5729403pxi.2
        for <netdev@vger.kernel.org>; Mon, 19 Jul 2010 11:44:06 -0700 (PDT)
In-Reply-To: <1279561319.2553.153.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 19, 2010 at 10:41 AM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> Le lundi 19 juillet 2010 =E0 10:05 -0700, Tom Herbert a =E9crit :
>> We have been looking at best case TCP latencies that might be achiev=
ed
>> within a cluster (low loss fabric). =A0The goal is to have latency
>> numbers roughly comparable to that which can be produced using RDMA/=
IB
>> in a low latency configuration =A0(<5 usecs round trip on netperf TC=
P_RR
>> test with one byte data for directly connected hosts as a starting
>> point). =A0This would be without changing sockets API, fabric, and
>> preferably not using TCP offload or a user space stack.
>>
>> I think there are at least two techniques that will drive down TCP
>> latency: per connection queues and polling queues. =A0Per connection
>> queues (supported by device) should eliminate costs of connection
>> look-up, hopefully some locking. =A0Polling becomes viable as core
>> counts on systems increase, and burning a few CPUs for networking
>> polling on behalf of very low-latency threads would be reasonable.
>>
>> Are there any efforts in progress to integrate per connection queues
>> in the stack or integrate polling of queues?
>
> aka "net channel" ;)
>
I don't think this is the same.  I am thinking of a device that
supports multi-queue where individual queues can be programming to
accept an exact 4-tuple, from the device's point of view I don't think
there's much beyond that and it is otherwise treated as just another
packet queue.  However, kernel may be able to use it to shortcut some
processing.  I believe such functionality is already supported in
Intel's flow director and possibly by some other vendors.

> What a nightmare...
>
I prefer to think of it as challenge, needing to resort to stateful
offload to get low latency would be the nightmare ;-)

> Anyway, 5 us roundtrip TCP_RR (including user thread work), seems a b=
it
> utopic right now.
>
> Even on loopback
>

I see about 7 usecs as best number on loopback, so I believe this is
in the ballpark.  As I mentioned above, this about "best case" latency
of a single thread, so we assume any amount of pinning or other
customized configuration to that purpose.

>
>
>
