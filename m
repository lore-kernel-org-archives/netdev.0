From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [RFC] Wireless extensions rethink
Date: Thu, 17 Jun 2004 14:23:01 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40D1E185.2010201@pobox.com>
References: <C6F5CF431189FA4CBAEC9E7DD5441E0103AF626C@orsmsx402.amr.corp.intel.com> <40CF263E.70009@home.nl> <1087377197.25912.54.camel@sfeldma-mobl2.dsl-verizon.net> <40D08769.3070106@home.nl> <20040616204248.GA23617@bougret.hpl.hp.com> <40D0BD5B.201@pobox.com> <20040616223316.GA29618@bougret.hpl.hp.com> <40D0D265.3070804@pobox.com> <20040617174717.GA30460@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050606090300090402020100"
Cc: Gertjan van Wingerde <gwingerde@home.nl>, sfeldma@pobox.com,
        netdev@oss.sgi.com, jkmaline@cc.hut.fi
Return-path: <netdev-bounce@oss.sgi.com>
To: jt@hpl.hp.com
In-Reply-To: <20040617174717.GA30460@bougret.hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050606090300090402020100
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Jean Tourrilhes wrote:
> On Wed, Jun 16, 2004 at 07:06:13PM -0400, Jeff Garzik wrote:
> 
>>It's not Jeff's weird personal preference that iw_handler be killed... 
>>type-opaque interfaces cause real problems.  A good C programmer should 
>>very, very rarely use type-casting.
> 
> 
> 	Yes, I know that I am really a perverse mind and I did
> designed the API this way only to make your life miserable and to
> sabotage the Linux kernel.
> 
> 	As a matter of fact, I tried the strongly type approach you
> advocate and find its kernel overhead not acceptable. Note that people
> not using wireless have to suffer from this bloat, and wireless
> extensions are used in embeeded platforms such as OpenAP, iPaq and
> Zaurus where footprint matters.

As you can see from the patch and header I have attached, there is 
_zero_ change to storage.  No additional bloat.


> 	Now, it seems that you clearly have not understood my
> proposal, so I made a little patch, hopping that it will clear the
> obvious miscommunication. Patch is below.
> 	I hope you will notice that the changes are fairly trivial and
> clean. And it's backward compatible.
> 	I also want you to notice that the code is quasi optimal,
> compared to rewritting the API, there is only one additional function
> call (plus the backward compatibility). I know you won't believe me,
> so verify that yourself. I think this is a small price to pay for
> keeping backward compatibility with all those drivers outside the
> kernel (see my web page).

Sorry, keeping compatibility with drivers outside the kernel is _not_ a 
priority here.  Backward compatibility is how this cruft accumulated in 
the first place.

Go ahead and assume that drivers outside the kernel will break.  This is 
no different from vendor drivers -- if the driver is not in the kernel, 
it doesn't exist.

	Jeff



--------------050606090300090402020100
Content-Type: text/plain;
 name="patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch"

===== drivers/net/wireless/wl3501_cs.c 1.77 vs edited =====
--- 1.77/drivers/net/wireless/wl3501_cs.c	2004-06-03 21:38:07 -04:00
+++ edited/drivers/net/wireless/wl3501_cs.c	2004-06-16 19:42:10 -04:00
@@ -46,6 +46,7 @@
 #include <linux/slab.h>
 #include <linux/string.h>
 #include <linux/wireless.h>
+#include <linux/wifi.h>
 
 #include <net/iw_handler.h>
 
@@ -1959,38 +1960,37 @@
 	return rc;
 }
 
