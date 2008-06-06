From: Patrick McManus <mcmanus@ducksong.com>
Subject: Re: [fixed] [patch] Re: [bug] stuck localhost TCP connections,
	v2.6.26-rc3+
Date: Fri, 06 Jun 2008 13:11:33 -0400
Message-ID: <1212772293.23706.22.camel@tng>
References: <20080603094057.GA29480@elte.hu>
	 <Pine.LNX.4.64.0806032245490.3474@wrl-59.cs.helsinki.fi>
	 <Pine.LNX.4.64.0806040052270.3474@wrl-59.cs.helsinki.fi>
	 <20080603.150344.145518113.davem@davemloft.net>
	 <Pine.LNX.4.64.0806040208350.7315@wrl-59.cs.helsinki.fi>
	 <20080605142244.GA19216@elte.hu>
	 <Pine.LNX.4.64.0806052059380.31672@wrl-59.cs.helsinki.fi>
	 <Pine.LNX.4.64.0806052355420.2522@wrl-59.cs.helsinki.fi>
	 <1212708571.19522.10.camel@tng>
	 <Pine.LNX.4.64.0806061248410.16829@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, David Miller <davem@davemloft.net>,
	peterz@infradead.org, LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>, rjw@sisk.pl,
	Andrew Morton <akpm@linux-foundation.org>, johnpol@2ka.mipt.ru
To: Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from linode.ducksong.com ([64.22.125.164]:56950 "EHLO
	linode.ducksong.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753066AbYFFRL0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2008 13:11:26 -0400
In-Reply-To: <Pine.LNX.4.64.0806061248410.16829@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> This Ingo's testcase should anyway be quite "simple", I mean that distcc 
> shouldn't do anything unexpected in a sense it shouldn't abort the flows 
> by not sending data, close the listening socket or other things like that.
> 

maybe - I've noted that I can get the distcc server to crash with just a
little fuzz (telnet to it and close the telnet) - but it is true I
haven't seen anything odd using the distcc client.

Anyhow, my news is that using rc5 I have managed to reproduce it on
localhost - so it isn't just ingo anymore ! ;)

I didn't have a 16 cpu machine at my disposal, so I was concerned I
wouldn't be able to make it happen - but I setup a 64 bit kvm image with
-smp 4, running on my core2-duo and created a makefile with 3 src files
that I just compiled as "while true; do make -j3 all; done" - the
makefile uses distcc to localhost and has intentionally broken
dependencies so it just keeps recompiling stuff. The input files are
approximately 135k, 98k, and 16k after running gcc -E on them (which I
what I assume distcc does before putting them down the socket).

On rc5 I could get the lockup in under 20 minutes.. usually 10. I think
I did it 4 times. My compile test is probably a better trigger than the
kernel compile because the distcc connects are never staggered like they
would be in a large directory of files. (3 files, -j4).

When I apply the locking patch you (Ilpo) wrote, I cannot reproduce the
error at all in the first 90 minutes of testing. I'll let the test run
and update the list.

I'm holding out hope that Ingo's report did not have the locking patch
on the distcc server end - because it certainly makes a difference for 
me.

-Patrick

