From: Shawn Bohrer <shawn.bohrer@gmail.com>
Subject: Re: [PATCH net-next 1/2] mlx4_en: Add PTP hardware clock
Date: Mon, 23 Dec 2013 10:29:58 -0600
Message-ID: <20131223162957.GA6810@lintop.rgmadvisors.com>
References: <1387312359-9476-1-git-send-email-shawn.bohrer@gmail.com>
 <1387312359-9476-2-git-send-email-shawn.bohrer@gmail.com>
 <52B6E568.4030400@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Richard Cochran <richardcochran@gmail.com>,
	netdev@vger.kernel.org, tomk@rgmadvisors.com,
	Shawn Bohrer <sbohrer@rgmadvisors.com>
To: Hadar Hen Zion <hadarh@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:59405 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757490Ab3LWQaK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Dec 2013 11:30:10 -0500
Received: by mail-ob0-f172.google.com with SMTP id gq1so5688062obb.31
        for <netdev@vger.kernel.org>; Mon, 23 Dec 2013 08:30:10 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <52B6E568.4030400@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 22, 2013 at 03:13:12PM +0200, Hadar Hen Zion wrote:
> On 12/17/2013 10:32 PM, Shawn Bohrer wrote:
> >From: Shawn Bohrer <sbohrer@rgmadvisors.com>
> >
> >This adds a PHC to the mlx4_en driver.  The code is largely based off of
> >the e1000e driver (drivers/net/ethernet/intel/e1000e/ptp.c) which seemed
> >very similar.
> >
> >This driver has been tested with both Documentation/ptp/testptp and the
> >linuxptp project (http://linuxptp.sourceforge.net/) and appears to work
> >on a Mellanox ConnectX-3 card.
> >
> >Signed-off-by: Shawn Bohrer <sbohrer@rgmadvisors.com>
> >---
> >  drivers/net/ethernet/mellanox/mlx4/en_clock.c   |  192 ++++++++++++++++++++++-
> >  drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |    3 +
> >  drivers/net/ethernet/mellanox/mlx4/en_main.c    |    3 +
> >  drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |    6 +
> >  4 files changed, 196 insertions(+), 8 deletions(-)
> >
> >diff --git a/drivers/net/ethernet/mellanox/mlx4/en_clock.c b/drivers/net/ethernet/mellanox/mlx4/en_clock.c
> >index fd64410..9b0d515 100644
> >--- a/drivers/net/ethernet/mellanox/mlx4/en_clock.c
> >+++ b/drivers/net/ethernet/mellanox/mlx4/en_clock.c
> >@@ -103,17 +103,187 @@ void mlx4_en_fill_hwtstamps(struct mlx4_en_dev *mdev,
> >  			    struct skb_shared_hwtstamps *hwts,
> >  			    u64 timestamp)
> >  {
> >+	unsigned long flags;
> >  	u64 nsec;
> >
> >+	spin_lock_irqsave(&mdev->clock_lock, flags);
> 
> 1. Missing initialization for clock_lock
> 2. Adding spin lock in the data path reduce performance by 15% when
> HW timestamping is enabled. I did some testing and replacing
> spin_lock_irqsave with read/write_lock_irqsave prevents the
> performance decrease.

Thanks Hadar,

I'm testing this change now, and will resend when I'm done.  However,
I noticed the following in Documentation/spinlocks.txt

   NOTE! We are working hard to remove reader-writer spinlocks in most
   cases, so please don't add a new one without consensus.  (Instead, see
   Documentation/RCU/rcu.txt for complete information.)

So is there consensus for a rwlock here?

Thanks,
Shawn
