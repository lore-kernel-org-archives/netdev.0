From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [patch net-next v2] ipv6: log autoconfiguration failures
Date: Wed, 11 Dec 2013 20:21:38 +0100
Message-ID: <20131211192138.GB4675@order.stressinduktion.org>
References: <1386762314-5149-1-git-send-email-dvlasenk@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, jpirko@redhat.com
To: Denys Vlasenko <dvlasenk@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:48943 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751203Ab3LKTVj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 14:21:39 -0500
Content-Disposition: inline
In-Reply-To: <1386762314-5149-1-git-send-email-dvlasenk@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 11, 2013 at 12:45:14PM +0100, Denys Vlasenko wrote:
> If ipv6 auto-configuration does not work, currently it's hard
> to track what's going on. This change adds log messages
> (at debug level) on every code path where ipv6 autoconf fails.
> 
> v2: fixed indentation in multi-line log output statements.

Have you seen lots of those problems? Some of those seem like very
serious problems and maybe could also deserve a pr_warn or pr_err.

I hope these are one-time errors, so I don't think counters would
be helpful.

> Signed-off-by: Denys Vlasenko <dvlasenk@redhat.com>
> ---
>  net/ipv6/addrconf.c | 45 ++++++++++++++++++++++++++++++++++++---------
>  1 file changed, 36 insertions(+), 9 deletions(-)
> 
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 3c3425e..c09c5f4 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -1694,8 +1694,11 @@ static void addrconf_leave_anycast(struct inet6_ifaddr *ifp)
>  
>  static int addrconf_ifid_eui48(u8 *eui, struct net_device *dev)
>  {
> -	if (dev->addr_len != ETH_ALEN)
> +	if (dev->addr_len != ETH_ALEN) {
> +		pr_debug("IPv6 addrconf: %s: address length %d != %s\n",
> +			 dev->name, dev->addr_len, "ETH_ALEN");

I like __stringify(ETH_ALEN) instead of "ETH_ALEN" a bit more but no need
to change the patch because of that. ;)

> @@ -1842,6 +1865,10 @@ static int ipv6_inherit_eui64(u8 *eui, struct inet6_dev *idev)
>  		}
>  	}
>  	read_unlock_bh(&idev->lock);
> +	if (err)
> +		pr_debug("IPv6 addrconf: "
> +			 "%s: no link-local address to inherit\n",
> +			 idev->dev->name);

Another nit:
String literals should not be wrapped to ease grepping for them in the source.

Thanks,

  Hannes
