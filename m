From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: Route cache performance under stress
Date: Tue, 10 Jun 2003 21:53:33 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16102.14141.524918.556121@robur.slu.se>
References: <Pine.LNX.4.51.0306101332300.8755@ns.istop.com>
	<20030610.103234.116374169.davem@redhat.com>
	<16102.9418.43884.336925@robur.slu.se>
	<20030610.115759.26513736.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, ralph+d@istop.com, ralph@istop.com,
   hadi@shell.cyberus.ca, xerox@foonet.net, sim@netnation.com,
   fw@deneb.enyo.de, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030610.115759.26513736.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


David S. Miller writes:

 > How did you "rip it out"?  Just never look into the routing
 > cache hash and never add entries there?  If so, then yes it is
 > excellent simulation for pure slow path.

 Look at the patch... 
 hash lookup is bypassed -> always slow path. no lookup in rt_intern_hash
 but we keep the entry in the hash and ip_rt_dst_alloc is changed to run
 do __rt_hash_shrink for each call.

 > This is not purely an algorithmic problem.  The highest cost thing we
 > do in the slow path of input route processing is source validation.
 > This requires real brains to eliminate.
 > 
 > Actually, that's a good idea, if someone if brave just rip out
 > fib_validate_source (just don't call it, should work for valid
 > traffic) and see what happens :)

 It should be easy to do... 

 Cheers.
						--ro
