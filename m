From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1 2.6.28] cxgb3 - add one check in interrupt routine
Date: Sat, 11 Oct 2008 12:29:19 -0700 (PDT)
Message-ID: <20081011.122919.61290776.davem@davemloft.net>
References: <1223671728.2614.13.camel@wendyx.austin.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, wenxiong@us.ibm.com
To: wendyx@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49879
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755004AbYJKT3n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Oct 2008 15:29:43 -0400
In-Reply-To: <1223671728.2614.13.camel@wendyx.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: wendy xiong <wendyx@us.ibm.com>
Date: Fri, 10 Oct 2008 15:48:48 -0500

> Hi Jeff,
> 
> We are submitting a patch to do the test before accessing A_PL_CLI register in interrupt routine for inclusion in 2.6.28, 
> as follows:

First, missing Signed-off-by:

Second, this is recidulious.

Every single interrupt we're going to check this error state value.  That's excessive,
and this is a performance critical fast path.

I do not want to see this begin to be a trend in the drivers, so I'm rejecting this
right now before it starts to spread.

If you want to handle this case, do something like quiesce the interrupt handler and
disable it when an error is detected.  That kind of scheme, at worst, will have the
same kinds of races that this silly test does.

