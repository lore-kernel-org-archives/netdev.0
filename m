From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.20.7 mss negotiation and path mtu discovery mostly broken?
Date: Wed, 25 Apr 2007 13:16:02 -0700 (PDT)
Message-ID: <20070425.131602.18289973.davem@davemloft.net>
References: <7CCD07160348804497EF29E9EA5560D7020F6212@exchtewks2.starentnetworks.com>
	<7CCD07160348804497EF29E9EA5560D7020F6213@exchtewks2.starentnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com
To: bristuccia@starentnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38425
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S2993063AbXDYUPy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2007 16:15:54 -0400
In-Reply-To: <7CCD07160348804497EF29E9EA5560D7020F6213@exchtewks2.starentnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Ristuccia, Brian" <bristuccia@starentnetworks.com>
Date: Wed, 25 Apr 2007 16:11:51 -0400

> > I'm seeing a 
> > problem where the kernel attempts to send packets with a MSS 
> > larger than the one negotiated when the TCP connection is 
> > established. Even after ICMP "can't fragment" messages 
> > arrive, the kernel still attempts to increase the MSS rather 
> > aggressively. The end result is extremely poor throughput 
> > when sending to a network with a smaller MTU. 
> 
> I've tracked this problem to the TSO feature in the bnx2 driver. Turning
> off TSO with "ethtool -K eth1 tso off" seems to work around the problem.
> It appears that the bnx2 device is not using the correct mss when
> performing segmentation offload. 

Thanks for narrowing it down like that.

Michael can you have a look?  Is the bnx2 firmware using the MTU
setting in the device and ignoring the passed in MSS or something
like that?

Thanks.

