From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [fixed] [patch] Re: [bug] stuck localhost TCP connections,
 v2.6.26-rc3+
Date: Fri, 6 Jun 2008 21:25:42 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0806062020270.9424@wrl-59.cs.helsinki.fi>
References: <20080603094057.GA29480@elte.hu>  <Pine.LNX.4.64.0806032245490.3474@wrl-59.cs.helsinki.fi>
  <Pine.LNX.4.64.0806040052270.3474@wrl-59.cs.helsinki.fi>
 <20080603.150344.145518113.davem@davemloft.net>
 <Pine.LNX.4.64.0806040208350.7315@wrl-59.cs.helsinki.fi>  <20080605142244.GA19216@elte.hu>
  <Pine.LNX.4.64.0806052059380.31672@wrl-59.cs.helsinki.fi>
 <Pine.LNX.4.64.0806052355420.2522@wrl-59.cs.helsinki.fi>  <1212708571.19522.10.camel@tng>
  <Pine.LNX.4.64.0806061248410.16829@wrl-59.cs.helsinki.fi>
 <1212772293.23706.22.camel@tng>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, David Miller <davem@davemloft.net>,
	peterz@infradead.org, LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>, rjw@sisk.pl,
	Andrew Morton <akpm@linux-foundation.org>, johnpol@2ka.mipt.ru
To: Patrick McManus <mcmanus@ducksong.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:37154 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755455AbYFFSZp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2008 14:25:45 -0400
In-Reply-To: <1212772293.23706.22.camel@tng>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 6 Jun 2008, Patrick McManus wrote:

> > This Ingo's testcase should anyway be quite "simple", I mean that distcc 
> > shouldn't do anything unexpected in a sense it shouldn't abort the flows 
> > by not sending data, close the listening socket or other things like that.
> 
> maybe - I've noted that I can get the distcc server to crash with just a
> little fuzz (telnet to it and close the telnet) - but it is true I
> haven't seen anything odd using the distcc client.

In addition I think I've also seen some bits floating around that 
occassionally distcc does something weird in a correct setup too.

I briefly looked how distcc behaved while doing the stress_accept. Distcc 
basically seems to have n processes each accept()ing and some kind of 
memleak killer by limiting number of successive accepts then exit, while 
the parent who did the listen is only periodically (had some sleep(1)s) 
collecting dead ones & respawning them.

> Anyhow, my news is that using rc5 I have managed to reproduce it on
> localhost - so it isn't just ingo anymore ! ;)

Also Peter Z has reported it earlier, it was distcc+localhost for him as 
well.

> and has intentionally broken dependencies so it just keeps recompiling 
> stuff.

...Trying to invent perpetual motion machine? :-/

> The input files are
> approximately 135k, 98k, and 16k after running gcc -E on them (which I
> what I assume distcc does before putting them down the socket).
>
> On rc5 I could get the lockup in under 20 minutes.. usually 10. I think
> I did it 4 times. My compile test is probably a better trigger than the
> kernel compile because the distcc connects are never staggered like they
> would be in a large directory of files. (3 files, -j4).

It could be even easier if you make next in path gcc to play with 
nice, trying a number of different values might reveal some really fast 
to reproduce scenario.

> When I apply the locking patch you (Ilpo) wrote, I cannot reproduce the
> error at all in the first 90 minutes of testing. I'll let the test run
> and update the list.

At least it helps some :-), like it should.

> I'm holding out hope that Ingo's report did not have the locking patch
> on the distcc server end - because it certainly makes a difference for 
> me.

...He had some issue with different versions being deployed at least in 
the past, and I failed to follow his latest answer :-).


-- 
 i.
