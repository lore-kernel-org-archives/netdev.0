From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH 2.6] [IPV6] MCAST: Ensure to check multicast listener(s).
Date: Sun, 30 Mar 2008 13:05:36 -0700
Message-ID: <OF02C9B6A8.C301DBC1-ON8825741C.006D7AD5-8825741C.006E608E@us.ibm.com>
References: <20080330.231247.105318612.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: =?ISO-2022-JP?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SEYjMVFMQBsoQg==?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:41028 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752799AbYC3UFi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Mar 2008 16:05:38 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m2UK5cOs002491
	for <netdev@vger.kernel.org>; Sun, 30 Mar 2008 16:05:38 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2UK5cG8189586
	for <netdev@vger.kernel.org>; Sun, 30 Mar 2008 14:05:38 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2UK5bJd023569
	for <netdev@vger.kernel.org>; Sun, 30 Mar 2008 14:05:38 -0600
In-Reply-To: <20080330.231247.105318612.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote on 03/30/2008 
07:12:47 AM:

> In article 
<OFA7B9706D.1E52ED5D-ON8825741C.004BE625-8825741C.004BFD53@us.ibm.
> com> (at Sun, 30 Mar 2008 06:49:58 -0700), David Stevens 
<dlstevens@us.ibm.com> says:
> 
> >  > After commit ae7bf20a6316272acfcaef5d265b18aaa54b41e4, all packets
> > > for multicast destinations are delivered to upper layer if
> > > IFF_PROMISC or IFF_ALLMULTI is set.
> > 
> >         Isn't that the intent of IFF_PROMISC and IFF_ALLMULTI?
> 
> Original intent for that flag check was for optimization.
> This was assuming, WITHOUT those flags, L2 appropriately filters
> unwanted multicast packets; not true.
> 
> L2 is expected to pass all multicast to L3, but even with those flags,
> we should filter them according to our listeners, upper layer
> (extension header etc.) should not see them.

Yoshifuji-san,
        I would assume that IFF_PROMISC or IFF_ALLMULTI means that an
INADDR_ANY listener would receive all multicasts on the link, not
just ones for groups that have been joined. This would be particularly
useful for older version multicast routers or monitoring programs.
Doesn't your change remove this capability?
        If the flags are not set, the check for group membership is
done. My concern is that when one or both are set, your change
appears to prevent delivery of multicasts that currently are
delivered, meaning that you can't write an application that, for
example, monitors all multicast packets, short of joining all
groups or using a packet socket. If the IFF_ALLMULTI flag isn't
equivalent, for INADDR_ANY-bound sockets, of joining all groups,
then I don't see that it has any purpose at all.

                                                                +-DLS

