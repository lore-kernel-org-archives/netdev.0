From: "David S. Miller" <davem@davemloft.net>
Subject: Re: RFC: NAPI packet weighting patch
Date: Fri, 03 Jun 2005 13:30:41 -0700 (PDT)
Message-ID: <20050603.133041.35664164.davem@davemloft.net>
References: <468F3FDA28AA87429AD807992E22D07E0450BFE8@orsmsx408>
	<17056.47835.583602.151291@robur.slu.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.ronciak@intel.com, jdmason@us.ibm.com, shemminger@osdl.org,
        hadi@cyberus.ca, mitch.a.williams@intel.com, netdev@oss.sgi.com,
        ganesh.venkatesan@intel.com, jesse.brandeburg@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert.Olsson@data.slu.se
In-Reply-To: <17056.47835.583602.151291@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Robert Olsson <Robert.Olsson@data.slu.se>
Date: Fri, 3 Jun 2005 22:17:31 +0200

>  It is possible that a lower weight forced your driver to disable interrupts
>  and do packet reception w/o interrupts often this is more efficient as
>  we get rid intr. latency etc.
> 
>  Again I think weight should only used for fairness and not control the
>  threshold when to disable interrupts.
>  
>  You can test with a new policy in e1000_clean so you schedule for a new 
>  poll if work_done (any pkts received) or tx_cleaned is true.

I don't think this is it.   What's happening is that E1000
pulls up to a full dev->quota of packets off the ring,
and _THEN_ goes back and does RX buffer replenishing.

It is very clear why E1000 runs out of RX descriptors with
this kind of policy.

I outlined a way to fix this in the E1000 driver in another
email.
