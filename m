From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH Round 2 0/2][RFC] Network Event Notifier Mechanism
Date: Tue, 27 Jun 2006 03:09:20 -0700 (PDT)
Message-ID: <20060627.030920.108743110.davem@davemloft.net>
References: <20060626203638.19083.71231.stgit@stevo-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:53643
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932705AbWF0KKH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 06:10:07 -0400
To: swise@opengridcomputing.com
In-Reply-To: <20060626203638.19083.71231.stgit@stevo-desktop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Steve Wise <swise@opengridcomputing.com>
Date: Mon, 26 Jun 2006 15:36:38 -0500

> Round 2 Changes:
> 
> - cleaned up event structures per review feedback.
> - began integration with netlink (see neighbour changes in patch 2).
> - added IPv6 support.

Yes, ipv6 support is the main think I saw lacking.
Especially the neighbour stuff.

How will you interpret the neighbour object properly, by
looking at neigh->ops->family?

> Questions:
> 
> - this patch is enabling some of the functionality that was under
>   CONFIG_ARPD.  Should I remove the CONFIG_ARPD stuff, leave it as-is
>   or what?

I think how you changed it is fine.

> - what about support for other afs?  Should I hook AF_DECnet?  IPX? Or is
>   AF_INET and AF_INET6 sufficient?

Probably this should be done on an as-needed basis.

> - I added a new RTM type in rtnetlink.h for neighbour change netlink
>   messages.  I suspect I did it wrong...

The low 3-bits of rtnetlink commands indicate the "kind".
So you have to be careful.  See rtnetlink_rcv_msg() for details.

You also have to update the tables in net/core/rtnetlink.c when
you add new values.  In particular rt_min[].
