From: Ben Greear <greearb@candelatech.com>
Subject: Re: Luca Deri's paper: Improving Passive Packet Capture: Beyond Device
 Polling
Date: Tue, 06 Apr 2004 11:40:44 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4072F9AC.7010307@candelatech.com>
References: <20040330142354.GA17671@outblaze.com> <1081033332.2037.61.camel@jzny.localdomain> <c4rvvv$dbf$1@sea.gmane.org> <407286BB.8080107@draigBrady.com> <4072A1CD.8070905@ntop.org> <c4uk8g$38l$1@sea.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jason Lunz <lunz@falooley.org>
In-Reply-To: <c4uk8g$38l$1@sea.gmane.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jason Lunz wrote:
> deri@ntop.org said:
> 
>>In addition if you do care about performance, I believe you're willing
>>to turn off packet transmission and only do packet receive. 
> 
> 
> I don't understand what you mean by this. packet-mmap works perfectly
> well on an UP|PROMISC interface with no addresses bound to it. As long
> as no packets are injected through a packet socket, the tx path never
> gets involved.
> 
> 
>>IRQ: Linux has far too much latency, in particular at high speeds. I'm
>>not the right person who can say "this is the way to go", however I
>>believe that we need some sort of interrupt prioritization like RTIRQ
>>does.
> 
> 
> I don't think this is the problem, since small-packet performance is bad
> even with a fully-polling e1000 in NAPI mode. As Robert Olsson has
> demonstrated, a highly-loaded napi e1000 only generates a few hundred
> interrupts per second. So the vast majority of packets recieved are
> coming in without a hardware interrupt occurring at all.

If the polling is delayed, then you get plenty of latency.

With something like e1000, you can have up to 4096 rx buffers too,
which can also increase latency, but you do drop fewer packets.

Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
