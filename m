From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH 1/2] net: Allow ethtool to set interface in loopback
 mode.
Date: Wed, 4 May 2011 13:15:27 +0200
Message-ID: <20110504111527.GB15486@rere.qmqm.pl>
References: <1304471935-402-1-git-send-email-maheshb@google.com>
 <1304471935-402-2-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Matt Carlson <mcarlson@broadcom.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Tom Herbert <therbert@google.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:40926 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752777Ab1EDLP2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 May 2011 07:15:28 -0400
Content-Disposition: inline
In-Reply-To: <1304471935-402-2-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 03, 2011 at 06:18:54PM -0700, Mahesh Bandewar wrote:
> This patch enables ethtool to set the loopback mode on a given interf=
ace.
> By configuring the interface in loopback mode in conjunction with a p=
olicy
> route / rule, a userland application can stress the egress / ingress =
path
> exposing the flows of the change in progress and potentially help dev=
eloper(s)
> understand the impact of those changes without even sending a packet =
out
> on the network.
>=20
> Following set of commands illustrates one such example -
>     a) ip -4 addr add 192.168.1.1/24 dev eth1
>     b) ip -4 rule add from all iif eth1 lookup 250
>     c) ip -4 route add local 0/0 dev lo proto kernel scope host table=
 250
>     d) arp -Ds 192.168.1.100 eth1
>     e) arp -Ds 192.168.1.200 eth1
>     f) sysctl -w net.ipv4.ip_nonlocal_bind=3D1
>     g) sysctl -w net.ipv4.conf.all.accept_local=3D1
>     # Assuming that the machine has 8 cores
>     h) taskset 000f netserver -L 192.168.1.200
>     i) taskset 00f0 netperf -t TCP_CRR -L 192.168.1.100 -H 192.168.1.=
200 -l 30
>=20
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> ---
>  include/linux/netdevice.h |    3 ++-
>  net/core/ethtool.c        |    2 +-
>  2 files changed, 3 insertions(+), 2 deletions(-)
>=20
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index d5de66a..e7244ed 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1067,6 +1067,7 @@ struct net_device {
>  #define NETIF_F_RXHASH		(1 << 28) /* Receive hashing offload */
>  #define NETIF_F_RXCSUM		(1 << 29) /* Receive checksumming offload */
>  #define NETIF_F_NOCACHE_COPY	(1 << 30) /* Use no-cache copyfromuser =
*/
> +#define NETIF_F_LOOPBACK	(1 << 31) /* Enable loopback */
[...]

Just for correctness: you could add this flag to loopback's dev->featur=
es.
It's just an aesthetics point, though.

Best Regards,
Micha=B3 Miros=B3aw
