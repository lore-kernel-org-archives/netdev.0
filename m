From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the wireless tree with the net tree
Date: Mon, 12 Apr 2010 14:05:17 +1000
Message-ID: <20100412140517.f433690b.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jiri Pirko <jpirko@redhat.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Saravanan Dhanabal <ext-saravanan.dhanabal@nokia.com>,
	Luciano Coelho <luciano.coelho@nokia.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi John,

Today's linux-next merge of the wireless tree got a conflict in
drivers/net/wireless/wl12xx/wl1271_main.c between commit
22bedad3ce112d5ca1eaf043d4990fa2ed698c87 ("net: convert multicast list to
list_head") from the net tree and commit
2c10bb9cb3f9cecb71bd2cbb771778136433ebe2 ("wl1271: Fix mac80211
configuration requests during WL1271_STATE_OFF") from the wireless tree.

Just context changes.  I fixed it up (see below) and can carry the fix as
necessary.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/wireless/wl12xx/wl1271_main.c
index aa970b7,283d5da..0000000
--- a/drivers/net/wireless/wl12xx/wl1271_main.c
+++ b/drivers/net/wireless/wl12xx/wl1271_main.c
@@@ -1267,11 -1304,15 +1305,15 @@@ struct wl1271_filter_params 
  	u8 mc_list[ACX_MC_ADDRESS_GROUP_MAX][ETH_ALEN];
  };
  
 -static u64 wl1271_op_prepare_multicast(struct ieee80211_hw *hw, int mc_count,
 -				       struct dev_addr_list *mc_list)
 +static u64 wl1271_op_prepare_multicast(struct ieee80211_hw *hw,
 +				       struct netdev_hw_addr_list *mc_list)
  {
  	struct wl1271_filter_params *fp;
 +	struct netdev_hw_addr *ha;
+ 	struct wl1271 *wl = hw->priv;
 -	int i;
+ 
+ 	if (unlikely(wl->state == WL1271_STATE_OFF))
+ 		return 0;
  
  	fp = kzalloc(sizeof(*fp), GFP_ATOMIC);
  	if (!fp) {
