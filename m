From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance under stress
Date: Wed, 11 Jun 2003 23:45:34 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030611.234534.52193216.davem@redhat.com>
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

   I ripped out the route hash just to test the slow path.

I want to point out an error in such simulations.

It doesn't eliminate some of the most expensive part of the routing
cache, the 'dst' management.  All of that still happens even after
your patch.

A better simulation of a "pure slowpath" would be to move the DST
entry into the fib entries themselves.

That is a lot more work, but it would validate the various ideas and
claims being made.  For example, it would say for sure whether
eliminating the routing cache is a win or not for DoS traffic.
