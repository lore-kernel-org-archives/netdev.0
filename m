From: Ben Greear <greearb@candelatech.com>
Subject: Re: send-to-self (was Re: routing bug report for 2.4)
Date: Tue, 01 Jul 2003 15:07:12 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F020610.2080109@candelatech.com>
References: <Pine.LNX.4.44.0307020030170.1076-100000@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.44.0307020030170.1076-100000@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Julian Anastasov wrote:
> 	Hello,
> 
> On Mon, 30 Jun 2003, Ben Greear wrote:
> 
> 
>>You should be able to easily test most of the changes your code
>>if you have a machine with two ethernet interfaces and a loopback
>>cable...
> 
> 
> 	ok, tested the 2.5 version, the patch files are updated:
> 
> http://www.ssi.bg/~ja/#loop
> 
> - added missing dev_put on ENETDOWN
> - removed the checks that ignore oif for local routes as Alexey suggests
> 
> 	I have tried simple tests: ICMP, telnet. What I see
> is that the 2.5 rt_set_nexthop() does not set sysctl_ip_default_ttl if
> res->fi is NULL and that causes the icmp echo packets to use
> ttl=0. May be there are still some noisy places like arp_set_predefined,
> it will need further investigation. I'm stopping here, for now.

How did you get telnet to bind to a particular local interface?  Also, what
ping syntax did you use?  Did you have to modify either of these applications
to get them to work?

I looked at the patch...but don't have a good enough grasp of the routing
code to provide a useful critique.  I believe my patch _is_ smaller though ;)

Thanks,
Ben

> 
> 
>>My requirements are:
>>
>>1)  Both ethernet ports communicate over the exernal link, UDP & IP traffic.
> 
> 
> 	Done
> 
> 
>>     Third-party programs if possible, thus I set the flag on the interface in
>>     my patch, not on an individual socket, though I do have to BINDTODEVICE and
>>     policy-base base route to get things working right...
> 
> 
> 	Now you have 2 options:
> 
> - bind to src IP: the app needs to be aware for that
> 
> - ip route replace local IP2 dev DEV2 ... src IP1 table local: the app
> does not need to be aware to use this feature
> 
> 	Now using BINDTODEVICE can cause problems with this feature,
> because we do not ignore oif for local destinations, you risk to
> miss the local route and arp_filter to break the things or worse (not
> tested)
> 
> 
>>1b)  Allow both same-subnet comm (eth1 & eth2 are on same subnet), and also
>>      routed traffic (eth1 & eth2 have their own default router, similar to the
>>      previously discussed routing setup)
> 
> 
> 	all other routes remain unchanged, I hope
> 
> 
>>2)  Allow normal non-looped communication on the ports, including policy-based routing
>>     based on source addr.
> 
> 
> 	hm, you better know what you mean. As expected, this feature
> has its drawbacks. The safe way is to teach some apps to bind to
> IP1 and the apps that are unaware for these loops to use the prefsrc
> and thus to use lo. There is no much space for improvement here but
> I'm open for suggestions.
> 
> 
>>Thanks,
>>Ben
> 
> 
> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>
> 


-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
