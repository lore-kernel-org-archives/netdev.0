From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with the wireless tree
Date: Wed, 6 Oct 2010 12:09:08 +1100
Message-ID: <20101006120908.ffe99876.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Dan Carpenter <error27@gmail.com>,
	Joe Perches <joe@perches.com>,
	"John W. Linville" <linville@tuxdriver.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:34451 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757002Ab0JFBJO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Oct 2010 21:09:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

Today's linux-next merge of the net tree got a conflict in
drivers/net/wireless/ipw2x00/ipw2200.c between commit
2ee4e27cf25ab647137713ca16377d8d9e138ea2 ("ipw2200: check for allocation
failures") from the wireless tree and commit
baeb2ffab4e67bb9174e6166e070a9a8ec94b0f6 ("drivers/net: Convert unbounded
kzalloc calls to kcalloc") from the net tree.

Just context changes.  I fixed it up (see below) and can carry the fix as
necessary.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/wireless/ipw2x00/ipw2200.c
index d04d760,0f25083..0000000
--- a/drivers/net/wireless/ipw2x00/ipw2200.c
+++ b/drivers/net/wireless/ipw2x00/ipw2200.c
@@@ -11467,13 -11467,9 +11467,13 @@@ static int ipw_net_init(struct net_devi
  
  		bg_band->band = IEEE80211_BAND_2GHZ;
  		bg_band->n_channels = geo->bg_channels;
- 		bg_band->channels =
- 			kzalloc(geo->bg_channels *
- 				sizeof(struct ieee80211_channel), GFP_KERNEL);
+ 		bg_band->channels = kcalloc(geo->bg_channels,
+ 					    sizeof(struct ieee80211_channel),
+ 					    GFP_KERNEL);
 +		if (!bg_band->channels) {
 +			rc = -ENOMEM;
 +			goto out;
 +		}
  		/* translate geo->bg to bg_band.channels */
  		for (i = 0; i < geo->bg_channels; i++) {
  			bg_band->channels[i].band = IEEE80211_BAND_2GHZ;
@@@ -11506,13 -11502,9 +11506,13 @@@
  
  		a_band->band = IEEE80211_BAND_5GHZ;
  		a_band->n_channels = geo->a_channels;
- 		a_band->channels =
- 			kzalloc(geo->a_channels *
- 				sizeof(struct ieee80211_channel), GFP_KERNEL);
+ 		a_band->channels = kcalloc(geo->a_channels,
+ 					   sizeof(struct ieee80211_channel),
+ 					   GFP_KERNEL);
 +		if (!a_band->channels) {
 +			rc = -ENOMEM;
 +			goto out;
 +		}
  		/* translate geo->bg to a_band.channels */
  		for (i = 0; i < geo->a_channels; i++) {
  			a_band->channels[i].band = IEEE80211_BAND_2GHZ;
