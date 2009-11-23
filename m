From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: Strange CPU load when flushing route cache (kernel 2.6.31.6)
Date: Mon, 23 Nov 2009 14:48:05 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0911231437020.24347@ask.diku.dk>
References: <1258970332.29747.262.camel@jdb-workstation>  <4B0A63FA.5000804@gmail.com>
 <1258979320.29747.270.camel@jdb-workstation> <4B0A8D41.6010608@gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-511516320-386678058-1258984085=:24347"
Cc: Jesper Dangaard Brouer <hawk@comx.dk>,
	Linux Kernel Network Hackers <netdev@vger.kernel.org>,
	Robert Olsson <robert@herjulf.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw1.diku.dk ([130.225.96.91]:52232 "EHLO mgw1.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750827AbZKWNsB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Nov 2009 08:48:01 -0500
In-Reply-To: <4B0A8D41.6010608@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---511516320-386678058-1258984085=:24347
Content-Type: TEXT/PLAIN; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: 8BIT

On Mon, 23 Nov 2009, Eric Dumazet wrote:

> Jesper Dangaard Brouer a écrit :
>> On Mon, 2009-11-23 at 11:29 +0100, Eric Dumazet wrote:
>
>>> Sure, after a flush, we have to rebuild the cache, so extra work is expected.
>>
>> But the old 2.6.25.7 do NOT show this behavior... That is the real
>> issue...
>
> Previous kernels were crashing, because flush was immediate and not deferred
> as today.
>
> During flush, we were dropping enormous amounts of packets.

Ahh... Now I remember that was why I was flushing the cache so often.  If 
I flushed the route cache before it got too big then it was not a 
problem with packet drops occuring.


> Now, its possible to have setups with equilibrium and no packet loss,
> because we smoothtly invalidate cache entries.

Which is a good thing :-)


>> I did the cache flushing due to some historical issues, that I think you
>> did a fix for... Guess I can drop the flushing and see if the garbage
>> collection can keep up...
>
> Yes it can. Unless your route cache settings are not optimal.

I'll adjust my flushing interval, or disable it and monitor it.


>>> Do you run a 2G/2G User/Kernel split kernel ?
>>
>> Not sure, how do I check?
>
> grep LowTotal /proc/meminfo

Yes, guess I'm using User/Kernel split.

grep LowTotal /proc/meminfo
LowTotal:         747080 kB

What does that mean?  Is it bad? What should I run on a 32-bit 
system/kernel?


Can you recommend any other /proc/sys/ tuning options?

Does my kernel boot option rhash_entries=262143 make sense anymore?
Or do we adjust the hash bucket size dynamically these days?

Cheers,
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
---511516320-386678058-1258984085=:24347--
