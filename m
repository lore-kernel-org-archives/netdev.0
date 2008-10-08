From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH] bonding: send IPv6 neighbor advertisement on failover
Date: Wed, 8 Oct 2008 11:19:08 -0700
Message-ID: <OF3F6EE419.BE384A50-ON882574DC.0063AD5A-882574DC.0064A148@us.ibm.com>
References: <OF2E92DF11.37B32D55-ON882574DC.0060DD39-882574DC.006110E1@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Alex Sidorenko <alexandre.sidorenko@hp.com>,
	Brian Haley <brian.haley@hp.com>,
	David Miller <davem@davemloft.net>, fubar@linux.vnet.ibm.com,
	Simon Horman <horms@verge.net.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netdev-owner@vger.kernel.org,
	Vladislav Yasevich <vladislav.yasevich@hp.com>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:34626 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753635AbYJHSTP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 14:19:15 -0400
In-Reply-To: <OF2E92DF11.37B32D55-ON882574DC.0060DD39-882574DC.006110E1@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Well, actually, it looks like I'm suggesting you to re-use something that 
doesn't
exist. :-)

MLD (and IGMP) has such a thing where unsolicited advertisements are sent
multiple times, with delays in between, to account for lossy networks 
possibly
dropping the first one. There are configurable counts associated with 
probes
and retransmit intervals for solicits, but I don't see the equivalent yet 
for
unsolicited NA's.

So, instead, what I suggest is that you add (or find!) THAT knob, instead 
of a
bonding-specific one. Because adding an address that wasn't there before
has identical issues with unsolicited NA's as bonding has with activating 
a
new address. The default should probably be 1, but if you ever need to
send multiple unsolicited NA's for bonding, you probably also need it for
adding a normal address on the same network. dad_transmits is similar,
but not really the same thing.

                                                        +-DLS


netdev-owner@vger.kernel.org wrote on 10/08/2008 10:40:13 AM:

> Brian,
>         I'll make the same comment I did in the earlier version,
> which is I don't think we need a new control for the count. Instead,
> it should use the count for unsolicited NA's we send when adding
> an address. It is the same case, really, and I, FWIW, would rather
> we didn't have any more sysctl's than we need.
> 
>                                                 +-DLS
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

