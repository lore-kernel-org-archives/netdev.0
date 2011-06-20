From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFT PATCH 3/9] net: ethtool: break association of ETH_FLAG_*
 with NETIF_F_*
Date: Mon, 20 Jun 2011 21:11:21 +0100
Message-ID: <1308600681.2701.159.camel@bwh-desktop>
References: <cover.1308596962.git.mirq-linux@rere.qmqm.pl>
	 <51d2fd4cf6855c2285ca9bcd8d267abedcbc599c.1308596963.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:27804 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752454Ab1FTULY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 16:11:24 -0400
In-Reply-To: <51d2fd4cf6855c2285ca9bcd8d267abedcbc599c.1308596963.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-06-20 at 21:14 +0200, Micha=C5=82 Miros=C5=82aw wrote:
> This is the only place where NETIF_F_* feature flags are exposed
> to userspace.

Except sysfs.

> After this patch feature flags may be changed/reordered freely.
[...]

Really, what do you think was the point of exposing features through
sysfs if they are going to be changed?

Oh, but they have been changed already:

v2.5.70
net-sysfs added

v2.6.15
+#define NETIF_F_UFO             8192    /* Can offload UDP Large Send*=
/

v2.6.18
-#define NETIF_F_TSO            2048    /* Can offload TCP/IP segmentat=
ion */
-#define NETIF_F_UFO             8192    /* Can offload UDP Large Send*=
/
+#define NETIF_F_GSO            2048    /* Enable software GSO. */
+#define NETIF_F_GSO_SHIFT      16
+#define NETIF_F_TSO            (SKB_GSO_TCPV4 << NETIF_F_GSO_SHIFT)
+#define NETIF_F_UFO            (SKB_GSO_UDP << NETIF_F_GSO_SHIFT)
+#define NETIF_F_GSO_ROBUST     (SKB_GSO_DODGY << NETIF_F_GSO_SHIFT)
+#define NETIF_F_TSO_ECN                (SKB_GSO_TCP_ECN << NETIF_F_GSO=
_SHIFT)
+#define NETIF_F_TSO6           (SKB_GSO_TCPV6 << NETIF_F_GSO_SHIFT)

v2.6.23
+#define NETIF_F_IPV6_CSUM      16      /* Can checksum TCP/UDP over IP=
V6 */
+#define NETIF_F_MULTI_QUEUE    16384   /* Has multiple TX/RX queues */

v2.6.24
+#define NETIF_F_NETNS_LOCAL    8192    /* Does not change network name=
spaces */

v2.6.27
-#define NETIF_F_MULTI_QUEUE    16384   /* Has multiple TX/RX queues */

v2.6.29
+#define NETIF_F_GRO            16384   /* Generic receive offload */

(I've omitted changes that use previously unused bits.)

If we're going to keep changing features (maybe even more often) then w=
e
have to do something about this sysfs attribute.  Maybe get rid of it
(as it seems not to be widely used, thankfully).  Maybe fix it to use
the same feature values as today, but no new features.  But certainly
don't pretend that feature flags are not exposed.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

