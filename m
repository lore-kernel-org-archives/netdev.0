From: starlight@binnacle.cx
Subject: Re: big picture UDP/IP performance question re 2.6.18
  -> 2.6.32
Date: Mon, 03 Oct 2011 12:28:13 -0400
Message-ID: <6.2.5.6.2.20111003121925.03a83a28@binnacle.cx>
References: <6.2.5.6.2.20111003112108.03a83a28@binnacle.cx>
 <1317658588.2442.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <1317658588.2442.5.camel@edumazet-HP-Compaq-6005-Pro
 -SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Willy Tarreau <w@1wt.eu>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.binnacle.cx ([74.95.187.105]:59503 "EHLO mx.binnacle.cx"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751640Ab1JCQmd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Oct 2011 12:42:33 -0400
In-Reply-To: <1317658588.2442.5.camel@edumazet-HP-Compaq-6005-Pro
 -SFF-PC>
References: <6.2.5.6.2.20111003112108.03a83a28@binnacle.cx>
 <1317658588.2442.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At 06:16 PM 10/3/2011 +0200, Eric Dumazet wrote:
>> >Please send full "dmesg" output 
>> 
>> Attached.
>> 
>
>Minor note :
>
>It seems you use 4096 2MB hugepages, and your
>machine has 1GB pages availabe, you could
>try to use them.
>
>(boot cmd : hugepagesz=1GB hugepages=8 )

Interesting.  I'll give it a try for sure, but
since hugepages only gives a 5% improvement
taking the page size up probably will not
dent it by more than an additional percent
or so.

BTW I goofed on the kernel version number in my
last post.  It should be 2.6.39.4.  That .27 was
my mind transposing the 2.6.32 sub-version
onto 2.6.39.

Have one closing thought, which is to wonder if the

    9.98% swapper [kernel.kallsyms]  [k] native_safe_halt

CPU is included in the 2.6.18(rhel) CPU accounting
or not.  If it's excluded that would make 2.6.39.4
look much better--possibly put it at near parity
though I'm too lazy to do the math just now.

My guess is that this number is something of an
artifact of the clock-tick CPU histogram logic.
Perhaps it's seeing the IP register parked in the
idle-loop HALT instruction some of the time and
counting it as non-idle time.  I'd be happier if
it either counted all idle time and showed the
45% that the poll=idle run shows, or none of
the idle time at all--if it is in fact idle time.

Unfortunately 'perf' is not available for
2.6.18(rhel) so the value cannot be compared.
