From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V3] netxen: fix ethtool rx_dropped information in
 ethtool get_ethtool_stats()
Date: Sun, 20 Jul 2014 20:58:30 -0700 (PDT)
Message-ID: <20140720.205830.595868255699983537.davem@davemloft.net>
References: <1405655009-18975-1-git-send-email-ethan.zhao@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: manish.chopra@qlogic.com, sony.chacko@qlogic.com,
	rajesh.borundia@qlogic.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ethan.kernel@gmail.com
To: ethan.zhao@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405655009-18975-1-git-send-email-ethan.zhao@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ethan Zhao <ethan.zhao@oracle.com>
Date: Fri, 18 Jul 2014 11:43:29 +0800

> netxen driver has implemented netxen_nic_get_ethtool_stats() interface,
> but it doesn't collect stats.rxdropped in driver, so we will get
> different rx_dropped statistic information while using ifconfig and ethtool.
> this patch fills stats.rxdropped field with data from net core
> with dev_get_stats() just as ixgbe driver did for some of its stats.
> 
> Tested with last netxen 4.0.82
> Compiled with stable 3.15.6
> 
> Signed-off-by: Ethan Zhao <ethan.zhao@oracle.com>
> Tested-by: Sriharsha Yadagudde <sriharsha.devdas@oracle.com>

ethtool stats are _NOT_ the place to duplicate normal netdev stats,
PERIOD.

The only exception is when you maintainer per-queue instaces of these
stats, and want to export that information to the user.

I'm not applying this, sorry.
