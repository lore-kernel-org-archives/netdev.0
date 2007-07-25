From: Patrick McHardy <kaber@trash.net>
Subject: Re: Tc filtering: broken 802_3 classifier?
Date: Wed, 25 Jul 2007 02:31:31 +0200
Message-ID: <46A699E3.2000609@trash.net>
References: <D5C1322C3E673F459512FB59E0DDC32903484027@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37050 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759329AbXGYAcL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2007 20:32:11 -0400
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC32903484027@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Waskiewicz Jr, Peter P wrote:
> [...]
> Now I add a filter for ethernet (802.3), and things aren't as happy:
> 
> # tc filter add dev eth0 protocol 802_3 parent 1: prio 2 u32 match u32
> <first 4 bytes of dst mac address> 0xffffffff at 0 match u32 <last 2
> bytes of dst mac address> 0xffff0000 at 4 flowid 1:1
> 
> This should match the destination MAC address of outgoing packets, and
> put it into flowid 1:1.  For pings, using the normal priomap, they go
> into 1:2, so ping should be a good candidate for seeing if it goes into
> 1:1.  In this case, it does not filter into 1:1.


The protocol match is on skb->protocol, so it case of ethernet its
on the ethernet protocol, which is ETH_P_IP or "ip" for IPv4.
