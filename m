From: "David S. Miller" <davem@redhat.com>
Subject: Re: 3c59x
Date: Tue, 10 Jun 2003 10:12:19 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030610.101219.38691038.davem@redhat.com>
References: <20030610.085600.71109220.davem@redhat.com>
	<Pine.LNX.4.44.0306101815550.26879-100000@kenzo.iwr.uni-heidelberg.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sim@netnation.com, ralph+d@istop.com, hadi@shell.cyberus.ca,
	xerox@foonet.net, fw@deneb.enyo.de, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: bogdan.costescu@iwr.uni-heidelberg.de
In-Reply-To: <Pine.LNX.4.44.0306101815550.26879-100000@kenzo.iwr.uni-heidelberg.de>
List-Id: netdev.vger.kernel.org

   From: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
   Date: Tue, 10 Jun 2003 18:45:03 +0200 (CEST)

   With this driver I would typically get TCP bandwidth figures 
   4-5 Mbps lower than those obtained with 3c59x and noticable difference in 
   the parallel jobs timing (using MPI over TCP). I'm not saying that NAPI 
   will perform the same way, just that there might be also hardware limits 
   somewhere...
   
I think it won't, hardware interrupt mitigation schemes have lots of
problems that NAPI is more ept to deal with.

   But the real question is: does it make sense to spend time now in
   trying to improve a driver with hope for only a marginal speed
   increase ?

People who have the cards care, and I think PIO-->MMIO is more
than marginal.

You're attempt to get "latency" was ill founded :)  Your limits
have to do with the wire speed, not all the cpu cycles being eaten
by PIO acceses.

On a DoS'd router, it's another situation altogether.

   And another important question: how much improvement can be gained from
   the driver ? Folks that do parallel computation over TCP over Ethernet
   know very well that the software in the kernel is the bottleneck (extra
   copies, TCP, IRQ management, etc).

Your lmitations in parallel computation have to do with how TCP
behaves more than how TCP is implemented.

For starters try:

	echo "1" >/proc/sys/net/ipv4/tcp_low_latency

That's the kind of thing that will help parallel computation
folks, not driver hacks.

