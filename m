From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH] bonding: send IPv6 neighbor advertisement on failover
Date: Wed, 08 Oct 2008 15:01:58 -0400
Message-ID: <48ED03A6.2060705@hp.com>
References: <OF3F6EE419.BE384A50-ON882574DC.0063AD5A-882574DC.0064A148@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alex Sidorenko <alexandre.sidorenko@hp.com>,
	David Miller <davem@davemloft.net>, fubar@linux.vnet.ibm.com,
	Simon Horman <horms@verge.net.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netdev-owner@vger.kernel.org,
	Vladislav Yasevich <vladislav.yasevich@hp.com>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:7513 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753170AbYJHTCb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 15:02:31 -0400
In-Reply-To: <OF3F6EE419.BE384A50-ON882574DC.0063AD5A-882574DC.0064A148@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Stevens wrote:
> Well, actually, it looks like I'm suggesting you to re-use something that 
> doesn't
> exist. :-)
> 
> MLD (and IGMP) has such a thing where unsolicited advertisements are sent
> multiple times, with delays in between, to account for lossy networks 
> possibly
> dropping the first one. There are configurable counts associated with 
> probes
> and retransmit intervals for solicits, but I don't see the equivalent yet 
> for
> unsolicited NA's.

I don't see an equivalent either, since the only unsolicited NA the 
kernel sends is for DAD, which uses dad_transmits.

I left the MLD changes out of this patch so I could work on it 
separately, when I get to it I'll make sure to look at the issues you 
raised in your other email so it follows the RFC, or at least the Linux 
behavior.

> So, instead, what I suggest is that you add (or find!) THAT knob, instead 
> of a
> bonding-specific one. Because adding an address that wasn't there before
> has identical issues with unsolicited NA's as bonding has with activating 
> a
> new address. The default should probably be 1, but if you ever need to
> send multiple unsolicited NA's for bonding, you probably also need it for
> adding a normal address on the same network. dad_transmits is similar,
> but not really the same thing.

The problem is that dad_transmits can be set to zero, although not 
recommended, so if we used that value then bonding failover would be 
just as broken.  I think having this new tunable stay in the bonding 
code is useful since that's the code that's actually doing the transmit.

-Brian
