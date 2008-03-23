From: David Miller <davem@davemloft.net>
Subject: Re: [git patches] net driver updates for .26
Date: Sat, 22 Mar 2008 18:35:22 -0700 (PDT)
Message-ID: <20080322.183522.124237568.davem@davemloft.net>
References: <20080318075902.GA18010@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48015
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755529AbYCWBfG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Mar 2008 21:35:06 -0400
In-Reply-To: <20080318075902.GA18010@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Garzik <jeff@garzik.org>
Date: Tue, 18 Mar 2008 03:59:02 -0400

> 
> Just sent this upstream to davem for 2.6.26...  snipped the patch I
> usually post along with a git push, due to mailing list restrictions.
> 
> Please pull from 'upstream-net26' branch of
> master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-net26

This fails an allmodconfig build:

drivers/net/8390.c: In function '__inittest':
drivers/net/8390.c:60: error: 'ns8390_init_module' undeclared (first use in this function)
drivers/net/8390.c:60: error: (Each undeclared identifier is reported only once
drivers/net/8390.c:60: error: for each function it appears in.)

The fix was easy so I took care of it, this time...

There was also a merge conflict in drivers/s390/net/qeth_main.c
(against a net-2.6.26 change, which is why you really should work
against that for 2.6.26 bound changes not against Linus's head as you
did here), which is easy to resolve by putting the conflicting change
to qeth_main.c into the inetdev notifier in qeth_l3_main.c, which
I took care of as well.

This time....

There are also some new build warnings such as:

drivers/net/atlx/atl1.c:506: warning: 'atl1_phy_enter_power_saving' defined but not used

Which I fixed up as well, but that atl1_phy_enter_power_saving()
function is just a jumble of commented out code, yuck!  Please
review some of this stuff :-/

I'm not doing all of these fixups next time just to make your
tree pullable, ok?

Thanks.
