From: "Denys" <denys@visp.net.lb>
Subject: Re: iproute2-2.6.20-070313 bug ?
Date: Thu, 22 Mar 2007 15:26:12 +0200
Message-ID: <20070322132021.M7074@visp.net.lb>
References: <20070321175951.M73913@visp.net.lb> <46026717.9060909@trash.net> <20070322124533.M79867@visp.net.lb> <46027FF2.6020001@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:38018 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751861AbXCVN0a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2007 09:26:30 -0400
In-Reply-To: <46027FF2.6020001@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear sir 

Sorry, i forgot to CC other members of discussion.

1024kb (if i am not wrong 1Mbyte) is huge? 

For me it is ok, as soon as i have RAM. Another thing, it is working well 
with old tc. Just really if i have plenty of RAM's and i want 32second 
buffer, why i cannot have that, and if i see it is really possible before? 

Possible i am misunderstanding something...
In real world i am seeing reasonable to have much bigger buffers, especially 
if there is no problem in resources (RAM, timer resolution, CPU). For 
example, as i remember we had failure on one of our STM-1, and Cisco's on 
Teleglobe was buffering about 20-30seconds of data without major packetloss. 

Another thing, why i was using buffer, and possible i use it wrong:
For example customer have 128Kbit/s account, and i want to give him burst to 
open web-pages fast (256Kbit/s), but if he use bandwidth non-stop, he will 
pass this buffer, and will be throttled back to 128Kbit/s. Now seems i cannot 
give such functionality.


On Thu, 22 Mar 2007 14:09:06 +0100, Patrick McHardy wrote
> Denys wrote:
> > /sbin/tc2 qdisc del dev ppp0 root 
> > /sbin/tc2 qdisc add dev ppp0 root handle 1: prio 
> > /sbin/tc2 qdisc add dev ppp0 parent 1:1 handle 2: tbf buffer 1024kb 
latency 
> > 500ms rate 128kbit peakrate 256kbit minburst 16384 
> > /sbin/tc2 filter add dev ppp0 parent 1:0 protocol ip prio 10 u32 match ip 
dst 
> > 0.0.0.0/0 flowid 2:1
> 
> That is an incredible huge buffer value.
> 
> > qdisc tbf 2: parent 1:1 rate 128000bit burst 4294932937b peakrate
> 256000bit minburst 16Kb lat 4.2s
> 
> And it causes an overflow.
> 
> The limit for the TBF burst value with nanosecond resolution is
> ~ 4 * rate (10^9 * burst / rate < 2^32 needs to hold), resoluting
> in a worst-case latency of 4 seconds. I think this limit is in the
> reasonable range. Your configuration results in a worst-case
> queuing delay of 64s, and I doubt that you really want that.
> 
> Obviously its not good to break existing configurations, but I
> would argue that this configuration is broken.


--
Virtual ISP S.A.L.

