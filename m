From: Rick Jones <rick.jones2@hp.com>
Subject: Re: NIU - Sun Neptune 10g - Transmit timed out reset (2.6.24)
Date: Fri, 09 May 2008 16:03:12 -0700
Message-ID: <4824D830.9090504@hp.com>
References: <86802c440805071130m62c1f4edydb3316dac4a2aba2@mail.gmail.com>	<20080507.141521.193714938.davem@davemloft.net>	<482498D5.9060008@krogh.cc>	<20080509.143229.174354251.davem@davemloft.net>	<4824C936.9000103@krogh.cc> <4824CE43.8060203@hp.com> <4824D4C0.10201@krogh.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, yhlu.kernel@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jesper Krogh <jesper@krogh.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:23519 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753565AbYEIXDS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2008 19:03:18 -0400
In-Reply-To: <4824D4C0.10201@krogh.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> To which cpu(s) were the neptune's interrupts assigned? (grep <ethN> 
>> /proc/interrupts)
>
> Several

Which ones?-)  I suspect that since it is several that at least answers 
the MSI_X question right?  Or is it possible to have a single device 
have several MSI interrupts?

>> Is the irqbalanced running?
> 
> 
> Yes. I started by not running it, but saw that cpu 0 was saturated by
> ksoftirqd
> 
>> Were any of the 16 CPUs in the system saturated during the test? (top 
>> with all CPUs displayed)
> 
> 
> Yes..
> Cpu12 : 34.2%us,  5.9%sy,  0.0%ni,  0.0%id, 14.5%wa,  1.0%hi, 44.4%si, 
> 0.0%st

David mentioned TX serialization - perhaps that is where TX completions 
are happening?

> All others have idle time.
> 
>> Do you have/know of any diagrams showing the way the I/O slots are 
>> wired to the rest of the system?
> 
> 
> I havent dug into that. Probably naive, as I as, I expected som hardware
> guys as Sun to have taken care of that, when I bought the recommended
> 10g card for their own server.

I am very clueless as to the design considerations under which Neptune 
was designed, but given that Neptune is based (IIRC) on the same "in 
core" 10G stuff as Sun talks about being in the UltraSPARC-T2 
processors, there is the possibility the design center was somewhat 
different then what one sees in an 8P Opteron system, whether it carries 
a Sun logo or not.  From what I've learned thusfar 8P Opteron systems 
are "interesting" beasts with what I suspect are rather different 
constraints and behaviours than an UltraSPARC-T[12] system.

What I was asking about was more a block diagram showing via which 
sockets the given I/O slots were connected.

>> Have you tried any tests without any filesystem involvement? 
> 
> no not yet. I'll try that.

If you decide to go the netperf route, feel free to contact me directly 
with netperf questions, or via the netperf-talk mailling list on 
netperf.org.

rick jones

