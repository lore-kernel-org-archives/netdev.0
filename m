From: Ben Greear <greearb@candelatech.com>
Subject: Re: packet re-ordering on SMP machines.
Date: Mon, 26 Aug 2002 16:20:41 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D6AB7C9.3020802@candelatech.com>
References: <Pine.GSO.4.30.0208252046250.675-100000@shell.cyberus.ca> <3D69AFE7.6020902@candelatech.com> <009701c24d54$d27304a0$f1fa010a@weixl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8bit
Cc: jamal <hadi@cyberus.ca>, Cheng Jin <chengjin@cs.caltech.edu>,
   Cheng Hu <chenghu@cs.caltech.edu>, Steven Low <slow@cs.caltech.edu>,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Xiaoliang (David) Wei" <weixl@caltech.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Xiaoliang (David) Wei wrote:
> Hi Ben and Jamal,
>        Are you guys sure that getdayoftime per packet is a big overhead on
> Gbps connection?
>        Do you compare the performance with getdayoftime per packet and
> without? I guess RFC 1323 specifies that each packet should have a timestamp
> (although not from getdayoftime).
>        Also, what's your testbed's configuration, Ben? (I guess if we can
> use faster hardware to overcome this effect...)
>       Thank you:)
> 
>      ps: I am working on some high speed TCP experiment and may want to make
> getdayoftime every packet...

Actually, now that I think back, I believe the generic ethernet code timestamps
each skb when it's received anyway....  So, my hit probably comes mostly
from allocating new buffers and potentially the gettimeofday that is done then.

I have not benchmarked the kernel gettimeofday call in any sort of
isolated case.

It does not appear that the CPU is what is limiting my particular test, I think
it's either the NIC or the driver, or more likely, the way I'm driving it...

Ben

> 
> -David
> Xiaoliang (David) Wei             Graduate Student in CS@Caltech
> http://www.cs.caltech.edu/~weixl
> ====================================================
> ----- Original Message -----
> From: "Ben Greear" <greearb@candelatech.com>
> To: "jamal" <hadi@cyberus.ca>
> Cc: <netdev@oss.sgi.com>
> Sent: Sunday, August 25, 2002 9:34 PM
> Subject: Re: packet re-ordering on SMP machines.
> 
> 
> 
>>jamal wrote:
>>
>>
>>>That doesnt sound impressive at all. I know it's about .8 of wire rate
>>>but you should be able to exceed that.
>>>Robert was generating in the range of 800Kpps with that NIC if i recall
>>>corectly
>>
>>I had only tested 1514 byte pkts, so I was getting around 880Mbps,
>>which is pretty good as far as I know.
>>
>>I see about 255 kpps when sending 64 byte pkts to myself.  Still
>>dropping about 1 in 4000 packets at this speed.  I think most of Robert's
>>tests didn't involve actually doing something with the received packet
>>though, and I am inspecting it for latency, sequence number, etc.
>>
>>I'm even doing a __get_timeofday() call to calculate the latency...need
>>to find a faster way to do that...
>>
>>If I only allocate/scan 1 per 100 packets (ie alloc one packet and send it
> 
> 100 times),
> 
>>then I get a more respectable 365kpps.  Robert's patch should definately
> 
> help!
> 
>>>Also if you have SMP, tie each onto a CPU.
>>
>>That's with the irq_afinity thing in proc, right?
>>
>>
>>>Additionaly get the skb recycler patch from Robert, it should improve
>>>things even more.
>>
>>Do you happen to have a URL for this?
>>
>>Actually, the various network tweaks are relatively hard to find
>>(at least to find the most up-to-date coppies).  It would be great if
>>there was a place where they were all concentrated.
>>
>>
>>>
>>>>Also, I see the hard_start_xmit call failing 5876 times out of 2719493
>>>>calls (for example).  The code that calls the method looks like this:
>>>>
>>>
>>>
>>>I dont have access to that NIC. But a stoopid question: Have you tried
>>>increasing the transmit queue via ifconfig? 1000 packets is reasonable
>>>for gige.
>>
>>I upped it, but it didn't stop the errors.  The NIC is still performing,
>>so it may not be a real problem...
>>
>>Thanks for the info,
>>Ben
>>
>>--
>>Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
>>President of Candela Technologies Inc      http://www.candelatech.com
>>ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
>>
>>
>>
>>
>>
> 
> 


-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
