From: "David S. Miller" <davem@davemloft.net>
Subject: Re: RFC: NAPI packet weighting patch
Date: Mon, 06 Jun 2005 12:47:25 -0700 (PDT)
Message-ID: <20050606.124725.85409439.davem@davemloft.net>
References: <468F3FDA28AA87429AD807992E22D07E0450C002@orsmsx408>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, hadi@cyberus.ca, buytenh@wantstofly.org,
        mitch.a.williams@intel.com, jdmason@us.ibm.com, shemminger@osdl.org,
        netdev@oss.sgi.com, Robert.Olsson@data.slu.se,
        ganesh.venkatesan@intel.com, jesse.brandeburg@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: john.ronciak@intel.com
In-Reply-To: <468F3FDA28AA87429AD807992E22D07E0450C002@orsmsx408>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: "Ronciak, John" <john.ronciak@intel.com>
Date: Mon, 6 Jun 2005 08:35:26 -0700

> We are dropping packets at the HW level (FIFO errors) with 256
> descriptors and the default weight of 64.  As we said reducing the
> weight eliminates this which is understandable since the driver is being
> serviced more fequently.  We also hacked the driver to do a buffer
> allocation per packet sent up the stack.  This reduced the number of
> dropped pacekts by about 80% but it was still a significant number of
> drops (190K to 39K dropped).  So I don't think this is where the problem
> is.  This is also comfimed with the tg3 driver doing the buffer update
> to the HW every 25 descriptors.

I reach a different conclusion, sorry. :-)

Here is the invariant:

	If you force the e1000 driver to do RX replenishment every N
	packets it should reduce the packet drops the same (in the
	single NIC case) as if you reduced the dev->weight to that
	same value N.

You have two test cases, single NIC and multi-NIC, so you should
be very clear in which case your drop number applies to.  They
are two totally different problems.

> We did not up the descriptor ring size with the default weight but will
> try this today and report back.

Thanks for all of your test data and hard work so far.
It's very valuable.
