From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] genetlink: fix netns vs. netlink table locking
Date: Mon, 14 Sep 2009 17:07:04 -0700 (PDT)
Message-ID: <20090914.170704.38918868.davem@davemloft.net>
References: <1252425578.3806.22.camel@johannes.local>
	<1252760595.23427.20.camel@johannes.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58873
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757578AbZIOAGs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2009 20:06:48 -0400
In-Reply-To: <1252760595.23427.20.camel@johannes.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Sat, 12 Sep 2009 07:03:15 -0600

> Since my commits introducing netns awareness into
> genetlink we can get this problem:
> 
> BUG: scheduling while atomic: modprobe/1178/0x00000002
> 2 locks held by modprobe/1178:
>  #0:  (genl_mutex){+.+.+.}, at: [<ffffffff8135ee1a>] genl_register_mc_grou
>  #1:  (rcu_read_lock){.+.+..}, at: [<ffffffff8135eeb5>] genl_register_mc_g
> Pid: 1178, comm: modprobe Not tainted 2.6.31-rc8-wl-34789-g95cb731-dirty #
> Call Trace:
>  [<ffffffff8103e285>] __schedule_bug+0x85/0x90
>  [<ffffffff81403138>] schedule+0x108/0x588
>  [<ffffffff8135b131>] netlink_table_grab+0xa1/0xf0
>  [<ffffffff8135c3a7>] netlink_change_ngroups+0x47/0x100
>  [<ffffffff8135ef0f>] genl_register_mc_group+0x12f/0x290
> 
> because I overlooked that netlink_table_grab() will
> schedule, thinking it was just the rwlock. However,
> in the contention case, that isn't actually true.
> 
> Fix this by letting the code grab the netlink table
> lock first and then the RCU for netns protection.
> 
> Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

Applied, thanks.
