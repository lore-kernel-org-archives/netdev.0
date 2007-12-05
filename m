From: Stefan Rompf <stefan@loplof.de>
Subject: Re: sockets affected by IPsec always block (2.6.23)
Date: Wed, 5 Dec 2007 19:42:31 +0100
Message-ID: <200712051942.32264.stefan@loplof.de>
References: <20071205001230.GA11391@gondor.apana.org.au> <20071205065132.GA11476@gondor.apana.org.au> <20071204.231200.117152338.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, simon@fire.lp0.eu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p07-ob.rzone.de ([81.169.146.188]:19459 "EHLO
	mo-p07-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750892AbXLESlF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 13:41:05 -0500
In-Reply-To: <20071204.231200.117152338.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Mittwoch, 5. Dezember 2007 08:12 schrieb David Miller:

> Actually, consider even a case like DNS.  Let's say the timeout
> is set to 2 seconds or something and you have 3 DNS servers
> listed, on different IPSEC destinations, in your resolv.conf
>
> Each IPSEC route that isn't currently resolved will cause packet loss
> of the DNS lookup request with xfrm_larval_drop set to '1'.
>
> If all 3 need to be resolved, the DNS lookup will fully fail
> which defeats the purpose of listing 3 servers for redundancy
> don't you think? :-)

In your example, the DNS server might actually stop responding to other 
clients while waiting for the (expected to be non-blocking) connect() to 
return. This is much much worse.

Stefan
