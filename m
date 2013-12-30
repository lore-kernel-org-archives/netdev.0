From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [WARNING net-next] from ixgbe_configure
Date: Sun, 29 Dec 2013 21:29:37 -0800
Message-ID: <52C104C1.6070508@gmail.com>
References: <20131229131545.5a8773c9@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20131229131545.5a8773c9@nehalam.linuxnetplumber.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 12/29/2013 01:15 PM, Stephen Hemminger wrote:
> Warning with current net-next from ixgbe_configure calling
> netdev_all_upper_get_next_dev_rcu without RCU read lock held.
>
>
> [    4.717512] r8169 0000:03:00.0 eth0: link down
> [    4.717581] r8169 0000:03:00.0 eth0: link down
> [    4.717590] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
> [    6.722390] r8169 0000:03:00.0 eth0: link up
> [    6.722428] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
> [    9.833968] ------------[ cut here ]------------
> [    9.833976] WARNING: CPU: 5 PID: 2173 at net/core/dev.c:4448 netdev_all_upper_get_next_dev_rcu+0x6b/0xa0()


This should be fixed when net is synced with net-next by the
following commit,

author		John Fastabend <john.r.fastabend@intel.com>
committer	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
commit		85328240c625f322af9f69c7b60e619717101d77

net: allow netdev_all_upper_get_next_dev_rcu with rtnl lock held

It is useful to be able to walk all upper devices when bringing a device 
online where the RTNL lock is held. In this case it is safe to walk the 
all_adj_list because the RTNL lock is used to protect the write side as 
well.
[...]

Thanks,
John

-- 
John Fastabend         Intel Corporation

------------------------------------------------------------------------------
Rapidly troubleshoot problems before they affect your business. Most IT 
organizations don't have a clear picture of how application performance 
affects their revenue. With AppDynamics, you get 100% visibility into your 
Java,.NET, & PHP application. Start your 15-day FREE TRIAL of AppDynamics Pro!
http://pubads.g.doubleclick.net/gampad/clk?id=84349831&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
