From: Mark Seger <Mark.Seger@hp.com>
Subject: Re: update frequency for stats in /proc/net/dev
Date: Tue, 18 Dec 2007 10:10:48 -0500
Message-ID: <4767E2F8.2040007@hp.com>
References: <4767CD16.5050904@hp.com> <20071218145707.GV11220@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:46391 "EHLO palrel10.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756139AbXLRPLJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Dec 2007 10:11:09 -0500
In-Reply-To: <20071218145707.GV11220@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Thomas Graf wrote:
> * Mark Seger <Mark.Seger@hp.com> 2007-12-18 08:37
>   
>> Anyhow, I just wanted to let people know that ALL tools that monitor 
>> once a second on older counters will get the wrong numbers and tools 
>> that correct for the wrong number by using fractional intervals (and I 
>> suspect mine is the only one that does) but run on newer kernels will 
>> also get the wrong numbers.  In any event, if anyone is interested in 
>> trying out collectl - it monitors a  LOT more than just networks - you 
>> can snag a copy of from http://collectl.sourceforge.net/ if you'd like 
>> to take if for a drive.  The website has a lot of output examples to 
>> give you a better idea what it can do.  I even included a writeup about 
>> the odd network performance observations at 
>> http://collectl.sourceforge.net/NetworkStats.html
>>     
>
> I've solved this problem by using netlink to read the interface counters
> ten times per second and maintain an own counter from which I calculate
> the rate exactly once per second/minute/hour. The rate per second may
> still be inaccurate to some degree, therefore I keep a history of 2-5
> rates and take them into account to smoothen the result. This works
> fairly well with _all_ operating systems.
>   
I guess I'm not entirely sure what you're saying with respect to 10 
times/sec. Is this once very .1 secs or 10 times in rapid fire?  From a 
general purpose monitoring perspective, since I read hundreds of 
counters every second doing it 10 times/sec is way too much overhead and 
special processing for netowork counters would also be pretty painful.  
The general problem of the counters only changing once a second means 
you'll never do that well when you monitor close the the interval and 
you can't ever get accurate counters at lower rates.  In fact, if you 
try to treat the network counters like any other and if you monitor say 
every .2 seconds, you see a rate of 0 for 4 of the 5 intervals and 
500MB/sec for the 5th.
-mark


