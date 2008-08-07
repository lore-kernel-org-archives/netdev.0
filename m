From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: [PATCH] net: trap attempts to modify noop qdisc
Date: Wed, 6 Aug 2008 23:15:16 -0700
Message-ID: <20080806231516.659f82c5@extreme>
References: <20080806202029.63f25c81@extreme>
	<20080806.202210.92821768.davem@davemloft.net>
	<20080806230850.41435290@extreme>
	<20080806.231159.55957179.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:57696 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750942AbYHGGPS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Aug 2008 02:15:18 -0400
In-Reply-To: <20080806.231159.55957179.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 06 Aug 2008 23:11:59 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <stephen.hemminger@vyatta.com>
> Date: Wed, 6 Aug 2008 23:08:50 -0700
> 
> > Since noop qdisc is a singleton, it shouldn't end up with any other
> > qdisc's on it's list, and it shouldn't be deleted.
> > 
> > Dave, this should help you find the bug.
> 
> Thanks.

I think the root of your problem (bad pun) is that the new code
is assuming that changes to the root are done with parent handle of 0,
but the API is for the parent handle to be TC_H_ROOT (0xFFFFFFFFU).

