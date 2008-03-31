From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 2.6] [IPV6] MCAST: Ensure to check multicast
 listener(s).
Date: Mon, 31 Mar 2008 11:50:01 +0900 (JST)
Message-ID: <20080331.115001.70855239.yoshfuji@linux-ipv6.org>
References: <20080330.231247.105318612.yoshfuji@linux-ipv6.org>
	<OF02C9B6A8.C301DBC1-ON8825741C.006D7AD5-8825741C.006E608E@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:55484 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751626AbYCaCsa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Mar 2008 22:48:30 -0400
In-Reply-To: <OF02C9B6A8.C301DBC1-ON8825741C.006D7AD5-8825741C.006E608E@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <OF02C9B6A8.C301DBC1-ON8825741C.006D7AD5-8825741C.006E608E@us.ibm.com> (at Sun, 30 Mar 2008 13:05:36 -0700), David Stevens <dlstevens@us.ibm.com> says:

> > L2 is expected to pass all multicast to L3, but even with those flags,
> > we should filter them according to our listeners, upper layer
> > (extension header etc.) should not see them.
> 
> Yoshifuji-san,
>         I would assume that IFF_PROMISC or IFF_ALLMULTI means that an
> INADDR_ANY listener would receive all multicasts on the link, not
> just ones for groups that have been joined. This would be particularly
> useful for older version multicast routers or monitoring programs.
> Doesn't your change remove this capability?

No, do not mix L2 and L3 here, and AFAIK, BSDs does not mix also.
Regardless if IFF_PROMISC and/or IFF_ALLMULTI is set, packet delivery
to standard sockets must not be changed.
This does NOT change OLDER applications because we did not have this
kind of confusion before.

>         If the flags are not set, the check for group membership is
> done. My concern is that when one or both are set, your change
> appears to prevent delivery of multicasts that currently are
> delivered, meaning that you can't write an application that, for
> example, monitors all multicast packets, short of joining all
> groups or using a packet socket. If the IFF_ALLMULTI flag isn't
> equivalent, for INADDR_ANY-bound sockets, of joining all groups,
> then I don't see that it has any purpose at all.

Even if IFF_PROMISC is set we do not receive unicast packet on  
standard socket bound on ::.  Same for multicast.
Current behavior is broken (*) and must be fixed.
If you really really want the short-cut, we could introduce a new 
socket option (say, IPV6_MULTICAST_ALL).

*: It was slightly broken before the commit, and 2.4 is not broken.

--yoshfuji
