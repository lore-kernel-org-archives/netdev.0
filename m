From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance under stress
Date: Tue, 10 Jun 2003 11:57:59 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030610.115759.26513736.davem@redhat.com>
References: <Pine.LNX.4.51.0306101332300.8755@ns.istop.com>
	<20030610.103234.116374169.davem@redhat.com>
	<16102.9418.43884.336925@robur.slu.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralph+d@istop.com, ralph@istop.com, hadi@shell.cyberus.ca,
   xerox@foonet.net, sim@netnation.com, fw@deneb.enyo.de, netdev@oss.sgi.com,
   linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert.Olsson@data.slu.se
In-Reply-To: <16102.9418.43884.336925@robur.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Robert Olsson <Robert.Olsson@data.slu.se>
   Date: Tue, 10 Jun 2003 20:34:50 +0200
   
   I ripped out the route hash just to test the slow path. Seems like your 
   patch was very good as we see the same performance w/o dst hash ~114 kpps.

How did you "rip it out"?  Just never look into the routing
cache hash and never add entries there?  If so, then yes it is
excellent simulation for pure slow path.

This is not purely an algorithmic problem.  The highest cost thing we
do in the slow path of input route processing is source validation.
This requires real brains to eliminate.

Actually, that's a good idea, if someone if brave just rip out
fib_validate_source (just don't call it, should work for valid
traffic) and see what happens :)
