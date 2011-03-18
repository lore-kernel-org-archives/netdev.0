From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: [PATCH] netfilter: xtables: fix reentrancy
Date: Fri, 18 Mar 2011 11:27:53 +0100 (CET)
Message-ID: <Pine.LNX.4.64.1103181113040.21558@ask.diku.dk>
References: <1300302005.3202.23.camel@edumazet-laptop>
 <20110316.131648.15245216.davem@davemloft.net>  <1300358140.3133.117.camel@edumazet-laptop>
  <Pine.LNX.4.64.1103171231220.21558@ask.diku.dk>  <1300362323.3133.195.camel@edumazet-laptop>
 <1300367841.6315.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-511516320-1226776439-1300444073=:21558"
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1300367841.6315.9.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---511516320-1226776439-1300444073=:21558
Content-Type: TEXT/PLAIN; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: 8BIT



On Thu, 17 Mar 2011, Eric Dumazet wrote:
> Le jeudi 17 mars 2011 à 12:45 +0100, Eric Dumazet a écrit :
>> Le jeudi 17 mars 2011 à 12:36 +0100, Jesper Dangaard Brouer a écrit :
>>> Hi Eric,
>>>
>>> How critial is this bug fix?
>>>
>>> Should I apply this on my stable production kernels?
>>> (I'm preparing a 2.6.38 kernel for prod usage, eventhougt its just been
>>> released, because I want your SFQ fixes...)
>>
>> I would say the race is there, but probability must be very small, and
>> might need malicious iptables rules (with RETURN targets)

Actually do have a large number of return targets.
In the filter forward chain.


>> Especially in routers, where OUTPUT path is taken from softirq handler
>> anyway ;)
>>
>> So dont worry at all, consider this as a cleanup :)
>>
>
> Almost forgot to mention your kernels probably have :
>
> CONFIG_PREEMPT_NONE=y
> # CONFIG_PREEMPT is not set
>
> So you can take it easy ;)

I have actually enabled PREEMPTion, am I in trouble then?

I have modified the .config I got from you, quite a lot, during my 
attempts to find the CCISS/HPSA problem.

Which reminds me that I needed to enable, the follwing config options, 
(which your config didn't have):
  CONFIG_PCIEASPM=y
  CONFIG_X86_X2APIC=y

In order to get rid of a PCI warning:
  NMI: PCI system error (SERR) for reason b1 on CPU 0.
  Dazed and confused, but trying to continue

The system worked fine, and you might not see this issue on your G6 
servers, as its most likely BIOS related (my server is a HP DL370 G6).

FYI: Operations have deployed the kernel on prod server this morning.

Cheers,
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
---511516320-1226776439-1300444073=:21558--
