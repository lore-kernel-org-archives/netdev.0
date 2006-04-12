From: Roberto Nibali <ratz@drugphish.ch>
Subject: Re: Window shrinking (was Linux v2.6.16-rc6)
Date: Wed, 12 Apr 2006 23:24:37 +0200
Message-ID: <443D7015.7080707@drugphish.ch>
References: <Pine.LNX.4.64.0603111551330.18022@g5.osdl.org>	<6bffcb0e0603111751i1ed30794s@mail.gmail.com> <20060311.183904.71244086.davem@davemloft.net> <4438F952.5040802@dsl.pipex.com> <44393AB7.3050506@middle.net> <443A2A46.9050808@dsl.pipex.com> <443A7195.5070406@middle.net> <443AA46C.9080708@dsl.pipex.com> <443ABFE1.6030601@middle.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: andy.furniss@dsl.pipex.com,
	"David S. Miller" <davem@davemloft.net>,
	michal.k.k.piotrowski@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from drugphish.ch ([69.55.226.176]:27539 "EHLO www.drugphish.ch")
	by vger.kernel.org with ESMTP id S932319AbWDLVZR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2006 17:25:17 -0400
To: Mark Butler <butlerm@middle.net>
In-Reply-To: <443ABFE1.6030601@middle.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>>> Thanks Mark, I guess packeteer closes window down properly, I 
>>>> thought Dave's reply meant that doing that was Treason.
>>>
>>> Packeteer is almost certainly being cavalier about the way it reduces 
>>> windows.  It could be a serious problem, depending on the way it 
>>> treats traffic on the return path.  The "treason" thing is a joke.  
>>> It is like a bank extending you a credit line one day, and revoking 
>>> it the next.
>>
>> I don't use or know of anyone who uses Packeteer - or have you tested?

I had the distinct pleasure of partly get involved with debugging 
network stalls related to Linux clients (2.6.x kernel) and a Packeteer.

>> to mean that it was illegal to close down a window at all - you 
>> cleared that up - ie it is legal if you close it by <= the amount of 
>> data that has just been acked. I assume this won't cause the Treason 
>> messaage so don't really understand why it is cavalier - or do you 
>> just mean the whole idea of window manipulation to shape may be dodgey 
>> but legal?
> 
> I thought that Packeteer was causing the error messages.  If not then no 
> problem.  The "treason" messages will not occur if the window is reduced 
> normally.  The window is there for a reason - namely flow control.  A 
> zero rwnd means "I can't handle any more data right now".  That is 
> perfectly legal as long as previously granted transmit credit is not 
> withdrawn.  Generally speaking the rwnd always drops to zero when the 
> receive buffer is full.

Regarding Packeteer traffic shaper and Linux TCP stacks:

A customer of ours has had significant problems with the packeteer 
traffic shaper in the past. Unfortunately my consulting contract only 
lasted so long as to point out the problem with the shaper in 
conjunction with Linux clients, thus I cannot provide you with more 
detailed information.

The setup at the customer side (ISP) was like follows: they had 
installed a squid-proxy farm for their clients and used the Packeteer to 
do some sort of micro-billing, shaping and general QoS. The problem of 
window shrinking by the shaper affecting the client's performance 
manifested itself most of the time when their customers were accessing a 
site via that proxy-farm, which delivered its site-pictures using 
content caching services like Akamai (a really horrible example for 
testing squid's patience is, among others, http://www.pro-sieben.de). 
This caused quite a burst of quick TCP connection setups and teardowns, 
eventually resulting in a complete stall for 10-15s.

Disabling the Packeteer traffic shaper completely solved this issue and 
customers were not experiencing any stalls anymore when surfing the net. 
Updating the firmware of the shaper did help somewhat, so I suspect 
their TCP window handling is also error-prone to some extend. So I went 
on and blamed the Packeteer traffic shaper device. It was not until I 
tested the whole setup with their pilot squid-farm based on Solaris 
(SunOS 2.5.1) when I had to rethink my blaming, since routing their 
customers over the Solaris squid proxies did not exhibit the problem 
when enabling the traffic shaper for the same troublesome websites. So, 
this again showed an indication towards an issue with Linux clients and 
the Packeteer traffic shaper. The squid-farm is running on a SuSE 9.3 
based kernel. Due to performance constraints we had to go with the Linux 
solution and disable the traffic shaper.

As soon as I get some more consulting days and if the customer desires, 
I'll be debugging this issue in greater detail. I will send a debug 
report to netdev in this case. Chances are slim though, since they only 
have one Packeteer so far and no test network to perform test conducts, 
so erroneous tests would cause major downtime for a lot of this ISP's 
customers.

My 2 cents,
Roberto Nibali, ratz
-- 
echo 
'[q]sa[ln0=aln256%Pln256/snlbx]sb3135071790101768542287578439snlbxq' | dc
