From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: route cache overflow
Date: Sat, 17 Jul 2004 13:26:52 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16633.3324.909512.231023@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Robert.Olsson@data.slu.se
Return-path: <netdev-bounce@oss.sgi.com>
To: andre@insite.com.br
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Andre Uratsuka Manoel writes:
 > Hello,
 > 
 > It seems that no resolution was found for the route cache DoS issue
 > (am I wrong here?).

 Well we see different performance for different flow lengths. The numbers 
 we've see is 1 packet per flow is .22 (22%) of single flow for packet 
 forwarding. Decreasing hash chain during DoS we could increase the t-put 
 to .34 of single flow. Still Linux is very usable as it is very seldom
 in real scenarios that there is 100% DoS at all interface.

 > I was wondering, and I'd like to persue this line of thought if you
 > don't consider this stupid: wouldn't it be better, when we find that
 > the machine is under DoS to avoid creating route cache entries instead
 > of simply trying to drop entries that exist?

 I did some experiments to make the route hash per device but didn't see 
 any performance wins compared to the global hash but for policy control 
 and tuning it would probably improve things with per dev hash.
 
 ftp://robur.slu.se/pub/Linux/net-development/dhash

 But the problem is how to define/find DoS which is in reality mixed with 
 real traffic. I'm getting to think we can not have any special DoS 
 treatment at route level as this would open for new DoS attacks. We have
 to assume traffic is sane.

 > Couldn't we create entries only once for every 1<<n packets on
 > ip_route_input_slow so that flows with many packets will have route
 > cache entries created with higher probability than flows with very
 > little connections. The n variable could be adjusted according to
 > perceived DoS-ness.

 We have done a lot job already getting the skb into the CPU cache and 
 also we must look up the address to verify if it belongs to a flow or not. 

 It seems ipv6 does not create hash entries as ipv4 and should be more
 tolerant in this aspect but ipv6 has another major issue be design
 as the link nets have 2^64 addresses. Neighbor entries can overflow 
 any table.

 Also it might be interesting to see what other lookup algorithms can do.
 Working on some LPC-trie (level path compresses seach tree) code hoping 
 to able to test this for lookup someday.

 Cheers.
						--ro
 
