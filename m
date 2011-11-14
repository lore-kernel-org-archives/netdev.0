From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: Fix potential deadlock on br->multicast_lock
Date: Mon, 14 Nov 2011 00:39:19 -0500 (EST)
Message-ID: <20111114.003919.1393266325552023244.davem@davemloft.net>
References: <1320940083-3719823-1-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devel@openvz.org
To: avagin@openvz.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1320940083-3719823-1-git-send-email-avagin@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Vagin <avagin@openvz.org>
Date: Thu, 10 Nov 2011 18:48:03 +0300

> multicast_lock is taken in softirq context, so we should use
> spin_lock_bh() in userspace.
> 
> call-chain in softirq context:
> run_timer_softirq()
> 	br_multicast_query_expired()
> 
> call-chain in userspace:
> sysfs_write_file()
> 	store_multicast_snooping()
> 		br_multicast_toggle()
> 
> Signed-off-by: Andrew Vagin <avagin@openvz.org>

Applied, thanks.
