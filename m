From: David Miller <davem@davemloft.net>
Subject: Re: Printing the driver name as part of the netdev watchdog message
Date: Tue, 08 Jul 2008 14:57:38 -0700 (PDT)
Message-ID: <20080708.145738.12692130.davem@davemloft.net>
References: <4873BC67.8010205@opengridcomputing.com>
	<20080708.143158.182627862.davem@davemloft.net>
	<20080708144725.5b663d19@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: swise@opengridcomputing.com, rdreier@cisco.com,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: arjan@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41202
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751120AbYGHV5i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 17:57:38 -0400
In-Reply-To: <20080708144725.5b663d19@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arjan van de Ven <arjan@infradead.org>
Date: Tue, 8 Jul 2008 14:47:25 -0700

> On Tue, 08 Jul 2008 14:31:58 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > From: Steve Wise <swise@opengridcomputing.com>
> > Date: Tue, 08 Jul 2008 14:13:43 -0500
> > 
> > > So should I put the rtnl acquisitions back in iw_cxgb3?  Or fix
> > > cxgb3 to not assume rtnl is held?
> > 
> > It appears that the kernel always invokes the ethtool ops with
> > RTNL held, and therefore that's the environment that needs
> > to be ensured.
> 
> so for the patch that started all this... do I need to go back to the
> original where I didn't use ethool?
> (since this is called from irq context....)

What we need instead is to cache the info block into the netdev struct
when the driver is ->open()'d, and then you can fetch it out of
there however you like.

Or, at least, that is one possible approach.
