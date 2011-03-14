From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Disable rp_filter for IPsec packets
Date: Mon, 14 Mar 2011 15:14:24 -0700 (PDT)
Message-ID: <20110314.151424.212690587.davem@davemloft.net>
References: <4D7E88C7.5080706@cbnco.com>
	<20110314.144156.245399355.davem@davemloft.net>
	<4D7E928C.1030707@cbnco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: msmith@cbnco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53778
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753536Ab1CNWNr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 18:13:47 -0400
In-Reply-To: <4D7E928C.1030707@cbnco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Smith <msmith@cbnco.com>
Date: Mon, 14 Mar 2011 18:11:24 -0400

> David Miller wrote:
>> I was trying to get you to think out of the box and come up with
>> something clever, but that isn't working. :-)
> 
> Yes, I got that, but I don't know what you are looking for, and don't
> expect to succeed by trying something else at random.

Existing arguments might be large enough to carry more than one piece
of information :-)

>> In short, fib_validate_source() is nothing but completely unnecessary
>> overhead in the common case.
> 
> I'm not entitled to an opinion about fib_validate_source(). It feels
> like it might be trying to do one too many things. If it were my code
> I might split the RPF out from the spec_dst calculation, move the
> whole lot into net/ipv4/route.c, and only do the fib_lookup() if RPF
> is enabled or CONFIG_IP_ROUTE_CLASSID (i.e. we need to know the itag).

Can't split two two things up, because spec_dst is a product of the
reverse FIB lookup, in the form of FIB_RES_PREFSRC().
