From: Andrea G Forte <andreaf@cs.columbia.edu>
Subject: Re: Very slow change of IP in kernel (slow socket?).
Date: Wed, 22 Dec 2004 12:37:14 -0500
Message-ID: <41C9B0CA.6060409@cs.columbia.edu>
References: <41C895D6.2040001@cs.columbia.edu> <20041222162632.GC29278@svana.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Martijn van Oosterhout <kleptog@svana.org>
In-Reply-To: <20041222162632.GC29278@svana.org>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yes, I apologize for the confusion.
I am trying to achieve a faster L3 handoff on a wireless network. Right 
now it seems like one of the biggest bottlenecks is in the kernel.
After I change IP address of the client (ip address add 
xxx.xxx.xxx.xxx/yy dev wlan0) and update all the routing info (ip route 
replace default via zzz.zzz.zzz.zzz, ip route replace kkk.kkk.0.0/yy dev 
wlan0 proto kernel src xxx.xxx.xxx.xxx), the old IP is still used to 
send packets as I mentioned earlier.
Note that I did not delete the old IP, I just set a new IP and changed 
the routing info. The old IP however it is invalid in the new subnet, 
but the kernel does not seem to realize it at all, at least for about 
500ms (even though I have changed all the routing info with the new IP).
Yes, perhaps it could be a problem related to the routing table being 
slow to update.
I will do some more testing and let you know.

Thank you,
Andrea



Martijn van Oosterhout wrote:

>Seems long, but have you condered other possible delays, like ARP,
>routing daemons, etc. BTW, I don't quite understand what you mean by
>changing IPs, because "ip route add" adds routes, not IPs. Presumably
>you're using an unbound UDP socket. You need to be a bit clearer about
>what you're actually trying to do...
>
>On Tue, Dec 21, 2004 at 04:29:58PM -0500, Andrea G Forte wrote:
>  
>
>>Hi all,
>>
>>after some talking I decided to try again and post a specific thread for 
>>this problem.
>>I noticed that when I change IP address for the same wireless card 
>>(since I am moving to a different subnet I need a new IP), the actual 
>>change in the kernel happens between 300 to 500 ms later. In particular, 
>>after changing the IP (ip route add...) and updating route table and 
>>default gw, the actual data packets are sent using the new IP only after 
>>300 to 500 ms after setting all the above.
>>Does anyone of you know what this could be related to? Or, does anyone 
>>of you know where in the kernel code I could start looking for some answers?
>>I have already had some feedback with suggestions to look into the 
>>route_cache, however this does not seem to me as a route problem but 
>>more as a socket problem and perhaps some kind of timer that is set to 
>>refresh the socket info in the kernel.
>>
>>Any help would be really appreciated.
>>
>>Thanks all,
>>Andrea
>>-
>>To unsubscribe from this list: send the line "unsubscribe linux-net" in
>>the body of a message to majordomo@vger.kernel.org
>>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>    
>>
>
>  
>

