From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH 2/4] Ethtool: convert get_sg/set_sg calls
 to hw_features flag
Date: Mon, 1 Nov 2010 19:24:38 -0700
Message-ID: <20101102022438.GA4243@mcarlson.broadcom.com>
References: <cover.1288496404.git.mirq-linux@rere.qmqm.pl>
	<9d89236b6e4ff8c66937fbd7d8ce76602e680c5b.1288496404.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "linux-net-drivers@solarflare.com" <linux-net-drivers@solarflare.com>,
	Debashis Dutt <ddutt@brocade.com>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@suse.de>, Rasesh Mody <rmody@brocade.com>,
	"linux-driver@qlogic.com" <linux-driver@qlogic.com>,
	Steve Glendinning <steve.glendinning@smsc.com>,
	Kristoffer Glembo <kristoffer@gaisler.com>
To: "Micha?? Miros??aw" <mirq-linux@rere.qmqm.pl>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <9d89236b6e4ff8c66937fbd7d8ce76602e680c5b.1288496404.git.mirq-linux@rere.qmqm.pl>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Fri, Oct 29, 2010 at 09:28:26PM -0700, Micha?? Miros??aw wrote:
> diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
> index 30ccbb6..b07e2d1 100644
> --- a/drivers/net/tg3.c
> +++ b/drivers/net/tg3.c
> @@ -11306,7 +11306,6 @@ static const struct ethtool_ops tg3_ethtool_ops = {
>         .get_rx_csum            = tg3_get_rx_csum,
>         .set_rx_csum            = tg3_set_rx_csum,
>         .set_tx_csum            = tg3_set_tx_csum,
> -       .set_sg                 = ethtool_op_set_sg,
>         .set_tso                = tg3_set_tso,
>         .self_test              = tg3_self_test,
>         .get_strings            = tg3_get_strings,
> @@ -14681,6 +14680,7 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
>         tp->rx_pending = TG3_DEF_RX_RING_PENDING;
>         tp->rx_jumbo_pending = TG3_DEF_RX_JUMBO_RING_PENDING;
> 
> +       dev->hw_features |= NETIF_F_SG;

Scatter-gather should not be enabled if TG3_FLAG_BROKEN_CHECKSUMS is set.  I
would do the following instead:

	if (!(tp->tg3_flags & TG3_FLAG_BROKEN_CHECKSUMS))
		dev->hw_features |= NETIF_F_SG;

TG3_FLAG_BROKEN_CHECKSUMS is set in tg3_get_invariants(), so this code
would need to be placed later than that function call.

>         dev->ethtool_ops = &tg3_ethtool_ops;
>         dev->watchdog_timeo = TG3_TX_TIMEOUT;
>         dev->irq = pdev->irq;


------------------------------------------------------------------------------
Nokia and AT&T present the 2010 Calling All Innovators-North America contest
Create new apps & games for the Nokia N8 for consumers in  U.S. and Canada
$10 million total in prizes - $4M cash, 500 devices, nearly $6M in marketing
Develop with Nokia Qt SDK, Web Runtime, or Java and Publish to Ovi Store 
http://p.sf.net/sfu/nokia-dev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
