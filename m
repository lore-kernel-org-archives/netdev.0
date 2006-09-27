From: matthieu castet <castet.matthieu@free.fr>
Subject: Re: softmac mtu
Date: Wed, 27 Sep 2006 19:17:09 +0200
Message-ID: <451AB215.3080500@free.fr>
References: <ef3s4u$or5$3@sea.gmane.org> <ef9a0b$4jb$4@sea.gmane.org>	 <20060925200125.GF16949@tuxdriver.com>	 <20060927143905.721ddf3e@griffin.suse.cz>	 <1159365434.451a833ae7728@imp3-g19.free.fr> <1159365316.2698.40.camel@ux156>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080201050109010505060500"
Cc: Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4-g19.free.fr ([212.27.42.30]:4845 "EHLO smtp4-g19.free.fr")
	by vger.kernel.org with ESMTP id S1030466AbWI0RRN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2006 13:17:13 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1159365316.2698.40.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080201050109010505060500
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Johannes Berg wrote:
> On Wed, 2006-09-27 at 15:57 +0200, castet.matthieu@free.fr wrote:
> 
> 
>>Also I wonder what should be the max mtu.
> 
> 
> 2304, I think, as that's
> synonym sMaxMsduLng Integer = 2304; /* max octets in an MSDU */
> 

Yes but if it is bigger the frame get framented at the 802.11 layer : in 
theory we could put mtu (IP max packet size) a big as we want [1].
Also if I understand it correctly if encryption is used there is less 
space for IP data ?

If people want to play with it, I attach the current version of my 
(trivial) patch.


Matthieu

[1]
if mtu > 2304, (struct ieee80211_txb*)->nr_frags is bigger than one ;)

--------------080201050109010505060500
Content-Type: text/plain;
 name="ieee80211mtu"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ieee80211mtu"

Index: linux/net/ieee80211/ieee80211_module.c
===================================================================
--- linux.orig/net/ieee80211/ieee80211_module.c	2006-09-25 22:37:20.000000000 +0200
+++ linux/net/ieee80211/ieee80211_module.c	2006-09-25 22:39:07.000000000 +0200
@@ -118,6 +118,14 @@
 			      &ieee->network_free_list);
 }
 
+static int ieee80211_change_mtu(struct net_device *dev, int new_mtu)
+{
+	if ((new_mtu < 68) || (new_mtu > 2400))
+		return -EINVAL;
+	dev->mtu = new_mtu;
+	return 0;
+}
+
 struct net_device *alloc_ieee80211(int sizeof_priv)
 {
 	struct ieee80211_device *ieee;
@@ -133,6 +141,7 @@
 	}
 	ieee = netdev_priv(dev);
 	dev->hard_start_xmit = ieee80211_xmit;
+	dev->change_mtu = ieee80211_change_mtu;
 
 	ieee->dev = dev;
 

--------------080201050109010505060500--
