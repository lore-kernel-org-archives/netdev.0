From: Andy Furniss <andy.furniss@dsl.pipex.com>
Subject: Re: IMQ / new Dummy device post.
Date: Sun, 18 Apr 2004 17:35:17 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4082AE45.7030101@dsl.pipex.com>
References: <407E5905.9070108@dsl.pipex.com>	 <1082031313.1039.13.camel@jzny.localdomain>	 <407EE3E5.8060200@dsl.pipex.com>	 <1082087553.1035.287.camel@jzny.localdomain>	 <4080356F.4020609@dsl.pipex.com>	 <1082145341.1026.125.camel@jzny.localdomain>	 <40810957.6030209@dsl.pipex.com>	 <1082203795.1043.18.camel@jzny.localdomain>	 <4081A824.5020107@dsl.pipex.com> <1082298480.1041.94.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1082298480.1041.94.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Sat, 2004-04-17 at 17:56, Andy Furniss wrote:
> 
>>jamal wrote:
> 
>  
> 
>>>I think i am almost understanding you now. Your main concern is people
>>>using bittorrent to upload to you, correct? 
>>>Is there a way to recognize packets going to/from bittorent?
>>
>>Quite possibly (though I think it uses connmark which I can't use as I 
>>use connbytes to get new tcps out of slowstart).
> 
> 
> You are speaking Inuit to me. What is connmark? and what is the relation
> to tcp slowstart.
> 
> 

Connmark is a netfilter patch which is required by the type of P2P 
limiting/marking projects on sf.net that could mark bittorrent traffic. 
It is incompatable with the connbytes patch which I use to mark the 
first x KB of new connections. Doing this lets me send new TCps to a 
short queue which is capped at 50% of my bandwidth. This means that some 
packets get dropped and the slowstart phase is ended before it's 
exponential nature floods my ISP buffer.

Put another way - I can game without latency spikes while a couple of 
people are browsing "heavy .jpg" type websites. It only works well if my 
link is otherwise clear - but this is a common situation for my home 
setup.


>>I also sometimes use wget and I've seen posts on LARTC from people who 
>>use squid and need to solve the same problem.
> 
> 
> I am gonna assume that you have some way to recognize the flows destined
> to localhost which you want to punish.
> 
> 
>>>
> 
> 
>>>>ppp0 one dynamic real IP ->  gateway PC -> eth0 -> LAN 192.168.0.0/24
>>>>                                  |
>>>>                                   -> local process.
>>>
>>>
>>>
>>>Ok good. Assuming you have attached your HTB etc on one or more dummy
>>>devices.
> 
> 
>>>- The third path is packets that come in from ppp0, get demasquareded,
>>>then have to either go a) to the LAN/eth0 or b)localhost bittorent
>>>process. You want to restrict b)
>>
>>Well not just restrict - dynamically share per IP total incoming 
>>bandwidth with LAN traffic using HTB.
> 
> 
> Sure - thats assumed since you attach HTB to the dummy device.
> 
> To accomodate your need for b), the idea would be as follows:
> packet gets demasquared, mark it with a fwmark

I guess you really mean mark then demasquerade.

> based on some recognition
> you have for bittorent or squid and lastly policy route it to the dummy
> device based on fwmark (since routing happens last).
> I will need to modify the dummy to not drop such packets which are
> fwmarked. 

OK I can see this as a possibility - assuming I can mark. Maybe conmark 
will be OK with connbytes sometime. I don't really know how to use it, 
but if it is possible to mark egress connections in output and have 
connmark match their incoming packets that would be a solution. I 
haven't got a clue if connmark can do this, though, just speculating.

Does anyone else know, and why it's not compatable with connbytes?

Andy.

> cheers,
> jamal
> 
> 
> 
