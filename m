From: David Miller <davem@davemloft.net>
Subject: Re: unintended ipv4 broadcast policy change
Date: Wed, 22 Jun 2011 17:42:13 -0700 (PDT)
Message-ID: <20110622.174213.1892570153480227781.davem@davemloft.net>
References: <20110622.163935.2248705300315908767.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.hengli.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43837 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758174Ab1FWAmT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2011 20:42:19 -0400
In-Reply-To: <20110622.163935.2248705300315908767.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 22 Jun 2011 16:39:35 -0700 (PDT)

> Contrary to previous discussions I see no code in the ISC dhcp
> client that needs to get at the MAC address.  It merely wants
> it there so that it's packet parsing engine can skip over it
> to get at the ipv4/UDP bits.

I take this back, it does want the "from" MAC address.  When
using plain BSD sockets, it zeros out the address since as we
know the MAC info is not available with normal UDP sockets.

But the ISC DHCP code never actually uses this information at all,
it only stores it away in the "struct packet" structure, never to
be used again.

That's probably because the info it needs is present in the "chaddr"
field of the DHCP packet.  And only the server side actually needs
this.
