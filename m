From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: RFC: NAPI packet weighting patch
Date: Fri, 03 Jun 2005 12:49:29 -0700
Message-ID: <1117828169.4430.29.camel@rh4>
References: <20050603.120126.41874584.davem@davemloft.net>
 <Pine.CYG.4.58.0506031202280.3344@mawilli1-desk2.amr.corp.intel.com>
 <20050603.132257.23013342.davem@davemloft.net>
 <20050603.132922.63997492.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: mitch.a.williams@intel.com, hadi@cyberus.ca, john.ronciak@intel.com,
        jdmason@us.ibm.com, shemminger@osdl.org, netdev@oss.sgi.com,
        Robert.Olsson@data.slu.se, ganesh.venkatesan@intel.com,
        jesse.brandeburg@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050603.132922.63997492.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-06-03 at 13:29 -0700, David S. Miller wrote:

> E1000 processes the full QUOTA of RX packets,
> _THEN_ replenishes with new RX buffers.  No wonder
> the chip runs out of RX descriptors.
> 
> You should replenish _AS_ you grab RX packets
> off the receive queue, just as tg3 does.

Yes, in tg3, rx buffers are replenished and put back into the ring as
completed packets are taken off the ring. But we don't tell the chip
about these new buffers until we get to the end of the loop, potentially
after a full quota of packets. Doesn't this make the end result the same
as e1000?
