From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net V3 2/2] net: core: explicitly select a
 txq before doing l2 forwarding
Date: Fri, 10 Jan 2014 13:24:28 -0500 (EST)
Message-ID: <20140110.132428.2182820842932734377.davem@davemloft.net>
References: <1389341906-2367-1-git-send-email-jasowang@redhat.com>
	<1389341906-2367-2-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, mst@redhat.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	john.r.fastabend@intel.com
To: jasowang@redhat.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1389341906-2367-2-git-send-email-jasowang@redhat.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Jason Wang <jasowang@redhat.com>
Date: Fri, 10 Jan 2014 16:18:26 +0800

> Currently, the tx queue were selected implicitly in ndo_dfwd_start_xmit(). The
> will cause several issues:
> 
> - NETIF_F_LLTX were removed for macvlan, so txq lock were done for macvlan
>   instead of lower device which misses the necessary txq synchronization for
>   lower device such as txq stopping or frozen required by dev watchdog or
>   control path.
> - dev_hard_start_xmit() was called with NULL txq which bypasses the net device
>   watchdog.
> - dev_hard_start_xmit() does not check txq everywhere which will lead a crash
>   when tso is disabled for lower device.
> 
> Fix this by explicitly introducing a new param for .ndo_select_queue() for just
> selecting queues in the case of l2 forwarding offload. netdev_pick_tx() was also
> extended to accept this parameter and dev_queue_xmit_accel() was used to do l2
> forwarding transmission.
> 
> With this fixes, NETIF_F_LLTX could be preserved for macvlan and there's no need
> to check txq against NULL in dev_hard_start_xmit(). Also there's no need to keep
> a dedicated ndo_dfwd_start_xmit() and we can just reuse the code of
> dev_queue_xmit() to do the transmission.
> 
> In the future, it was also required for macvtap l2 forwarding support since it
> provides a necessary synchronization method.
> 
> Cc: John Fastabend <john.r.fastabend@intel.com>
> Cc: Neil Horman <nhorman@tuxdriver.com>
> Cc: e1000-devel@lists.sourceforge.net
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Applied.

------------------------------------------------------------------------------
CenturyLink Cloud: The Leader in Enterprise Cloud Services.
Learn Why More Businesses Are Choosing CenturyLink Cloud For
Critical Workloads, Development Environments & Everything In Between.
Get a Quote or Start a Free Trial Today. 
http://pubads.g.doubleclick.net/gampad/clk?id=119420431&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
