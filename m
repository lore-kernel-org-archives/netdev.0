From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC] net: change bridge/macvlan hook to be be generic
Date: Mon, 10 May 2010 17:58:05 +0200
Message-ID: <4BE82D0D.60504@trash.net>
References: <C80610E0.2E2EC%scofeldm@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49046 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754643Ab0EJP6G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 11:58:06 -0400
In-Reply-To: <C80610E0.2E2EC%scofeldm@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Scott Feldman wrote:
> On 5/4/10 3:37 PM, "Stephen Hemminger" <shemminger@vyatta.com> wrote:
> 
>> The existing macvlan and bridge have special hooks in the packet input
>> path. This patch changes it to a generic hook chain, like the packet type
>> processing. I have been wanting to look into flow based switching, etc...
> 
> Can this be further simplified by saying that a netdev can only be hooked by
> one mux (macvlan, bridge, etc) at any given time, so there is never more
> than one element in the hook chain.  If so, then we just need a single hook,
> not a chain.  
> 
> It seems odd to me that a dev would have both macvlan_port != NULL and
> br_port != NULL.  Can dev be in a macvlan and a bridge at the same time?

Yes, its possible to use the ebtables broute table to have packets
selectively delivered upwards in the stack instead of briding them.
"upwards" could also mean to a macvlan device.

I don't know if anyone is actually doing this, but its a configuration
which currently should work.
