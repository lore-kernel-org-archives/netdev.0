From: Erik Hugne <erik.hugne@ericsson.com>
Subject: Re: tipc: MTU discovery
Date: Tue, 5 Mar 2013 15:18:24 +0100
Message-ID: <20130305141824.GG15384@eerihug-hybrid.ki.sw.ericsson.se>
References: <CAGUzgdKJ4pPdhx7VkGCGS8CynXgOrxhTu8dZ+s77C+WKrCcCeA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, jon.maloy@ericsson.com,
	allan.stephens@windriver.com
To: Sebastian =?iso-8859-1?Q?P=F6hn?= <sebastian.poehn@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw2.ericsson.se ([193.180.251.37]:54792 "EHLO
	mailgw2.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754580Ab3CEOWP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Mar 2013 09:22:15 -0500
Content-Disposition: inline
In-Reply-To: <CAGUzgdKJ4pPdhx7VkGCGS8CynXgOrxhTu8dZ+s77C+WKrCcCeA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 05, 2013 at 01:43:29PM +0100, Sebastian P=F6hn wrote:
> State Messages larger than 1500 which as used for the MTU negotiation
> do not appear in the TIPC stack. But I am able to seen them entering
> the correct device.
> Because of that no reply with the correct max_packet field set can be
> send and the negotiation will always end up at 1.5k.
>=20
> So my questions are:
> # Is TIPC meant to detect and use the MTU larger than 1.5k?
Yes, it should probe and detect MTU's up to ~66k

> # Why are the packets not passed to the TIPC stack?
TIPC just registers itself as a handler for ETH_P_TIPC through dev_add_=
pack.
If link mtu probes >1.5k are not passed to TIPC, it sounds to me that t=
he NIC driver
is to blame. What NIC type and kernel version are you running?

Do you see any packet drops in ethtool statistics?

//E
