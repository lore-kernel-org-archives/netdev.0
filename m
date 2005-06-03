From: "David S. Miller" <davem@davemloft.net>
Subject: Re: RFC: NAPI packet weighting patch
Date: Fri, 03 Jun 2005 13:22:57 -0700 (PDT)
Message-ID: <20050603.132257.23013342.davem@davemloft.net>
References: <1117824150.6071.34.camel@localhost.localdomain>
	<20050603.120126.41874584.davem@davemloft.net>
	<Pine.CYG.4.58.0506031202280.3344@mawilli1-desk2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, john.ronciak@intel.com, jdmason@us.ibm.com,
        shemminger@osdl.org, netdev@oss.sgi.com, Robert.Olsson@data.slu.se,
        ganesh.venkatesan@intel.com, jesse.brandeburg@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: mitch.a.williams@intel.com
In-Reply-To: <Pine.CYG.4.58.0506031202280.3344@mawilli1-desk2.amr.corp.intel.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Mitch Williams <mitch.a.williams@intel.com>
Date: Fri, 3 Jun 2005 12:28:10 -0700

> In a typical NAPI polling loop, the driver processes receive packets until
> it either hits the quota or runs out of packets.  Then, at the end of the
> loop, it returns all of those now-free receive resources back to the
> hardware.
> 
> With a heavy receive load, the hardware will run out of receive
> descriptors in the time it takes the driver/NAPI/stack to process 64
> packets.  So it drops them on the floor.  And, as we know, dropped packets
> are A Bad Thing.

This is why you should replenish RX packets _IN_ your
RX packet receive processing, not via some tasklet
or other seperate work processing context.

No wonder I never see this on tg3.

It is the only way to do this cleanly.
