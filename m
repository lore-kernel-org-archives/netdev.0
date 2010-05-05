From: Scott Feldman <scofeldm@cisco.com>
Subject: Re: [RFC] net: change bridge/macvlan hook to be be generic
Date: Tue, 04 May 2010 17:58:56 -0700
Message-ID: <C80610E0.2E2EC%scofeldm@cisco.com>
References: <20100504153758.0ed3a87d@nehalam>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:19329 "EHLO
	sj-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755461Ab0EEA64 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 May 2010 20:58:56 -0400
In-Reply-To: <20100504153758.0ed3a87d@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/4/10 3:37 PM, "Stephen Hemminger" <shemminger@vyatta.com> wrote:

> The existing macvlan and bridge have special hooks in the packet input
> path. This patch changes it to a generic hook chain, like the packet type
> processing. I have been wanting to look into flow based switching, etc...

Can this be further simplified by saying that a netdev can only be hooked by
one mux (macvlan, bridge, etc) at any given time, so there is never more
than one element in the hook chain.  If so, then we just need a single hook,
not a chain.  

It seems odd to me that a dev would have both macvlan_port != NULL and
br_port != NULL.  Can dev be in a macvlan and a bridge at the same time?

-scott

