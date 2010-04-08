From: John Linn <John.Linn@xilinx.com>
Subject: RE: linux-next: build failure after merge of the final tree
Date: Thu, 8 Apr 2010 08:15:12 -0600
Message-ID: <6125d80a-81d5-4699-ac6e-9408bd0c1145@SG2EHSMHS010.ehs.local>
References: <20100408153505.eb205158.sfr@canb.auug.org.au> <20100407.232500.184442638.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <linux-next@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jtyner@cs.ucr.edu>,
	<grant.likely@secretlab.ca>
To: "David Miller" <davem@davemloft.net>, <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sg2ehsobe002.messaging.microsoft.com ([207.46.51.76]:23298 "EHLO
	SG2EHSOBE002.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756367Ab0DHOPn convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Apr 2010 10:15:43 -0400
Content-Class: urn:content-classes:message
In-Reply-To: <20100407.232500.184442638.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Thursday, April 08, 2010 12:25 AM
> To: sfr@canb.auug.org.au
> Cc: netdev@vger.kernel.org; linux-next@vger.kernel.org;
linux-kernel@vger.kernel.org; John Linn;
> jtyner@cs.ucr.edu
> Subject: Re: linux-next: build failure after merge of the final tree
> 
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Thu, 8 Apr 2010 15:35:05 +1000
> 
> > After merging the final tree, today's linux-next build (powerpc
> > allyesconfig) failed like this:
> >
> > drivers/net/ll_temac_main.c: In function 'll_temac_recv':
> > drivers/net/ll_temac_main.c:695: error: implicit declaration of
function 'virt_to_bus'
> >
> > Caused by commit 459569145516f7967b916c57445feb02c600668c ("Add
> > non-Virtex5 support for LL TEMAC driver") from the net tree.
> >
> > I have reverted that commit for today.
> 
> And I'm reverting it too, it's illegal to use virt_to_bus()
> in new code in this day and age.

I'm not pushing back here, just trying to make sure I understand and do
it better next time :)

I don't see that my patch has touched that part of the driver as that
call was already in the driver before my patch (but maybe I'm just
missing it).

My patch did change the dependency in the Kconfig so that it only
depends on powerpc rather than powerpc DCR and maybe that exposed
something that wasn't previously exposed.

Maybe this is an issue in linux-next and I need to test against that,
I'm pulling it now.  I was testing against Linus's tree.

> 
> John, you'll need to use the DMA mapping APIs in this change when you
> resubmit it.

Thanks, will spin it again and get that fixed.  My apologies for the
hassles, appreciate the help.

-- John

> 
> Thanks.


This email and any attachments are intended for the sole use of the named recipient(s) and contain(s) confidential information that may be proprietary, privileged or copyrighted under applicable law. If you are not the intended recipient, do not read, copy, or forward this email message or any attachments. Delete this email message and any attachments immediately.


