From: Lutz Jaenicke <ljaenicke@innominate.com>
Subject: Re: [PATCHv6 2/3] Interface group: core (netlink) part
Date: Fri, 23 Nov 2007 14:18:00 +0100
Message-ID: <20071123131800.GA31342@innominate.com>
References: <11955644701165-git-send-email-panther@balabit.hu> <1195564470928-git-send-email-panther@balabit.hu> <11955644702451-git-send-email-panther@balabit.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Laszlo Attila Toth <panther@balabit.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from home.innominate.com ([77.245.32.75]:39172 "EHLO
	home.innominate.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756578AbXKWNYC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Nov 2007 08:24:02 -0500
Content-Disposition: inline
In-Reply-To: <11955644702451-git-send-email-panther@balabit.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 20, 2007 at 02:14:26PM +0100, Laszlo Attila Toth wrote:
> Interface groups let handle different interfaces together.
> Modified net device structure and netlink interface.
>=20
> Signed-off-by: Laszlo Attila Toth <panther@balabit.hu>
> ---
>  include/linux/if_link.h   |    2 ++
>  include/linux/netdevice.h |    2 ++
>  net/core/rtnetlink.c      |   11 +++++++++++
>  3 files changed, 15 insertions(+), 0 deletions(-)

Adding read/write support via sysfs should not be too difficult:

diff -ruN a/net/core/net-sysfs.c b/net/core/net-sysfs.c
--- a/net/core/net-sysfs.c	2007-11-17 06:16:36.000000000 +0100
+++ b/net/core/net-sysfs.c	2007-11-23 14:04:47.000000000 +0100
@@ -219,6 +219,20 @@
 	return netdev_store(dev, attr, buf, len, change_tx_queue_len);
 }
=20
+NETDEVICE_SHOW(ifgroup, fmt_hex);
+
+static int change_ifgroup(struct net_device *net, unsigned long new_if=
group)
+{
+	net->ifgroup =3D new_ifgroup;
+	return 0;
+}
+
+static ssize_t store_ifgroup(struct device *dev, struct device_attribu=
te *attr,
+			   const char *buf, size_t len)
+{
+	return netdev_store(dev, attr, buf, len, change_ifgroup);
+}
+
 static struct device_attribute net_class_attributes[] =3D {
 	__ATTR(addr_len, S_IRUGO, show_addr_len, NULL),
 	__ATTR(iflink, S_IRUGO, show_iflink, NULL),
@@ -235,6 +249,7 @@
 	__ATTR(flags, S_IRUGO | S_IWUSR, show_flags, store_flags),
 	__ATTR(tx_queue_len, S_IRUGO | S_IWUSR, show_tx_queue_len,
 	       store_tx_queue_len),
+	__ATTR(ifgroup, S_IRUGO | S_IWUSR, show_ifgroup, store_ifgroup),
 	{}
 };
=20
--=20
Dr.-Ing. Lutz J=E4nicke
CTO
Innominate Security Technologies AG  /protecting industrial networks/
tel: +49.30.6392-3308
fax: +49.30.6392-3307
Albert-Einstein-Str. 14
D-12489 Berlin, Germany
www.innominate.com

Register Court: AG Charlottenburg, HR B 81603
Management Board: Joachim Fietz, Dirk Seewald
Chairman of the Supervisory Board: Edward M. Stadum

-----------------------------------------------------------------------=
-----

Visit us at the SPS/IPC/Drives in Nuremberg / Germany

27 - 29 November 2007, Hall 9, Stand 9-141

-----------------------------------------------------------------------=
-----
