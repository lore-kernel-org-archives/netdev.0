From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: suggestion for routing code improvement
Date: Thu, 11 Apr 2002 01:02:23 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <15540.50303.858294.986710@robur.slu.se>
References: <3CB47B90.B4CF1FAD@nortelnetworks.com>
	<15540.40277.772027.111512@robur.slu.se>
	<3CB4A6FB.F9146FDB@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: Chris Friesen <cfriesen@nortelnetworks.com>
In-Reply-To: <3CB4A6FB.F9146FDB@nortelnetworks.com>
List-Id: netdev.vger.kernel.org


Chris Friesen writes:
 > The box(es) which inspired this sit on a private network, and once they are
 > brought into service, the routes never change.  However, there is a command from
 > our gui to manually drop and raise the ethernet link (just in case something
 > goes wrong and can't be handled automatically) and it would simplify our code
 > greatly if the routes that are automatically deleted would be automatically put
 > back.

 If we limit us to "static routes" for the other routes we must definitely leave to 
 some with routing/topologi knowledge and we must not break systems with "routing 
 daemons".

 If we look into the routing world a "route" can come from different origins/routing
 protocols static/ospf/rip/bgp and there is preferences to decide which one to 
 install.

 So

 ip route add x y proto static 

 Is registered by routing daemon and installed if it has the best pref. and the 
 route is hidden otherwise to be restored when appropriate. And the route is invalid 
 but kept by the daemon over "link downs" 

 And I think

 ip route rep x y proto static 

 or something similar at link up for restoring "static" routes would not break 
 for the daemons either. But I got a feeling it can hurt more than it helps.


 > In this case, my software *is* essentially the routing daemon, and I want it to
 > be simpler to maintain.
 
 Well router daemons belongs to "user space" and via netlink you should be able to 
 do most of what you want.

 
 Cheers.

							--ro

 
