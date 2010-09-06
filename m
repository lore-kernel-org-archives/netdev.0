From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mlx4_core: module param to limit msix vec allocation
Date: Mon, 06 Sep 2010 12:51:23 -0700 (PDT)
Message-ID: <20100906.125123.104055684.davem@davemloft.net>
References: <20100903221303.GS2464@sgi.com>
	<20100903.193046.184840227.davem@davemloft.net>
	<20100906174245.GA12956@sgi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: akepner@sgi.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34882
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750775Ab0IFTvH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Sep 2010 15:51:07 -0400
In-Reply-To: <20100906174245.GA12956@sgi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arthur Kepner <akepner@sgi.com>
Date: Mon, 6 Sep 2010 10:42:45 -0700

> On Fri, Sep 03, 2010 at 07:30:46PM -0700, David Miller wrote:
>> This also means there would have to be notifications sent to
>> drivers when the distribution and allocation policy of MSI-X
>> interrupts is changed.  This is so that, for example, network
>> drivers can reconfigure their network queues for the new set
>> of MSI-X vectors available to them after the policy change.
> 
> Hadn't considered this. Will have to add it.

BTW, reading this again made me consider another case that
needs to invoke a notifier.

Let's say that a policy specifies an even distribution of
MSI-X allocation amongst all present devices behind a PCI
domain.  Well, if a PCI-E device hot-plugs you'll have to
do notifications for that too because a card might now be
able to get more of the MSI-X vectors it wants.