-static const iw_handler	wl3501_handler[] = {
-	[SIOCGIWNAME	- SIOCIWFIRST] = wl3501_get_name,
-	[SIOCSIWFREQ	- SIOCIWFIRST] = wl3501_set_freq,
-	[SIOCGIWFREQ	- SIOCIWFIRST] = wl3501_get_freq,
-	[SIOCSIWMODE	- SIOCIWFIRST] = wl3501_set_mode,
-	[SIOCGIWMODE	- SIOCIWFIRST] = wl3501_get_mode,
-	[SIOCGIWSENS	- SIOCIWFIRST] = wl3501_get_sens,
-	[SIOCGIWRANGE	- SIOCIWFIRST] = wl3501_get_range,
-	[SIOCSIWSPY	- SIOCIWFIRST] = iw_handler_set_spy,
-	[SIOCGIWSPY	- SIOCIWFIRST] = iw_handler_get_spy,
-	[SIOCSIWTHRSPY	- SIOCIWFIRST] = iw_handler_set_thrspy,
-	[SIOCGIWTHRSPY	- SIOCIWFIRST] = iw_handler_get_thrspy,
-	[SIOCSIWAP	- SIOCIWFIRST] = wl3501_set_wap,
-	[SIOCGIWAP	- SIOCIWFIRST] = wl3501_get_wap,
-	[SIOCSIWSCAN	- SIOCIWFIRST] = wl3501_set_scan,
-	[SIOCGIWSCAN	- SIOCIWFIRST] = wl3501_get_scan,
-	[SIOCSIWESSID	- SIOCIWFIRST] = wl3501_set_essid,
-	[SIOCGIWESSID	- SIOCIWFIRST] = wl3501_get_essid,
-	[SIOCSIWNICKN	- SIOCIWFIRST] = wl3501_set_nick,
-	[SIOCGIWNICKN	- SIOCIWFIRST] = wl3501_get_nick,
-	[SIOCGIWRATE	- SIOCIWFIRST] = wl3501_get_rate,
-	[SIOCGIWRTS	- SIOCIWFIRST] = wl3501_get_rts_threshold,
-	[SIOCGIWFRAG	- SIOCIWFIRST] = wl3501_get_frag_threshold,
-	[SIOCGIWTXPOW	- SIOCIWFIRST] = wl3501_get_txpow,
-	[SIOCGIWRETRY	- SIOCIWFIRST] = wl3501_get_retry,
-	[SIOCGIWENCODE	- SIOCIWFIRST] = wl3501_get_encode,
-	[SIOCGIWPOWER	- SIOCIWFIRST] = wl3501_get_power,
+static const struct wireless_ops wl3501_ops = {
+	.get_name		= wl3501_get_name,
+	.get_freq		= wl3501_get_freq,
+	.set_freq		= wl3501_set_freq,
+	.set_mode		= wl3501_set_mode,
+	.get_mode		= wl3501_get_mode,
+	.get_sens		= wl3501_get_sens,
+	.get_range		= wl3501_get_range,
+	.set_spy		= iw_handler_set_spy,
+	.get_spy		= iw_handler_get_spy,
+	.set_thrspy		= iw_handler_set_thrspy,
+	.get_thrspy		= iw_handler_get_thrspy,
+	.set_wap		= wl3501_set_wap,
+	.get_wap		= wl3501_get_wap,
+	.set_scan		= wl3501_set_scan,
+	.get_scan		= wl3501_get_scan,
+	.set_essid		= wl3501_set_essid,
+	.get_essid		= wl3501_get_essid,
+	.set_nick		= wl3501_set_nick,
+	.get_nick		= wl3501_get_nick,
+	.get_rate		= wl3501_get_rate,
+	.get_rts_threshold	= wl3501_get_rts_threshold,
+	.get_frag_threshold	= wl3501_get_frag_threshold,
+	.get_txpow		= wl3501_get_txpow,
+	.get_retry		= wl3501_get_retry,
+	.get_encode		= wl3501_get_encode,
+	.get_power		= wl3501_get_power,
 };
 
-static const struct iw_handler_def wl3501_handler_def = {
-	.num_standard	= sizeof(wl3501_handler) / sizeof(iw_handler),
-	.standard	= (iw_handler *)wl3501_handler,
+static const struct wireless_handler wl3501_handler = {
+	.ops		= &wl3501_ops,
 	.spy_offset	= offsetof(struct wl3501_card, spy_data),
 };
 
@@ -2048,7 +2048,7 @@
 	dev->get_stats		= wl3501_get_stats;
 	dev->get_wireless_stats = wl3501_get_wireless_stats;
 	dev->do_ioctl		= wl3501_ioctl;
-	dev->wireless_handlers	= (struct iw_handler_def *)&wl3501_handler_def;
+	dev->wireless_handler	= &wl3501_handler;
 	netif_stop_queue(dev);
 	link->priv = link->irq.Instance = dev;
 
===== include/linux/netdevice.h 1.80 vs edited =====
--- 1.80/include/linux/netdevice.h	2004-06-04 01:02:47 -04:00
+++ edited/include/linux/netdevice.h	2004-06-16 19:42:38 -04:00
@@ -41,6 +41,7 @@
 struct divert_blk;
 struct vlan_group;
 struct ethtool_ops;
+struct wireless_handler;
 
 					/* source back-compat hooks */
 #define SET_ETHTOOL_OPS(netdev,ops) \
@@ -304,7 +305,7 @@
 
 	/* List of functions to handle Wireless Extensions (instead of ioctl).
 	 * See <net/iw_handler.h> for details. Jean II */
-	struct iw_handler_def *	wireless_handlers;
+	const struct wireless_handler *wireless_handler;
 
 	struct ethtool_ops *ethtool_ops;
 

--------------050606090300090402020100
Content-Type: text/x-chdr;
 name="wifi.h"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="wifi.h"

#ifndef __LINUX_WIFI_H__
#define __LINUX_WIFI_H__

#include <net/iw_handler.h>

struct wireless_ops {
	int (*get_name) (struct net_device *dev, struct iw_request_info *info,
                           union iwreq_data *wrqu, char *extra);
	int (*get_freq) (struct net_device *dev, struct iw_request_info *info,
	                           union iwreq_data *wrqu, char *extra);
	int (*set_freq) (struct net_device *dev, struct iw_request_info *info,
                           union iwreq_data *wrqu, char *extra);
	int (*get_mode) (struct net_device *dev, struct iw_request_info *info,
                           union iwreq_data *wrqu, char *extra);
	int (*set_mode) (struct net_device *dev, struct iw_request_info *info,
                           union iwreq_data *wrqu, char *extra);
	int (*get_sens) (struct net_device *dev, struct iw_request_info *info,
                           union iwreq_data *wrqu, char *extra);
	int (*get_range) (struct net_device *dev, struct iw_request_info *info,
                           union iwreq_data *wrqu, char *extra);
	int (*get_spy) (struct net_device *dev, struct iw_request_info *info,
                           union iwreq_data *wrqu, char *extra);
	int (*set_spy) (struct net_device *dev, struct iw_request_info *info,
                           union iwreq_data *wrqu, char *extra);
	int (*get_thrspy) (struct net_device *dev, struct iw_request_info *info,
                           union iwreq_data *wrqu, char *extra);
	int (*set_thrspy) (struct net_device *dev, struct iw_request_info *info,
                           union iwreq_data *wrqu, char *extra);
	int (*get_wap) (struct net_device *dev, struct iw_request_info *info,
                           union iwreq_data *wrqu, char *extra);
	int (*set_wap) (struct net_device *dev, struct iw_request_info *info,
                           union iwreq_data *wrqu, char *extra);
	int (*get_scan) (struct net_device *dev, struct iw_request_info *info,
                           union iwreq_data *wrqu, char *extra);
	int (*set_scan) (struct net_device *dev, struct iw_request_info *info,
                           union iwreq_data *wrqu, char *extra);
	int (*get_essid) (struct net_device *dev, struct iw_request_info *info,
                           union iwreq_data *wrqu, char *extra);
	int (*set_essid) (struct net_device *dev, struct iw_request_info *info,
                           union iwreq_data *wrqu, char *extra);
	int (*get_nick) (struct net_device *dev, struct iw_request_info *info,
                           union iwreq_data *wrqu, char *extra);
	int (*set_nick) (struct net_device *dev, struct iw_request_info *info,
                           union iwreq_data *wrqu, char *extra);
	int (*get_rate) (struct net_device *dev, struct iw_request_info *info,
                           union iwreq_data *wrqu, char *extra);
	int (*get_rts_threshold) (struct net_device *dev, struct iw_request_info *info,
                           union iwreq_data *wrqu, char *extra);
	int (*get_frag_threshold) (struct net_device *dev, struct iw_request_info *info,
                           union iwreq_data *wrqu, char *extra);
	int (*get_txpow) (struct net_device *dev, struct iw_request_info *info,
                           union iwreq_data *wrqu, char *extra);
	int (*get_retry) (struct net_device *dev, struct iw_request_info *info,
                           union iwreq_data *wrqu, char *extra);
	int (*get_encode) (struct net_device *dev, struct iw_request_info *info,
                           union iwreq_data *wrqu, char *extra);
	int (*get_power) (struct net_device *dev, struct iw_request_info *info,
                           union iwreq_data *wrqu, char *extra);

};

struct wireless_handler {
	const struct wireless_ops	*ops;
	size_t				spy_offset;
};

#endif /* __LINUX_WIFI_H__ */

--------------050606090300090402020100--
