From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][IPv6]: Fix incorrect length check in rawv6_sendmsg()
Date: Thu, 29 Mar 2007 14:26:44 -0700 (PDT)
Message-ID: <20070329.142644.70222545.davem@davemloft.net>
References: <1175203048.16183.14.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: sri@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54162
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750936AbXC2V04 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Mar 2007 17:26:56 -0400
In-Reply-To: <1175203048.16183.14.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Thu, 29 Mar 2007 14:17:28 -0700

> The check for length in rawv6_sendmsg() is incorrect.
> As len is an unsigned int, (len < 0) will never be TRUE.
> I think checking for IPV6_MAXPLEN(65535) is better.
> 
> Is it possible to send ipv6 jumbo packets using raw
> sockets? If so, we can remove this check.

I don't see why such a limitation against jumbo would exist,
does anyone else?

Thanks for catching this Sridhar.  A good compiler should simply
fail to compile "if (x < 0)" when 'x' is an unsigned type, don't
you think :-)
