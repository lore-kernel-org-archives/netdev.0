From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: Re: DDoS attack causing bad effect on conntrack searches
Date: Mon, 26 Apr 2010 16:36:08 +0200
Message-ID: <1272292568.13192.43.camel@jdb-workstation>
References: <1271941082.14501.189.camel@jdb-workstation>
	 <q2h412e6f7f1004220613m488c2ee4r6d24a8d1e65997d4@mail.gmail.com>
	 <4BD04C74.9020402@trash.net> <1271946961.7895.5665.camel@edumazet-laptop>
	 <1271948029.7895.5707.camel@edumazet-laptop>
	 <20100422155123.GA2524@linux.vnet.ibm.com>
	 <1271952128.7895.5851.camel@edumazet-laptop>
	 <Pine.LNX.4.64.1004222213290.10919@ask.diku.dk>
	 <1272056237.4599.7.camel@edumazet-laptop>
	 <Pine.LNX.4.64.1004241219280.32071@ask.diku.dk>
	 <1272139861.20714.525.camel@edumazet-laptop>
Reply-To: hawk@comx.dk
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <hawk@diku.dk>, paulmck@linux.vnet.ibm.com,
	Patrick McHardy <kaber@trash.net>,
	Changli Gao <xiaosuo@gmail.com>,
	Linux Kernel Network Hackers <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:58312 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751614Ab0DZOfv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 10:35:51 -0400
In-Reply-To: <1272139861.20714.525.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2010-04-24 at 22:11 +0200, Eric Dumazet wrote:
>  
> > Monday or Tuesdag I'll do a test setup with some old HP380 G4 machines to 
> > see if I can reproduce the DDoS attack senario.  And see if I can get 
> > it into to lookup loop.
> 
> Theorically a loop is very unlikely, given a single retry is very
> unlikly too.
> 
> Unless a cpu gets in its cache a corrupted value of a 'next' pointer.
> 
...
>
> With same hash bucket size (300.032) and max conntracks (800.000), and
> after more than 10 hours of test, not a single lookup was restarted
> because of a nulls with wrong value.

So fare, I have to agree with you.  I have now tested on the same type
of hardware (although running a 64-bit kernel, and off net-next-2.6),
and the result is, the same as yours, I don't see a any restarts of the
loop.  The test systems differs a bit, as it has two physical CPU and 2M
cache (and annoyingly the system insists on using HPET as clocksource).

Guess, the only explanation would be bad/sub-optimal hash distribution.
With 40 kpps and 700.000 'searches' per second, the hash bucket list
length "only" need to be 17.5 elements on average, where optimum is 3.
With my pktgen DoS test, where I tried to reproduce the DoS attack, only
see a screw of 6 elements on average.


> I can setup a test on a 16 cpu machine, multiqueue card too.

Don't think that is necessary.  My theory was it was possible on slower
single queue NIC, where one CPU is 100% busy in the conntrack search,
and the other CPUs delete the entries (due to early drop and
call_rcu()).  But guess that note the case, and RCU works perfectly ;-)

> Hmm, I forgot to say I am using net-next-2.6, not your kernel version...

I also did this test using net-next-2.6, perhaps I should try the
version I use in production...


-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network Kernel Developer
  Cand. Scient Datalog / MSc.CS
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer

