From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH] net ipv4: use preferred log methods
Date: Thu, 1 Oct 2015 09:55:30 +0200
Message-ID: <20151001075530.GL3982@pengutronix.de>
References: <20150928.222409.1641594777817922710.davem@davemloft.net>
 <1443625231-1871-1-git-send-email-bst@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	trivial@kernel.org, kernel@pengutronix.de,
	Joe Perches <joe@perches.com>
To: Bastian Stender <bst@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:37370 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755246AbbJAHzq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2015 03:55:46 -0400
Content-Disposition: inline
In-Reply-To: <1443625231-1871-1-git-send-email-bst@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Basti,

Cc +=3D Joe Perches

On Wed, Sep 30, 2015 at 05:00:31PM +0200, Bastian Stender wrote:
> Replace printk calls with preferred unconditional log method calls to=
 keep
> kernel messages clean.
>=20
> Signed-off-by: Bastian Stender <bst@pengutronix.de>
> ---
>  net/ipv4/ipconfig.c                            |  77 +++++-------
>  net/ipv4/netfilter/arp_tables.c                | 165 +++++++++++----=
----------
>  net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |   2 +-
>  net/ipv4/netfilter/nf_nat_snmp_basic.c         |  31 +++--
>  4 files changed, 122 insertions(+), 153 deletions(-)
>=20
> diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
> index ed4ef09..50ec7c6 100644
> --- a/net/ipv4/ipconfig.c
> +++ b/net/ipv4/ipconfig.c
> [...]
> @@ -857,12 +848,12 @@ static void __init ic_bootp_send_if(struct ic_d=
evice *d, unsigned long jiffies_d
>  	if (dev_hard_header(skb, dev, ntohs(skb->protocol),
>  			    dev->broadcast, dev->dev_addr, skb->len) < 0) {
>  		kfree_skb(skb);
> -		printk("E");
> +		pr_alert("E\n");
>  		return;
>  	}
> =20
>  	if (dev_queue_xmit(skb) < 0)
> -		printk("E");
> +		pr_alert("E\n");

I'm not sure about this change. If after

	printk("E");
	printk("E");

both E are on the same line I'd say switching to pr_alert and adding \n
is bad. I don't know off-hand if that's the case, maybe Joe does?

> [...]
> diff --git a/net/ipv4/netfilter/nf_nat_snmp_basic.c b/net/ipv4/netfil=
ter/nf_nat_snmp_basic.c
> index 7c67667..78f63f5 100644
> --- a/net/ipv4/netfilter/nf_nat_snmp_basic.c
> +++ b/net/ipv4/netfilter/nf_nat_snmp_basic.c
> @@ -915,8 +915,7 @@ static inline void mangle_address(unsigned char *=
begin,
>  		}
> =20
>  		if (debug)
> -			printk(KERN_DEBUG "bsalg: mapped %pI4 to %pI4\n",
> -			       &old, addr);
> +			pr_debug("bsalg: mapped %pI4 to %pI4\n", &old, addr);

This is also a change in behaviour. The removed line results in the
message making it into the kernel log buffer unconditionally (though
probably not on the console). The newly added line is a noop however
unless DEBUG is defined. This doesn't mean the change is bad, but at
least it's not in the scope for a trivial cleanup patch that just
converts existing code to the modern way with no intend to change
behaviour.

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
