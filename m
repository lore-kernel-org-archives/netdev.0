From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [PATCH Round 2 0/2][RFC] Network Event Notifier Mechanism
Date: Tue, 27 Jun 2006 10:02:19 -0500
Message-ID: <1151420539.3207.29.camel@stevo-desktop>
References: <20060626203638.19083.71231.stgit@stevo-desktop>
	 <20060627.030920.108743110.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from es335.com ([67.65.19.105]:23562 "EHLO mail.es335.com")
	by vger.kernel.org with ESMTP id S1161077AbWF0PCV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2006 11:02:21 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060627.030920.108743110.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-06-27 at 03:09 -0700, David Miller wrote:
> From: Steve Wise <swise@opengridcomputing.com>
> Date: Mon, 26 Jun 2006 15:36:38 -0500
> 
> > Round 2 Changes:
> > 
> > - cleaned up event structures per review feedback.
> > - began integration with netlink (see neighbour changes in patch 2).
> > - added IPv6 support.
> 
> Yes, ipv6 support is the main think I saw lacking.
> Especially the neighbour stuff.
> 
> How will you interpret the neighbour object properly, by
> looking at neigh->ops->family?
> 

Yea.

Also:  WRT a netlink message for REDIRECT events.  After thinking more
about this, it seems like users will already get notification of a
REDIRECT in the form of 2 messages, a RTM_DELROUTE for the old route and
a RTM_NEWROUTE message with the RTPROT_REDIRECT protocol type.  I think
this is perhaps sufficient for user mode notifications.  What do you
think?

For the RDMA kernel subsystem, however, we still need a specific event.
We need both the old and new dst_entry struct ptrs to figure out which
active connections were using the old dst_entry and should be updated to
use the new dst_entry.

Steve.


