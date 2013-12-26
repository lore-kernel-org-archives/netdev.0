From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 1/2] mlx4_en: Add PTP hardware clock
Date: Thu, 26 Dec 2013 15:49:08 +0100
Message-ID: <20131226144908.GA4360@netboy>
References: <1387312359-9476-1-git-send-email-shawn.bohrer@gmail.com>
 <1387312359-9476-2-git-send-email-shawn.bohrer@gmail.com>
 <52B6E568.4030400@mellanox.com>
 <20131223184845.GA4922@netboy>
 <52B992EE.5030401@mellanox.com>
 <20131225115322.GB5378@netboy>
 <52BBE84C.1030702@mellanox.com>
 <52BBE9D6.3040006@mellanox.com>
 <20131226091740.GA8787@netboy>
 <20131226144111.GB12695@mtl-eit-vdi-41.mtl.labs.mlnx>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Shawn Bohrer <shawn.bohrer@gmail.com>,
	Tom Ketterhagen <tomk@rgmadvisors.com>,
	netdev <netdev@vger.kernel.org>, Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Hen Zion <hadarh@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>
To: Hadar Hen-Zion <hadarh@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f52.google.com ([74.125.83.52]:35829 "EHLO
	mail-ee0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753145Ab3LZOtS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Dec 2013 09:49:18 -0500
Received: by mail-ee0-f52.google.com with SMTP id d17so3718920eek.11
        for <netdev@vger.kernel.org>; Thu, 26 Dec 2013 06:49:17 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20131226144111.GB12695@mtl-eit-vdi-41.mtl.labs.mlnx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 26, 2013 at 04:41:11PM +0200, Hadar Hen-Zion wrote:

> +u64 mlx4_en_timecounter_read(struct mlx4_en_dev *mdev)
> +{
> +	struct timecounter *new_tc, *old_tc;
> +	unsigned long flags;
> +	s64 now;
> +
> +	new_tc = kmalloc(sizeof(*new_tc), GFP_KERNEL);

So you want to call malloc/free on every clock read?
That is crazy.

> +	spin_lock_irqsave(&mdev->clock_lock, flags);
> +	old_tc = mdev->clock;
> +	*new_tc = *old_tc;
> +	now = timecounter_read(new_tc);
> +	rcu_assign_pointer(mdev->clock, new_tc);
> +	spin_unlock_irqrestore(&mdev->clock_lock, flags);
> +	synchronize_rcu();
> +	kfree(old_tc);
> +
> +	return now;
> +}

Thanks,
Richard
