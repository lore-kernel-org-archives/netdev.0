From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: Route cache performance under stress
Date: Thu, 12 Jun 2003 15:56:47 +0200
Sender: linux-net-owner@vger.kernel.org
Message-ID: <16104.34463.60472.750699@robur.slu.se>
References: <Pine.LNX.4.51.0306101332300.8755@ns.istop.com>
	<20030610.103234.116374169.davem@redhat.com>
	<16102.9418.43884.336925@robur.slu.se>
	<20030611.234534.52193216.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, ralph+d@istop.com, ralph@istop.com,
	hadi@shell.cyberus.ca, xerox@foonet.net, sim@netnation.com,
	fw@deneb.enyo.de, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030611.234534.52193216.davem@redhat.com>
List-Id: netdev.vger.kernel.org


David S. Miller writes:

 > I want to point out an error in such simulations.
 > 
 > It doesn't eliminate some of the most expensive part of the routing
 > cache, the 'dst' management.  All of that still happens even after
 > your patch.
 > 
 > A better simulation of a "pure slowpath" would be to move the DST
 > entry into the fib entries themselves.
 > 
 > That is a lot more work, but it would validate the various ideas and
 > claims being made.  For example, it would say for sure whether
 > eliminating the routing cache is a win or not for DoS traffic.

 Well it's true. But do we need too? From the profile we actually see the 
 'dst' management cost. Not much I would say and still we will need some 
 adminstration i.e refcounting even it we should remove the route hash.
 
c023c038 107340   33.143      fn_hash_lookup
c013154c 17399    5.37223     free_block
c0211364 16502    5.09527     __rt_hash_shrink
c01316e4 12854    3.96889     kmem_cache_alloc
c01b86dc 11719    3.61844     e1000_clean_rx_irq
c02033a0 11557    3.56842     alloc_skb
c0212330 11378    3.51315     ip_route_input_slow
c020cc98 9765     3.01511     eth_type_trans
c0208860 7986     2.46581     dst_alloc
c0216d98 7733     2.38769     ip_output
c021200c 6940     2.14284     rt_set_nexthop
c0213a9c 6331     1.9548      dst_free
c0126998 6272     1.93659     rcu_do_batch
c02035cc 6164     1.90324     skb_release_data
c02036c4 6068     1.8736      __kfree_skb
c01b8558 5532     1.7081      e1000_clean_tx_irq
c01b7678 4970     1.53457     e1000_xmit_frame

 From what I understand now removing the route hash is not a good idea. It's 
 seems we can control the hash pretty well and this even under very extreme 
 conditions.
 
 I think that people who is suggesting this thinks that we can achieve same 
 performance without it. I don't think we can. So question is should we tune
 routing to do 120 kpps regardless of input or have a performance span of 
 112-420 kpps (numbers from my tests). Where we most of the time are close
 to the higher limit?

 Anyway fib_lookup seems to be something to look into regardless of this 
 question.

 Cheers.

						--ro
 
