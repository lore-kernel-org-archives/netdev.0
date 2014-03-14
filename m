From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 02/10] e1000e: add timeout for TX
 HW time stamping work
Date: Fri, 14 Mar 2014 10:48:37 -0700
Message-ID: <1394819317.3253.3.camel@joe-AO722>
References: <1394818481-7652-1-git-send-email-kubakici@wp.pl>
	<1394818481-7652-3-git-send-email-kubakici@wp.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1394818481-7652-3-git-send-email-kubakici@wp.pl>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Fri, 2014-03-14 at 18:34 +0100, Jakub Kicinski wrote:
> Hardware may fail to report time stamp e.g.:
>  - when hardware time stamping is not enabled
>  - when time stamp is requested shortly after ifup

trivia:

> diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
[]
> @@ -1155,6 +1155,12 @@ static void e1000e_tx_hwtstamp_work(struct work_struct *work)
>  		skb_tstamp_tx(adapter->tx_hwtstamp_skb, &shhwtstamps);
>  		dev_kfree_skb_any(adapter->tx_hwtstamp_skb);
>  		adapter->tx_hwtstamp_skb = NULL;
> +	} else if (time_after(jiffies, adapter->tx_hwtstamp_start
> +			      + adapter->tx_timeout_factor * HZ)) {
> +		dev_kfree_skb_any(adapter->tx_hwtstamp_skb);
> +		adapter->tx_hwtstamp_skb = NULL;
> +		adapter->tx_hwtstamp_timeouts++;
> +		e_warn("clearing Tx timestamp hang");

Missing \n termination




------------------------------------------------------------------------------
Learn Graph Databases - Download FREE O'Reilly Book
"Graph Databases" is the definitive new guide to graph databases and their
applications. Written by three acclaimed leaders in the field,
this first edition is now available. Download your free book today!
http://p.sf.net/sfu/13534_NeoTech
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
