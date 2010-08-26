From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] ipv6: Enable netlink notification for tentative
 addresses.
Date: Wed, 25 Aug 2010 21:24:56 -0700 (PDT)
Message-ID: <20100825.212456.71107442.davem@davemloft.net>
References: <1282760777-15381-1-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41526
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751116Ab0HZEYl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Aug 2010 00:24:41 -0400
In-Reply-To: <1282760777-15381-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>
Date: Wed, 25 Aug 2010 11:26:17 -0700

> By default, netlink messages are not sent when an IPv6 address
> is added if it is in tentative state.  This makes it harder
> for user-space applications to know the current state of the
> IPv6 addresses.  This patch adds an ipv6 sysctl that will
> allow tentative address notifications to be sent.  The sysctl
> is off by default.
> 
> Signed-off-by: Ben Greear <greearb@candelatech.com>

It's inconsistent to send two NEWADDR events for the same add.

I would advise that we unconditionally do the NEWADDR once,
when the tentative state address is added, and completely
elide the one we current send when it leaves tentative state.

Having a sysctl, and having it off by default, just means you haven't
actually fixes the problem.  Since it's only fixed if someone makes a
non-standard configuration change.

Otherwise what you're saying is that this is a very obscure thing for
very obscure applications, and it very nearly doesn't even matter
as a result.

