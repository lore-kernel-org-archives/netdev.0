From: Mark Seger <Mark.Seger@hp.com>
Subject: Re: Why are network counters only updated once a second?
Date: Mon, 14 Jan 2008 16:00:27 -0500
Message-ID: <478BCD6B.4020009@hp.com>
References: <478BC662.6030004@hp.com> <478BC9ED.2000204@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:54342 "EHLO palrel12.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750708AbYANVAn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jan 2008 16:00:43 -0500
In-Reply-To: <478BC9ED.2000204@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Eric Dumazet wrote:
> Mark Seger a =E9crit :
>> I had mentioned this in my previous post but perhaps it might get=20
>> more attention all by itself.  I can't say for sure when this=20
>> changed, but for the longest time network counters were only updated=
=20
>> once every 0.9765 seconds and unless you used a tools like collectl=20
>> that could monitor at fractional intervals, your traffic was=20
>> under-reported AND you'd get periodic spikes of double the actual=20
>> rate.  See http://collectl.sourceforge.net/NetworkStats.html for a=20
>> more complete explanation.
>>
>> Eventually the frequency became better aligned at a 1 second interva=
l=20
>> because now the number look better, but the problem I see is that=20
>> when the sampling interval is very close to the monitoring interval=20
>> you still get periodic incorrect data.  Furthermore, you now need to=
=20
>> know which way the counters are updated before you pick a sampling=20
>> interval!  But the real point is if anyone ever wants to do finer=20
>> grained monitoring, say every 1/2 or even tenth of a second, they=20
>> can't because the counters won't change between samples.  Has this=20
>> ever been discussed before?
>>
>
> Yes it was discussed before. Some devices perform counters updates=20
> directly at the NIC level, and one in a while a transfert of counters=
=20
> is done to the host.
>
> This is supposed to be better, especially on SMP.
>
> Maybe you need to setup accounting rules with iptables, so that you=20
> can perform counter sampling at whatever rate you want ?
Maybe I wasn't clear enough.  I'm grabbing the counters from=20
/proc/net/dev and whatever mechanism is being used only ports them with=
=20
a granularity of about once a second.  This means any of the standard=20
tools that use /proc to get their data will all have the same problem.
-mark

