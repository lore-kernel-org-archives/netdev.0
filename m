From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [Lksctp-developers] Fw: Intermittent SCTP multihoming breakage
Date: Mon, 05 Feb 2007 15:34:32 -0500
Message-ID: <45C794D8.30304@hp.com>
References: <E096369D937D3A4DB271B382850C5C5F44E71C@pysmail.eicon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net,
	Sridhar Samudrala <sri@us.ibm.com>
To: Steve Hill <steve.hill@dialogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:39365 "EHLO atlrel8.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933422AbXBEUfG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Feb 2007 15:35:06 -0500
In-Reply-To: <E096369D937D3A4DB271B382850C5C5F44E71C@pysmail.eicon.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Steve

would you mind terribly, changing the -d "$net" to the 
-i "$net", and run the script with the interface name instead?

The reason is, that I see 2 different behaviors between blocking
by interface and blocking by IP and would like to find out if
you see it too.

When I block at the interface ( -i eth1 in my case), I see
the path failover happen and flow if resumed.

When I block at the ip address, I see the path failover
in an odd state.  It looks like it happened, but the flow is
not resumed.  Receive still doesn't get traffic. I think I might
be running a buggy receiver, but I am not 100% sure.  In my
case, the sender if running 2.6.10-rc7 and receiver is running
Ubuntu 2.6.17-10.

I'll try running against a different receiver as well.

-vlad

Steve Hill wrote:
> Vlad Yasevich wrote on 05 February 2007 17:08:
> 
>>   1. What did you set the sinfo_timetolive to?
> 
> I presume you mean the timetolive parameter of sctp_sendmsg()? - this
> was set to 1400ms (as previously mentioned, this was in error but it
> does appear to have highlighted a problem with the stack itself).
> 
>>   2. What specific netfilter rule to do use to simulate
>> network outage?
>>      I was using '-t filter -A INPUT -i eth0 -p sctp -j DROP'
> 
> iptables -A INPUT -d 192.168.2.0/24 -p sctp -j DROP
> 
>> Just trying to get more info to simulate this.  My prior attempts
>> recovered quickly with my patch.
> 
> I usually (but not always - sometimes it happens on the first attempt)
> have to add and remove the iptables rule a few times while running
> traffic over the association in order to reproduce the problem.  I'm
> running traffic at a rate of around 500 data chunks per second.  Each
> data chunk has a 44 octet payload.
> 
> The script I'm using to toggle the iptables rule is below:
> 
> ----------
> #!/bin/sh
> 
> net="$1"
> 
> flush() {
> 	iptables -F
> 	echo "Flush"
> 	exit
> }
> 
> trap flush EXIT
> 
> while true; do
> 	iptables -A INPUT -d "$net" -p sctp -j DROP
> 	echo "set"
> 	sleep 5
> 	iptables -F
> 	echo "flushed"
> 	sleep 5
> done 
> ----------
> 
>  - Steve Hill
>    Software Engineer
>    Dialogic
>    Fordingbridge, Hampshire, UK
>    +44-1425-651392
>    steve.hill@dialogic.com
> 

