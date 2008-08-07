From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: trap attempts to modify noop qdisc
Date: Wed, 06 Aug 2008 23:18:51 -0700 (PDT)
Message-ID: <20080806.231851.193702040.davem@davemloft.net>
References: <20080806230850.41435290@extreme>
	<20080806.231159.55957179.davem@davemloft.net>
	<20080806231516.659f82c5@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: stephen.hemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54777
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751281AbYHGGSu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2008 02:18:50 -0400
In-Reply-To: <20080806231516.659f82c5@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Date: Wed, 6 Aug 2008 23:15:16 -0700

> I think the root of your problem (bad pun) is that the new code
> is assuming that changes to the root are done with parent handle of 0,
> but the API is for the parent handle to be TC_H_ROOT (0xFFFFFFFFU).

Yes, that's likely it.  I'm playing with some patches now.

BTW, destroying the noop_qdisc is legal, that's why we check
TCF_F_BUILTIN there.

