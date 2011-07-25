From: Richard Kennedy <richard@rsk.demon.co.uk>
Subject: Re: v3.0-rc* intermittent network failure: Test case found!
Date: Mon, 25 Jul 2011 13:01:52 +0100
Message-ID: <4E2D5B30.30003@rsk.demon.co.uk>
References: <1311256194.2980.18.camel@castor.rsk>  <20110721143218.GA10595@electric-eye.fr.zoreil.com> <1311261527.2980.26.camel@castor.rsk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from anchor-post-2.mail.demon.net ([195.173.77.133]:45074 "EHLO
	anchor-post-2.mail.demon.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750864Ab1GYMB7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2011 08:01:59 -0400
In-Reply-To: <1311261527.2980.26.camel@castor.rsk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21/07/11 16:18, Richard Kennedy wrote:
>> Richard Kennedy<richard@rsk.demon.co.uk>  :
>>> I keep seeing a total network failure on v3.0.0-rc* , it is highly
>>> intermittent, anything from 1 hour to 12+, and I don't have a reliable
>>> test case.
>>> When it fails I lose all network comms, but there are no errors in the
>>> system log, no hung tasks reported, nothing. But after it fails the
>>> machine hangs during shutdown, it just never turns off. So I guess
>>> something is getting stuck but I can't find it.
>>

I have found a reliable test case, I can instantly trigger my problem by 
starting 2 instances of rsync at the same time. [this is on x86_64 AMDX2]

e.g.
rsync -a linux-2.6 server:t1 & ;rsync -a linux-2.6 server:t2 &


If I have a ping running when I trigger the problem, it pauses then 
errors with :-

	ping: sendmsg: No buffer space available

But if I start a ping after, it fails with

...	Destination Host Unreachable
.

I have a serial console attached but don't really understand what it's 
telling me.
AFAICT -- I have no blocked tasks  - sysrq w shows :-


SysRq : Show Blocked State
   task                        PC stack   pid father
Sched Debug Version: v0.10, 3.0.0 #46
ktime                                   : 7129717.783042
sched_clk                               : 7126380.221722
cpu_clk                                 : 7129711.544071
jiffies                                 : 4301797008
sched_clock_stable                      : 0
.....[lots more schedule & cpu info]

But now I've got a reliable test case I can find a last know good kernel 
and have a stab at bisecting this, unless anyone has got any better 
suggestions?

regards
Richard



