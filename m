From: Andy Furniss <andy.furniss@dsl.pipex.com>
Subject: Re: IMQ / new Dummy device post.
Date: Sat, 17 Apr 2004 22:56:52 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4081A824.5020107@dsl.pipex.com>
References: <407E5905.9070108@dsl.pipex.com>	 <1082031313.1039.13.camel@jzny.localdomain>	 <407EE3E5.8060200@dsl.pipex.com>	 <1082087553.1035.287.camel@jzny.localdomain>	 <4080356F.4020609@dsl.pipex.com>	 <1082145341.1026.125.camel@jzny.localdomain>	 <40810957.6030209@dsl.pipex.com> <1082203795.1043.18.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1082203795.1043.18.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Sat, 2004-04-17 at 06:39, Andy Furniss wrote:
> 
> 
>>>No i dont plan to. Why do you want to go that path?
>>
>>I think it's the only way I can shape/share my ingress traffic between a 
>>  process (eg. bittorrent/squid) running on my shaping machine and 
>>traffic that is forwarded to my LAN. I masquerade onto one real dynamic IP.
> 
> 
> I think i am almost understanding you now. Your main concern is people
> using bittorrent to upload to you, correct? 
> Is there a way to recognize packets going to/from bittorent?

Quite possibly (though I think it uses connmark which I can't use as I 
use connbytes to get new tcps out of slowstart).

I also sometimes use wget and I've seen posts on LARTC from people who 
use squid and need to solve the same problem.

> 
> 
>>In the case of pre nat outbound - I know people can mark pre NAT and 
>>shape on that, but it would allow people with big LANs doing NAT to use 
>>WRR/ESFQ on src for egress traffic.
> 
> 
> Dont jump into the HOW; lets get to your setup and dissect it. Like i
> said, dont think in terms of IMQ but still think in terms of meeting
> your requirements.
> Your setup is certainly new to me (at least from what i have been told 
> or read on how people use IMQ) - so thanks for posting. This is the kind
> of thing i needed to hear about.
> 
> 
>>My setup is very simple - the only reason I use IMQ+NAT patch is because 
>>I want to use my gateway/shaping PC to run bittorrent and I want the LAN 
>>machines to have priority/fair share of incoming traffic. I guess my 
>>setup is not that common - more common are people who run squid on the 
>>same PC they shape/do NAT on.
>>
>>ppp0 one dynamic real IP ->  gateway PC -> eth0 -> LAN 192.168.0.0/24
>>                                   |
>>                                    -> local process.
> 
> 
> 
> Ok good. Assuming you have attached your HTB etc on one or more dummy
> devices.
> 
> - packets from local Lan can be marked at ingress and redirect to a
> dummy if needed. Infact you can do this on the egress at ppp0 as well
> using the new tc -i <inputdev> that i introduced. So this is easy.
> 
> - packets from the bittorent process can be marked by iptables before
> they get NATed (is this right?). Such packets can then be redirected to
> dummy from egress of ppp0 using fw classifier. So again this is easy.

Yes - egress is sortable without IMQ.

> 
> - The third path is packets that come in from ppp0, get demasquareded,
> then have to either go a) to the LAN/eth0 or b)localhost bittorent
> process. You want to restrict b)

Well not just restrict - dynamically share per IP total incoming 
bandwidth with LAN traffic using HTB.


Andy.

  - is that correct? I have some
> suggestion, but need you to verify this part.
> 
> cheers,
> jamal
> 
> 
