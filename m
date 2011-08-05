From: Amit Salecha <amit.salecha@qlogic.com>
Subject: RE: [PATCHv2 NEXT 1/1] netxen: add vlan accel support
Date: Fri, 5 Aug 2011 06:04:10 -0500
Message-ID: <99737F4847ED0A48AECC9F4A1974A4B80FE464EF99@MNEXMB2.qlogic.org>
References: <1312536015-21719-2-git-send-email-amit.salecha@qlogic.com>
	<20110805.024247.1468547132343070339.davem@davemloft.net>
	<99737F4847ED0A48AECC9F4A1974A4B80FE464EF82@MNEXMB2.qlogic.org>
 <20110805.032606.1214964517719657458.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	Ameen Rahman <ameen.rahman@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe006.messaging.microsoft.com ([216.32.180.16]:1100 "EHLO
	VA3EHSOBE009.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753006Ab1HELES convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Aug 2011 07:04:18 -0400
In-Reply-To: <20110805.032606.1214964517719657458.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: David Miller [mailto:davem@davemloft.net]
> Sent: Friday, August 05, 2011 3:56 PM
> 
> From: Amit Salecha <amit.salecha@qlogic.com>
> Date: Fri, 5 Aug 2011 05:12:37 -0500
> 
> > After fw recovery we don't get vlan devices by any kernel api, so we
> > are adding NETIF_VLAN_ACC support.  Earlier kernel had vlan group
> > support, through that we get vlan devices and then their ip
> > addresses.
> 
> Every time an IP address is added or removed there is a notification
> generated on the "inetaddr_chain", and you seem to be properly using
> this.
> 
> You have the VLAN device expansion in there as well.
> 
> Why doesn't this work?
> 
> The IP addresses cannot be added or removed from the VLAN device
> until it is attached to your device.  So you should see any IP
> address manipulation that occurs for VLANs stacked on top of
> your device.
>

This is true, but problem is after fw recovery. So flow is 
1) vlan device added
2) Driver program ip address of vlan device (through inet events)
3) Fw recovery
4) After fw recovery driver need to program ip addresses again which were already programmed.
   After fw recovery there won't be any inet/netdev event.

Simple solution is to maintain those ip addresses in driver.

It can be more easier, if we can get vlan ip addresses(or vlan device) by some kernel api.

-Amit
 


