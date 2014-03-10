From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: tcp_release_cb() should release socket ownership
Date: Mon, 10 Mar 2014 16:40:21 -0400 (EDT)
Message-ID: <20140310.164021.1313320657150372351.davem@davemloft.net>
References: <771471B8871B5044A6CA7CCD9C26EEE10117E265CE84@xmail2.se.axis.com>
	<1394208065.20149.31.camel@edumazet-glaptop2.roam.corp.google.com>
	<1394469831.3607.27.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lars.persson@axis.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47315 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754386AbaCJUkX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 16:40:23 -0400
In-Reply-To: <1394469831.3607.27.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 10 Mar 2014 09:43:51 -0700

> On Fri, 2014-03-07 at 08:01 -0800, Eric Dumazet wrote:
>> On Fri, 2014-03-07 at 16:45 +0100, Lars Persson wrote:
>> > So far no deadlock on the socket lock is seen with this patch. I have seen two out-of-memory crashes which leaves the system deadlocked trying to allocate memory.
>> > 
>> > Stack traces and kernel log from one of the oom crashes is attached. I was thinking this may be caused by having the dirty_ratio set too high given our product's heavy use of memory. Currently re-testing with dirty_ratio reduced to 5%.
>> > 
>> > 
>> > [11515.530000] Recording maint invoked oom-killer: gfp_mask=0x201da, order=0, oom_score_adj=0
>> > [11515.540000] CPU: 0 PID: 1304 Comm: Recording maint Tainted: G           O 3.10.32 #10
>> > [11515.550000] Stack : 80666e52 00000049 80660000 00000000 805563dc 8b1876f8 8054af80 805d2227
>> > 	  00000518 00000000 80656d40 8b1876f8 000007ce 00000002 00000000 8047d858
>> > 	  00000000 8003bb64 00000006 00000000 8054d024
>> >  [11515.580000]  8b189a84 8b189a84 8054af80
>> > 	  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
>> > 	  00000000 00000000 00000000 00000000 00000000 00000000 00000000 8b189a18
>> > 	  ...
>> 
>> 
>> Well, this is 3.10.32, with local changes to dirty_ratio....
>> 
>> so I will simply ignore mm issues for the moment.
>> 
>> Thanks a lot Lars
>> 
>> Tested-by: Lars Persson <lars.persson@axis.com>
> 
> David, what happened with this patch ?
> 
> Should I re-submit it ?

Yes, please do.  Thanks!
