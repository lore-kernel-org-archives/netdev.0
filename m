From: Ben Greear <greearb@candelatech.com>
Subject: more on forcing traffic to route to local interface though another
 interface.
Date: Thu, 12 Sep 2002 21:31:45 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D816A31.3050401@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "netdev@oss.sgi.com" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I've been adding printk's to the linux routing code to try to figure
out how things are working...

It appears that at least one of the reasons why what I want to do will
not work is that this code in route.c:

  	/*
	 *	Now we are ready to route packet.
	 */
	if ((err = fib_lookup(&key, &res)) != 0) {
		if (!IN_DEV_FORWARD(in_dev))
			goto e_inval;
		goto no_route;
	}

returns a 'res' that has the res.type == RTN_LOCAL.


So, does anyone know what part of the code populates
the fib tables?  I need to convince that code to never (or rarely)
use any RTN_LOCAL type, at least for certain interfaces and/or sockets.


Other ideas are welcome, of course!

Ben

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
