From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Printing the driver name as part of the netdev watchdog message
Date: Sun, 6 Jul 2008 18:08:42 -0700
Message-ID: <20080706180842.36cc0b1c@extreme>
References: <20080706130801.6bc36cf7@infradead.org>
	<20080706.155318.46569612.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: arjan@infradead.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:54160 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757461AbYGGBIs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Jul 2008 21:08:48 -0400
In-Reply-To: <20080706.155318.46569612.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 06 Jul 2008 15:53:18 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Arjan van de Ven <arjan@infradead.org>
> Date: Sun, 6 Jul 2008 13:08:01 -0700
> 
> > Does this patch look like the right approach for achieving the goal?
> 
> It's almost there.
> 
> You can issue an ethtool_ops->get_drvinfo() call, on devices which
> support ethtool, and fetch the driver info from there.
> 
> Your current method of obtaining this info can be used as the
> fallback when the ethtool op fails.

Maybe not. For consistency each call through ethtool_ops should
be holding rtnl mutex. And since dev_watchdog is a timer routine,
it is not safe to acquire a mutex there.
