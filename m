From: Zdenek Radouch <zdenek@rcn.com>
Subject: Re: Do you know the linux TCP stack?
Date: Sat, 05 Mar 2005 12:11:29 -0500
Message-ID: <E1D7cr7-0006TO-00@smtp06.mrf.mail.rcn.net>
References: <E1D7aML-0007Wp-00@smtp01.mrf.mail.rcn.net>
 <E1D7aML-0007Wp-00@smtp01.mrf.mail.rcn.net> <4229DF97.2040500@auto.ucl.ac.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: netdev@oss.sgi.com, linux-net@vger.kernel.org
In-Reply-To: <4229DF97.2040500@auto.ucl.ac.be>
References: <E1D7aML-0007Wp-00@smtp01.mrf.mail.rcn.net>
 <E1D7aML-0007Wp-00@smtp01.mrf.mail.rcn.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


That's correct. The routing has already been done (I'm about to queue the
packet to the hardware), and all I need is to find the IP address that came
out of the routing function.  As you said, the address may or may not be
the one in the IP header.  So how do I get hold of it?  In the BSD stack,
this address is part of the transmit API, but under Linux that does not seem
to be the case.

To illustrate this further, my hardware uses the interface IP addreses also
for the physical layer (instead of Ethernet addresses).  Before I send the
packet
I need to fill the physical header.  This would normally be done by ARP,
but in my case the IP to physical is an identity mapping.  I just have no clue
how to implement it under a stack/API that seems to target mainly the Ethernet
model.

-Zdenek


At 05:34 PM 3/5/05 +0100, Vincent Guffens wrote:
>Zdenek Radouch wrote:
>> I ran out of ideas.  Can't find the answers in any docs,
>> and I don't have time to read and analyze the source right now.
>> 
>> I will hire you to help me; I need the following to be done in
>> my net device driver:
>> 
>> With the ARP disabled (this is well documented so I believe I've done
that),
>> while queueing the physical output, I need to get hold of the IP address
>> of where the packet is being sent.  Yes, I mean IP address, not
>> Ethernet address, and yes this is not the destination addresses in
>> the IP header.
>
>can you not use the routing table ? In a normal setup, either the 
>network part of your destination IP matches the network part of a 
>directly connected network and the address your are looking for is the 
>destination IP in the packet or it does not match and the next IP is the 
>  IP of the gateway found by routing.
>
>Is it what you are looking for ?
>
>
>-- 
>				Vincent Guffens
>				PhD Student UCL/CESAME
>				tel:   +32 10 47 80 30
>Value your freedom, or you will lose it, teaches history.
>"Don't bother us with politics," respond those who don't want to learn.
>	      	-- Richard M. Stallman
>-
>To unsubscribe from this list: send the line "unsubscribe linux-net" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
