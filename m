From: David Miller <davem@davemloft.net>
Subject: Re: BUG in skb_pull with e1000e, PPTP, and L2TP
Date: Wed, 19 Oct 2011 03:31:54 -0400 (EDT)
Message-ID: <20111019.033154.371626230759904957.davem@davemloft.net>
References: <1318904666.2571.33.camel@edumazet-laptop>
	<1318909879.2571.43.camel@edumazet-laptop>
	<1318910393.2571.47.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	bruce.w.allan@intel.com, jesse.brandeburg@intel.com,
	john.ronciak@intel.com, despite@gmail.com
To: eric.dumazet@gmail.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1318910393.2571.47.camel@edumazet-laptop>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 18 Oct 2011 05:59:53 +0200

> [PATCH v2] pptp: pptp_rcv_core() misses pskb_may_pull() call
> 
> e1000e uses paged frags, so any layer incorrectly pulling bytes from skb
> can trigger a BUG in skb_pull()
> 
> [951.142737]  [<ffffffff813d2f36>] skb_pull+0x15/0x17
> [951.142737]  [<ffffffffa0286824>] pptp_rcv_core+0x126/0x19a [pptp]
> [951.152725]  [<ffffffff813d17c4>] sk_receive_skb+0x69/0x105
> [951.163558]  [<ffffffffa0286993>] pptp_rcv+0xc8/0xdc [pptp]
> [951.165092]  [<ffffffffa02800a3>] gre_rcv+0x62/0x75 [gre]
> [951.165092]  [<ffffffff81410784>] ip_local_deliver_finish+0x150/0x1c1
> [951.177599]  [<ffffffff81410634>] ? ip_local_deliver_finish+0x0/0x1c1
> [951.177599]  [<ffffffff81410846>] NF_HOOK.clone.7+0x51/0x58
> [951.177599]  [<ffffffff81410996>] ip_local_deliver+0x51/0x55
> [951.177599]  [<ffffffff814105b9>] ip_rcv_finish+0x31a/0x33e
> [951.177599]  [<ffffffff8141029f>] ? ip_rcv_finish+0x0/0x33e
> [951.204898]  [<ffffffff81410846>] NF_HOOK.clone.7+0x51/0x58
> [951.214651]  [<ffffffff81410bb5>] ip_rcv+0x21b/0x246
> 
> pptp_rcv_core() is a nice example of a function assuming everything it
> needs is available in skb head.
> 
> Reported-by: Bradley Peterson <despite@gmail.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

I assume by the driver paths in the patch that you think this
is 'net-next' material and not suitable for plain 'net', right?

------------------------------------------------------------------------------
All the data continuously generated in your IT infrastructure contains a
definitive record of customers, application performance, security
threats, fraudulent activity and more. Splunk takes this data and makes
sense of it. Business sense. IT sense. Common sense.
http://p.sf.net/sfu/splunk-d2d-oct
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
