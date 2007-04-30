From: David Miller <davem@davemloft.net>
Subject: Re: [RFC, PATCH] IPV6 : add 64 bits components in struct in6_addr
 to speedup ipv6_addr_equal() & ipv6_addr_any()
Date: Mon, 30 Apr 2007 13:37:49 -0700 (PDT)
Message-ID: <20070430.133749.41636290.davem@davemloft.net>
References: <20070430162851.ca3c7869.dada1@cosmosbay.com>
	<20070430.121029.21927349.davem@davemloft.net>
	<p73bqh5zgv7.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55974
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1946809AbXD3Uhu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2007 16:37:50 -0400
In-Reply-To: <p73bqh5zgv7.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <andi@firstfloor.org>
Date: 30 Apr 2007 23:34:20 +0200

> David Miller <davem@davemloft.net> writes:
> > 
> > Unfortunately, as mentioned elsewhere, we're only able to assume
> > 32-bit alignment of ipv6 packet headers and that isn't likely to
> > change any time soon.
> 
> On x86 it would be fine at least -- unaligned access is cheap. I believe
> the same is true for POWER4/5/s390x. Should it be made conditional perhaps?

We have that conditional, it's callet {get,put}_unaligned() but it's
better to fix the infrastructure so that conditionalization isn't
even needed.
