From: David Miller <davem@davemloft.net>
Subject: Re: [RFC, PATCH] IPV6 : add 64 bits components in struct in6_addr
 to speedup ipv6_addr_equal() & ipv6_addr_any()
Date: Mon, 30 Apr 2007 11:59:37 -0700 (PDT)
Message-ID: <20070430.115937.104035556.davem@davemloft.net>
References: <20070430162851.ca3c7869.dada1@cosmosbay.com>
	<463618DB.7020309@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
To: brian.haley@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34015
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1946574AbXD3S7Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2007 14:59:24 -0400
In-Reply-To: <463618DB.7020309@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Brian Haley <brian.haley@hp.com>
Date: Mon, 30 Apr 2007 12:27:07 -0400

> The problem is that drivers don't necessarily align the address on the 
> correct boundary, so on some 64-bit arches this could be fatal.  There's 
> ways around it since I did it in a previous life, but you'd need to copy 
> the addresses and hide them in the skb in the rare case, neither of 
> which is a great thing to do.

Yes, the majority of the network drivers are only ensuring 32-bit
alignment after the ethernet header currently on receive.  They
were designed with ipv4 in mind long ago and then the logic just
gets copied everywhere.
