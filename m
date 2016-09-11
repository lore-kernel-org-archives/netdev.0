From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 00/11] net: Convert vrf to tx hook
Date: Sat, 10 Sep 2016 23:13:17 -0700 (PDT)
Message-ID: <20160910.231317.431318504608631938.davem@davemloft.net>
References: <1473534602-23602-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shm@cumulusnetworks.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52430 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751568AbcIKGNY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Sep 2016 02:13:24 -0400
In-Reply-To: <1473534602-23602-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Sat, 10 Sep 2016 12:09:51 -0700

> The motivation for this series is that ICMP Unreachable - Fragmentation
> Needed packets are not handled properly for VRFs. Specifically, the
> FIB lookup in __ip_rt_update_pmtu fails so no nexthop exception is
> created with the reduced MTU. As a result connections stall if packets
> larger than the smallest MTU in the path are generated.
> 
> While investigating that problem I also noticed that the MSS for all
> connections in a VRF is based on the VRF device's MTU and not the
> route the packets ultimately go through. VRF currently uses a dst
> to direct packets to the device. The first FIB lookup returns this dst
> and then the lookup in the VRF driver gets the actual output route. A
> side effect of this design is that the VRF dst is cached on sockets
> and then used for calculations like the MSS.
> 
> This series fixes this problem by removing the hook in the FIB lookups
> that returns the dst pointing to the VRF device to the VRF and always
> doing the actual FIB lookup. This allows the real dst to be used
> throughout the stack (for example the MSS). Packets are diverted to
> the VRF device on Tx using an l3mdev hook in the output path similar to
> to what is done for Rx. The end result is a simpler implementation for
> VRF with fewer intrusions into the network stack and symmetrical packet
> handling for Rx and Tx paths.
 ...

Series applied, thanks David.
