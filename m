From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [BUG] overflow in net/ipv4/route.c rt_check_expire()
Date: Fri, 1 Apr 2005 19:26:32 +0200
Message-ID: <16973.33864.613333.389857@robur.slu.se>
References: <42370997.6010302@cosmosbay.com>
	<20050315103253.590c8bfc.davem@davemloft.net>
	<42380EC6.60100@cosmosbay.com>
	<20050316140915.0f6b9528.davem@davemloft.net>
	<4239E00C.4080309@cosmosbay.com>
	<20050331221352.13695124.davem@davemloft.net>
	<424D5D34.4030800@cosmosbay.com>
	<16973.28254.203492.400896@robur.slu.se>
	<424D780A.9000101@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Eric Dumazet <dada1@cosmosbay.com>
In-Reply-To: <424D780A.9000101@cosmosbay.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Eric Dumazet writes:

 > According to oprofile, an unpatched kernel was spending more than 15% of time in route.c routines, now I see ip_route_input() at 1.88%

 Would like to see absolute numbers for UP/SMP single flow and DoS to be
 confident.

 > I found it was better to adjust gc_interval to 1 (to let it fire every second and examine 1/300 table slots, or more if the dynamic behavior 
 > triggers), and ajust params so that rt_garbage_collect() doesnt run at all : rt_garbage_collect() can take forever to complete, blocking 
 > network trafic.

 I don't think you can depend on timer for GC solely. Timer tick is 
 eternity for todays packet rates. You can distribute the GC load by allowing 
 it to run more frequent this in combination with huge cache seems to be a
 very interesting approach given that you have memory.

 
						--ro
