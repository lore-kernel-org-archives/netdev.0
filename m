From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Thu, 6 Jan 2005 21:29:14 +0100
Message-ID: <16861.40858.80960.794144@robur.slu.se>
References: <200501031455.26980.jeremy.guthrie@berbee.com>
	<200501060926.54588.jeremy.guthrie@berbee.com>
	<16861.32852.11187.131058@robur.slu.se>
	<200501061335.55104.jeremy.guthrie@berbee.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Robert Olsson <Robert.Olsson@data.slu.se>,
        Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: jeremy.guthrie@berbee.com
In-Reply-To: <200501061335.55104.jeremy.guthrie@berbee.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Jeremy M. Guthrie writes:

 > >  You only use CPU0 for packet processing. Also it seems you use  the
 > > non-NAPI version of e1000.
 > The E1000 driver is the stock driver in 2.4.28.


 There is a kernel config option.  Use Rx Polling (NAPI)
 
 > eth2 is TX only.  We don't receive anything on it.  This system should only 
 > ever RX on eth3 and TX on eth2 as part of its function.  

 Ok! So unidirectional traffic and CPU0 processes all skb's and passes them 
 over to CPU1 which touches and frees them. You could try some other 
 affinity setting later on but there are so many options depending what 
 we want do. If we just want to compare 2.4/2.6 we can start out simple 
 with setting affinity so only one CPU. Which is almost what you got.
 We reach all the complicated problems immediately... Now we pass skb's
 between the CPU's which release cache bouncing and makes slab rebalance it's
 pools. So using just one CPU is probably better... If we had incoming pkts
 on eth2 eventually we could have had any use for CPU1.

 Install NAPI-driver, set affinity so eth2/eth3 uses same CPU to start with.

 The stats info you sent was almost impossible to read. See if you can get 
 only the rtstats.

						--ro
