From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH v3 net-next 2/8] geneve: Use skb mark and protocol to
 lookup route.
Date: Wed, 26 Aug 2015 16:46:17 -0400
Message-ID: <20150826204616.GC9495@tuxdriver.com>
References: <1440438195-5695-1-git-send-email-pshelar@nicira.com>
 <1440438195-5695-3-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:58317 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751483AbbHZVAO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 17:00:14 -0400
Content-Disposition: inline
In-Reply-To: <1440438195-5695-3-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 24, 2015 at 10:43:09AM -0700, Pravin B Shelar wrote:
> On packet transmit path geneve need to lookup route. Following
> patch improves route lookup using more parameters.
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> Reviewed-by: Jesse Gross <jesse@nicira.com>
> Acked-by: Thomas Graf <tgraf@suug.ch>
> ---
>  drivers/net/geneve.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
> index 95e9da0..3c5b2b1 100644
> --- a/drivers/net/geneve.c
> +++ b/drivers/net/geneve.c
> @@ -202,6 +202,9 @@ static netdev_tx_t geneve_xmit(struct sk_buff *skb, struct net_device *dev)
>  	memset(&fl4, 0, sizeof(fl4));
>  	fl4.flowi4_tos = RT_TOS(tos);
>  	fl4.daddr = geneve->remote.sin_addr.s_addr;
> +	fl4.flowi4_mark = skb->mark;
> +	fl4.flowi4_proto = IPPROTO_UDP;
> +
>  	rt = ip_route_output_key(geneve->net, &fl4);
>  	if (IS_ERR(rt)) {
>  		netdev_dbg(dev, "no route to %pI4\n", &fl4.daddr);

Acked-by: John W. Linville <linville@tuxdriver.com>

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
