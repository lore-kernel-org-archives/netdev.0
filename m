From: Patrick McHardy <kaber@trash.net>
Subject: Re: vlan/macvlan 02/02: propagate transmission state to upper layers
Date: Tue, 10 Nov 2009 17:56:11 +0100
Message-ID: <4AF99B2B.7040507@trash.net>
References: <4AF99160.2060607@trash.net> <20091110084814.02593603@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40093 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757154AbZKJQ4K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 11:56:10 -0500
In-Reply-To: <20091110084814.02593603@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Tue, 10 Nov 2009 17:14:24 +0100
> Patrick McHardy <kaber@trash.net> wrote:
> 
>>   vlan/macvlan: propagate transmission state to upper layers
>>     
>>     Both vlan and macvlan devices usually don't use a qdisc and immediately
>>     queue packets to the underlying device. Propagate transmission state of
>>     the underlying device to the upper layers so they can react on congestion
>>     and/or inform the sending process.
>>     
>>     Signed-off-by: Patrick McHardy <kaber@trash.net>
> 
> 
> Bridging and bonding have same issue, but the solution is more difficult.

Yes, in both cases the packet might be sent out on multiple
interfaces, so its not really clear which state we should
propagate. I guess it would make sense to indicate an error
if transmission on *all* interfaces fail, but I'm not sure
about the other cases.
