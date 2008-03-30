From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 2.6] [IPV6] MCAST: Ensure to check multicast
 listener(s).
Date: Sun, 30 Mar 2008 23:12:47 +0900 (JST)
Message-ID: <20080330.231247.105318612.yoshfuji@linux-ipv6.org>
References: <20080330.175835.81268650.yoshfuji@linux-ipv6.org>
	<OFA7B9706D.1E52ED5D-ON8825741C.004BE625-8825741C.004BFD53@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:55460 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750800AbYC3OLS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Mar 2008 10:11:18 -0400
In-Reply-To: <OFA7B9706D.1E52ED5D-ON8825741C.004BE625-8825741C.004BFD53@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <OFA7B9706D.1E52ED5D-ON8825741C.004BE625-8825741C.004BFD53@us.ibm.com> (at Sun, 30 Mar 2008 06:49:58 -0700), David Stevens <dlstevens@us.ibm.com> says:

>  > After commit ae7bf20a6316272acfcaef5d265b18aaa54b41e4, all packets
> > for multicast destinations are delivered to upper layer if
> > IFF_PROMISC or IFF_ALLMULTI is set.
> 
>         Isn't that the intent of IFF_PROMISC and IFF_ALLMULTI?

Original intent for that flag check was for optimization.
This was assuming, WITHOUT those flags, L2 appropriately filters
unwanted multicast packets; not true.

L2 is expected to pass all multicast to L3, but even with those flags,
we should filter them according to our listeners, upper layer
(extension header etc.) should not see them.

--yoshfuji
