From: "David S. Miller" <davem@davemloft.net>
Subject: Re: RFC: NAPI packet weighting patch
Date: Fri, 03 Jun 2005 13:31:33 -0700 (PDT)
Message-ID: <20050603.133133.38710501.davem@davemloft.net>
References: <20050603.120126.41874584.davem@davemloft.net>
	<Pine.CYG.4.58.0506031202280.3344@mawilli1-desk2.amr.corp.intel.com>
	<1117828771.6071.77.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mitch.a.williams@intel.com, john.ronciak@intel.com, jdmason@us.ibm.com,
        shemminger@osdl.org, netdev@oss.sgi.com, Robert.Olsson@data.slu.se,
        ganesh.venkatesan@intel.com, jesse.brandeburg@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1117828771.6071.77.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Fri, 03 Jun 2005 15:59:31 -0400

> But one that you could validate by putting proper hooks. As an example,
> try to restore a descriptor every time you pick one - for an example of
> this look at the sb1250 driver.

Yes, this in my mind is exactly the problem.  TG3 does this
properly, as do several other drivers.

You should never defer RX buffer replenishment, you should
always do it as you grab packets off of the ring.  You will
starve the chip otherwise.
