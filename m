From: Stephen Clark <sclark46@earthlink.net>
Subject: Re: Trouble Shooting ipsec
Date: Tue, 08 Feb 2011 14:33:17 -0500
Message-ID: <4D519A7D.5010405@earthlink.net>
References: <4D504563.5010802@earthlink.net> <20110208183527.GA7450@hmsreliant.think-freely.org>
Reply-To: sclark46@earthlink.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-dupuy.atl.sa.earthlink.net ([209.86.89.62]:49281 "EHLO
	elasmtp-dupuy.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754441Ab1BHTdS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Feb 2011 14:33:18 -0500
In-Reply-To: <20110208183527.GA7450@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/08/2011 01:35 PM, Neil Horman wrote:
> On Mon, Feb 07, 2011 at 02:17:55PM -0500, Stephen Clark wrote:
>    
>> Hello,
>>
>> How do I find out what is happening to my packets thru my ipsec tunnel.
>> They just seem to disappear on the remote side.
>>
>> I have successfully got the pings thru
>> when everything has an ipv6 address, but am not successful when trying
>> to connect two ipv4 lans across an ipv6 ipsec tunnel. All fw chains
>> both 4 and 6
>> are set to ACCEPT. NAT is turned off.
>>
>>       eth0               eth1
>> eth1                 eth0
>> 10.1.254.254/17  2001:xxxx:1628::254<----ipv6 internet ----->
>> 2001:xxxx:e334::254  10.0.254.254/17
>>
>> 12:00:02.296972 IP6 2001:xxxx:1628::254>  2001:xxxx:e334::254:
>> ESP(spi=0x07454bc3,seq=0x28b), length 132
>> 12:00:03.308751 IP6 2001:xxxx:1628::254>  2001:xxxx:e334::254:
>> ESP(spi=0x07454bc3,seq=0x28c), length 132
>> 12:00:04.296857 IP6 2001:xxxx:1628::254>  2001:xxxx:e334::254:
>> ESP(spi=0x07454bc3,seq=0x28d), length 132
>> 12:00:05.293748 IP6 2001:xxxx:1628::254>  2001:xxxx:e334::254:
>> ESP(spi=0x07454bc3,seq=0x28e), length 132
>> 12:00:06.296623 IP6 2001:xxxx:1628::254>  2001:xxxx:e334::254:
>> ESP(spi=0x07454bc3,seq=0x28f), length 132
>>
>> I have posted to the ipsec-devel list and haven't gotten any
>> responses. Also I have spent 2 days googling with
>> no results about the above setup. Is it even possible to tunnel ipv4
>> packet thru an ipv6 ipsec tunnel?
>>
>> Thanks,
>> Steve
>>
>>      
> I'd start by looking at your stats counters to see if you're dropping anything
> significat.  It appears from what you have above that you're receiving end is
> getting encapsulated packets, so at least your tunnel is functional.  Take a
> look at proc/net/snmp and see if any counters get bumped as you send data.  I
> expect you're loosing them somewhere during decode (which would show up in
> /proc/net/xfrm_stat), or you're loosing them after you decode them and try to
> receive/forward them (which would likely show up in /proc/net/snmp).  That
> should give you a clue as to where to look next
>
> Neil
>
>    
>>      
>    
Thanks for the tip. I wasn't aware of /proc/net/xfrm_stat

I was able to work around by creating an ipv6 to ipv6 ipsec tunnel
and then creating an ipip6 tunnel inside of ipv6-ipv6 ipsec tunnel.

I'll continue investigating. It just so frustrating when the ipsec packets
just get dropped and you have no idea why. I wish there were some hooks
in the kernel so you could at least get some debug information about what is
happening.



-- 

"They that give up essential liberty to obtain temporary safety,
deserve neither liberty nor safety."  (Ben Franklin)

"The course of history shows that as a government grows, liberty
decreases."  (Thomas Jefferson)



