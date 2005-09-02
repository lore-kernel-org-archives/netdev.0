From: Guillaume Autran <gautran@mrv.com>
Subject: Re: Possible BUG in IPv4 TCP window handling, all recent 2.4.x/2.6.x
 kernels
Date: Fri, 02 Sep 2005 14:56:42 -0400
Message-ID: <4318A06A.1000702@mrv.com>
References: <Pine.LNX.4.61.0509011713240.6083@guppy.limebrokerage.com> <20050901.154300.118239765.davem@davemloft.net> <Pine.LNX.4.61.0509011845040.6083@guppy.limebrokerage.com> <2d02c76a84655d212634a91002b3eccd@psc.edu> <43184D79.6040009@mrv.com> <20050902135256.GC12617@yakov.inr.ac.ru> <43185E81.2070300@mrv.com> <20050902154424.GA15060@yakov.inr.ac.ru> <431877EE.6010101@mrv.com> <20050902173228.GA15925@yakov.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Heffner <jheffner@psc.edu>,
	Ion Badulescu <lists@limebrokerage.com>,
	"David S. Miller" <davem@davemloft.net>, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
In-Reply-To: <20050902173228.GA15925@yakov.inr.ac.ru>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The server socket sockopt are all default, except for the 
TCP_WINDOW_CLAMP which is set to 1400 (application specific).
Guillaume.


Alexey Kuznetsov wrote:

>Hello!
>
>  
>
>>Do you think this will also fix Ion's issue with small window size never 
>>going back up ?
>>    
>>
>
>I was wrong even about this one. That bad case, which I rememebered,
>is not triggered here. And even if packet lengths and windows were modified
>to trigger it, the effect would not be so pathological.
>
>
>12:23:24.474506 IP 10.10.10.3.3560 > 10.10.10.2.3200: P 13323:14703(1380) ack 1 win 6144 <nop,nop,timestamp 3256371 268597947>
>12:23:24.508950 IP 10.10.10.2.3200 > 10.10.10.3.3560: . ack 14703 win 14 <nop,nop,timestamp 268598804 3256371>
>
>This value for window is OK, we adverised 1394, so we have to reply with 14.
>
>But where is the ACK opening full window after receiver application
>reads data from buffer? It is the puzzle. It looks like rcvbuf is still
>full.
>
>Now sender cannot send anything due to SWS avoidance.
>
>12:23:29.362161 IP 10.10.10.3.3560 > 10.10.10.2.3200: . 14703:14717(14) ack 1 win 6144 <nop,nop,timestamp 3256380 268597947>
>
>I interpret this as SWS avoidance override timer.
>
>12:23:29.362791 IP 10.10.10.2.3200 > 10.10.10.3.3560: . ack 14717 win 14 <nop,nop,timestamp 268599289 3256380>
>
>This is impossible. :-) Well, it is possible, if rcv_mss is 14. It is what
>I thought, but it is impossible. :-)
>
>Honestly, I still cannot invent any way how this could happen.
>
>Can you say what setsockopt()s were made on receiver socket? It looks
>like just fiddlined with SO_RCVBUF is not enough.
>
>Alexey
>
>  
>

-- 
=======================================
Guillaume Autran
Senior Software Engineer
MRV Communications, Inc.
Tel: (978) 952-4932 office
E-mail: gautran@mrv.com
======================================= 


