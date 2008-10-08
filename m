From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] bonding: send IPv6 neighbor advertisement on failover
Date: Wed, 08 Oct 2008 15:12:21 -0400
Message-ID: <48ED0615.7000007@hp.com>
References: <OF3F6EE419.BE384A50-ON882574DC.0063AD5A-882574DC.0064A148@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Alex Sidorenko <alexandre.sidorenko@hp.com>,
	Brian Haley <brian.haley@hp.com>,
	David Miller <davem@davemloft.net>, fubar@linux.vnet.ibm.com,
	Simon Horman <horms@verge.net.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netdev-owner@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:27301 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753248AbYJHTMY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 15:12:24 -0400
In-Reply-To: <OF3F6EE419.BE384A50-ON882574DC.0063AD5A-882574DC.0064A148@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David

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
> 
> So, instead, what I suggest is that you add (or find!) THAT knob, instead 
> of a
> bonding-specific one. Because adding an address that wasn't there before
> has identical issues with unsolicited NA's as bonding has with activating 
> a
> new address.

Adding a new address triggers a DAD probe which is enough to let the switch
learn the MAC address.  It's a different scenario for a link failover in
bonding.  Also, adding a new address will automatically trigger and MLD response
if a corresponding solicited node multicast address is added.

So the bonding case is rather different from everything else we've had so far.

-vlad

> The default should probably be 1, but if you ever need to
> send multiple unsolicited NA's for bonding, you probably also need it for
> adding a normal address on the same network. dad_transmits is similar,
> but not really the same thing.
> 
>                                                         +-DLS

