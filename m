From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Throughput Bug?
Date: Fri, 19 Oct 2007 10:42:15 -0700
Message-ID: <4718EC77.8090309@hp.com>
References: <c565abbb0710180854j6f2f756sdd390161bafd1c4a@mail.gmail.com>	<20071019014419.6ac8a6a0.billfink@mindspring.com> <c565abbb0710190841g6ea4b424vbd5acf8e2fbc4d1c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Matthew Faulkner <matthew.faulkner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel11.hp.com ([156.153.255.246]:43658 "EHLO palrel11.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934675AbXJSRmR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2007 13:42:17 -0400
In-Reply-To: <c565abbb0710190841g6ea4b424vbd5acf8e2fbc4d1c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Matthew Faulkner wrote:
> I removed the socket sizes in an attempt to reproduce your results
> Rick and i managed to do so, but only when i launch netperf by typing
> in the follow cmd in to the bash shell.
> 
> /home/cheka/netperf-2.4.4/src/netperf -T 0,0 -l 10 -t TCP_STREAM -c
> 100 -C 100 -f M -P 0 -- -m 523
> 
> As soon as i try to launch netperf (with the same line as i do manual)
> from within a script of any form (be it php or bash) the difference
> between 523 and 524 appears again.
> 
> The php script i'm using is pasted below (it's the same as the bash
> script that comes with netperf to provide the tcp_stream)

well, bash on some platforms I guess - when those netperf scripts were first 
written, i'm not even sure bash was a gleam in its author's eye :)

> <?php
>         $START=522;
>         $END=524;
>         $MULT=1;
>         $ADD=1;
>         $MAXPROC=1; // This is the maximum number of CPU's you have so
> we can assign the client to different CPUs to show the same problem
> between 523 and 524 does not occur unless it's on CPU 0 and CPU 0
> 
>         $DURATION = 10; // Length of test
>         $LOC_CPU = "-c 100"; // Report the local CPU info
>         $REM_CPU = "-C 100"; // Report the remove CPU info
> 
>        $NETSERVER = "netserver"; //path to netserver
>        $NETPERF = "netperf"; // path to netperf
> 
>         for($i=0; $i<=$MAXPROC; $i++) {
>                 echo "0,$i\n";
>                 $MESSAGE = $START;
> 
>                 while($MESSAGE <= $END) {
>                         passthru('killall netserver > /dev/null'); //
> tried it with and without the following restarts of netserver
>                         passthru('sleep 5');
>                         passthru("$NETSERVER");
>                         passthru('sleep 5');
>                         echo "$NETPERF -T 0,$i -l $DURATION -t
> TCP_STREAM $LOC_CPU $REM_CPU -f M -P 0 -- -m $MESSAGE\n"; // let's see
> what we try to exec
>                         passthru("$NETPERF -T 0,$i -l $DURATION -t
> TCP_STREAM $LOC_CPU $REM_CPU -f M -P 0 -- -m $MESSAGE"); // exec it -
> this will also print to screen
>                         passthru('sleep 5'); // sleep
>                         $MESSAGE += $ADD;
>                         $MESSAGE *= $MULT;
>                 }
>         }
> ?>

While I wouldn't know broken php if it reared up and bit me on the backside, the 
above looks like a fairly straightforward trnaslation of some of the old netperf 
scripts with the add and mult  bits.  I don't see anything amis there.

While it is often a case of famous last words, I've dropped netperf-talk from 
this as I don't think there is a netperf issue, just an issue demonstrated with 
netperf.  Besides, netperf-talk, being a closed list (my simplistic attempts to 
deal with spam) would cause problems for most readers of netdev when/if they 
were to contribute to the thread...

> 
> 
> On 19/10/2007, Bill Fink <billfink@mindspring.com> wrote:
>>I don't know if it's relevant, but note that 524 bytes + 52 bytes
>>of IP(20)/TCP(20)/TimeStamp(12) overhead gives a 576 byte packet,
>>which is the specified size that all IP routers must handle (and
>>the smallest value possible during PMTU discovery I believe).  A
>>message size of 523 bytes would be 1 less than that.  Could this
>>possibly have to do with ABC (possibly try disabling it if set)?

ABC might be good to check.  It might also be worthwhile to try setting the 
lowlatency sysctl - both processes being on the same CPU might interact poorly 
with the attempts to run things on the receiver's stack.

rick jones

I guess I've not managed to lose the race to a packet trace... :)
