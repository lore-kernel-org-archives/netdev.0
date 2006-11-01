From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 2.6.19-rc4 - netlink messages created with bad flags
 in soft_irq context
Date: Tue, 31 Oct 2006 22:00:47 -0800 (PST)
Message-ID: <20061031.220047.08324824.davem@davemloft.net>
References: <20061031220559.GA10119@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:179
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1946596AbWKAGAo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Nov 2006 01:00:44 -0500
To: andy@greyhouse.net
In-Reply-To: <20061031220559.GA10119@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andy Gospodarek <andy@greyhouse.net>
Date: Tue, 31 Oct 2006 17:06:00 -0500

> I've got a kernel built where 
> 
> CONFIG_DEBUG_SPINLOCK_SLEEP=y
> 
> is in the config and I've noticed some interesting behavior when
> bringing up bonds in balance-alb mode.  When I start to enslave devices
> to a bond I get the following in the ring buffer:
> 
> BUG: sleeping function called from invalid context at mm/slab.c:3007
> in_atomic():1, irqs_disabled():0

As Herbert mentioned, the bonding layer calls into the networking
in atomic contexts when that is illegal.
