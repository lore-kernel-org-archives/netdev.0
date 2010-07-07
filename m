From: "Jussi Kivilinna" <jussi.kivilinna@mbnet.fi>
Subject: Re: QoS weirdness : HTB accuracy
Date: Wed, 07 Jul 2010 18:07:53 +0300
Message-ID: <20100707180753.104124gv6yvtou9s@hayate.sektori.org>
References: <067c83163988908ef546d7ff7f560a17@localhost>
	<4BF32BB0.7010700@redfish-solutions.com>
	<e6bd0cff8dafc8b3af0760facb5fdc8c@localhost>
	<1276204948.1403.13.camel@andybev> <1278265807.1506.86.camel@andybev>
	<Pine.LNX.4.64.1007071457020.6631@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
	DelSp=Yes	format=flowed
Content-Transfer-Encoding: 7BIT
Cc: "Andrew Beverley" <andy@andybev.com>,
	"Julien Vehent" <julien@linuxwall.info>,
	"Philip A. Prindeville" <philipp_subx@redfish-solutions.com>,
	Netdev <netdev@vger.kernel.org>,
	netfilter <netfilter@vger.kernel.org>, hawk@comx.dk
To: "Jesper Dangaard Brouer" <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tulikuusama.dnainternet.net ([83.102.40.132]:58204 "EHLO
	tulikuusama.dnainternet.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756907Ab0GGPIE convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jul 2010 11:08:04 -0400
In-Reply-To: <Pine.LNX.4.64.1007071457020.6631@ask.diku.dk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting "Jesper Dangaard Brouer" <hawk@diku.dk>:

>
> On Sun, 4 Jul 2010, Andrew Beverley wrote:
>
>>>> I was, in fact, an error in my ruleset. I had put the 'linklayer atm' at
>>>> both the branch and leaf levels, so the overhead was computed twice,
>>>> creating those holes in the bandwidth.
>>>
>>> I am seeing similar behaviour with my setup. Am I making the same
>>> mistake? A subset of my rules is as follows:
>>>
>>> tc qdisc add dev ppp0 root handle 1: htb r2q 1
>>>
>>> tc class add dev ppp0 parent 1: classid 1:1 htb \
>>>    rate ${DOWNLINK}kbit ceil ${DOWNLINK}kbit \
>>>    overhead $overhead linklayer atm                   <------- Here
>>>
>>> tc class add dev ppp0 parent 1:1 classid 1:10 htb \
>>>    rate 612kbit ceil 612kbit prio 0 \
>>>    overhead $overhead linklayer atm                   <------- And here
>>>
>>> tc qdisc add dev ppp0 parent 1:10 handle 4210: \
>>>    sfq perturb 10 limit 50
>>>
>>> tc filter add dev ppp0 parent 1:0 protocol ip \
>>>    prio 10 handle 10 fw flowid 1:10
>>
>> I removed the overhead option on the first leaf, and the speeds change
>> to what I expect. However, the rules above are taken straight from the
>> ADSL Optimizer project, which was the source of the original overhead
>> patch for tc. So is the ADSL Optimizer project wrong?
>
> After looking at the HTB kernel code I believe that the ADSL  
> Optimizer project is NOT wrong.  You should/must set the linklayer  
> option on both the root class and leaf (else you would be charging  
> the root/parent node too little).
>

It's been while I looked at the linklayer/size-table code, but if I  
remember right overhead is calculated with first linklayer packet sees  
in qdisc. So when packet goes to leaf with 'linklayer atm', packet get  
packet size with overhead for ATM and root linklayer is not used for  
that packet. Because of this you can have leafs with different  
overheads (pppoe, ipv6-tunnel, etc, with ) and all get right  
overhead... ..

..

...Uh oh...

HTB still has linklayer/overhead of its own, I was talking about the  
generic linklayer code that can be used with all qdiscs. Never mind,  
sorry.

-Jussi


