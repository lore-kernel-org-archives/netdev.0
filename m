From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the wireless tree with the net tree
Date: Wed, 23 Jun 2010 12:51:38 +1000
Message-ID: <20100623125138.dff6c368.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Kiran Divekar <dkiran@marvell.com>,
	Amitkumar Karwar <akarwar@marvell.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:41112 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751658Ab0FWCvk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jun 2010 22:51:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi John,

Today's linux-next merge of the wireless tree got a conflict in
drivers/net/wireless/libertas/host.h between commit
ba2d3587912f82d1ab4367975b1df460db60fb1e ("drivers/net: use __packed
annotation") from the net tree and commit
c2af450168af531b70564e3ceb20983199a66216 ("Libertas: Added 11d support
using cfg80211") from the wireless tree.

Just a white space change clashing with a real change!  I fixed it up
(and changed some newly added "__attribute__ ((packed))" to "__packed" as
well ...) (see below) and can carry the fix as necessary.

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/wireless/libertas/host.h
index 3bd5d3b,112fbf1..0000000
--- a/drivers/net/wireless/libertas/host.h
+++ b/drivers/net/wireless/libertas/host.h
@@@ -387,8 -387,32 +387,32 @@@ struct enc_key 
  struct lbs_offset_value {
  	u32 offset;
  	u32 value;
 -} __attribute__ ((packed));
 +} __packed;
  
+ #define MRVDRV_MAX_TRIPLET_802_11D              83
+ 
+ #define COUNTRY_CODE_LEN                        3
+ 
+ struct mrvl_ie_domain_param_set {
+ 	struct mrvl_ie_header header;
+ 
+ 	u8 countrycode[COUNTRY_CODE_LEN];
+ 	struct ieee80211_country_ie_triplet triplet[1];
 -} __attribute__ ((packed));
++} __packed;
+ 
+ struct cmd_ds_802_11d_domain_info {
+ 	__le16 action;
+ 	struct mrvl_ie_domain_param_set domain;
 -} __attribute__ ((packed));
++} __packed;
+ 
+ struct lbs_802_11d_domain_reg {
+ 	/** Country code*/
+ 	u8 country_code[COUNTRY_CODE_LEN];
+ 	/** No. of triplet*/
+ 	u8 no_triplet;
+ 	struct ieee80211_country_ie_triplet triplet[MRVDRV_MAX_TRIPLET_802_11D];
 -} __attribute__ ((packed));
++} __packed;
+ 
  /*
   * Define data structure for CMD_GET_HW_SPEC
   * This structure defines the response for the GET_HW_SPEC command
