From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the wireless tree with the net tree
Date: Fri, 4 Jun 2010 11:48:01 +1000
Message-ID: <20100604114801.df31fb50.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Juuso Oikarinen <juuso.oikarinen@nokia.com>,
	Luciano Coelho <luciano.coelho@nokia.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi John,

Today's linux-next merge of the wireless tree got a conflict in
drivers/net/wireless/wl12xx/wl1271.h
drivers/net/wireless/wl12xx/wl1271_cmd.h between commit
ba2d3587912f82d1ab4367975b1df460db60fb1e ("drivers/net: use __packed
annotation") from the net tree and commit
eb70eb723b489dd4e233e22e47d993f59858cdd8 ("wl1271: Update handling of the
NVS file / INI parameters") from the wireless tree.

I fixed up some if it (see below) and can carry the fixes as necessary.
The latter patch also moved some of the structures to another file
(drivers/net/wireless/wl12xx/wl1271_ini.h), so they will need fixing up
there.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/wireless/wl12xx/wl1271_cmd.h
index d88faf9,68001df..0000000
--- a/drivers/net/wireless/wl12xx/wl1271_cmd.h
+++ b/drivers/net/wireless/wl12xx/wl1271_cmd.h
@@@ -439,25 -439,31 +439,31 @@@ struct wl1271_general_parms_cmd 
  
  	struct wl1271_cmd_test_header test;
  
- 	u8 params[WL1271_NVS_GENERAL_PARAMS_SIZE];
- 	s8 reserved[23];
- } __packed;
+ 	struct wl1271_ini_general_params general_params;
  
- #define WL1271_STAT_RADIO_PARAMS_5_SIZE    29
- #define WL1271_DYN_RADIO_PARAMS_5_SIZE    104
+ 	u8 sr_debug_table[WL1271_INI_MAX_SMART_REFLEX_PARAM];
+ 	u8 sr_sen_n_p;
+ 	u8 sr_sen_n_p_gain;
+ 	u8 sr_sen_nrn;
+ 	u8 sr_sen_prn;
+ 	u8 padding[3];
 -} __attribute__ ((packed));
++} __packed;
  
  struct wl1271_radio_parms_cmd {
  	struct wl1271_cmd_header header;
  
  	struct wl1271_cmd_test_header test;
  
- 	u8 stat_radio_params[WL1271_NVS_STAT_RADIO_PARAMS_SIZE];
- 	u8 stat_radio_params_5[WL1271_STAT_RADIO_PARAMS_5_SIZE];
+ 	/* Static radio parameters */
+ 	struct wl1271_ini_band_params_2 static_params_2;
+ 	struct wl1271_ini_band_params_5 static_params_5;
  
- 	u8 dyn_radio_params[WL1271_NVS_DYN_RADIO_PARAMS_SIZE];
- 	u8 reserved;
- 	u8 dyn_radio_params_5[WL1271_DYN_RADIO_PARAMS_5_SIZE];
+ 	/* Dynamic radio parameters */
+ 	struct wl1271_ini_fem_params_2 dyn_params_2;
+ 	u8 padding2;
+ 	struct wl1271_ini_fem_params_5 dyn_params_5;
+ 	u8 padding3[2];
 -} __attribute__ ((packed));
 +} __packed;
  
  struct wl1271_cmd_cal_channel_tune {
  	struct wl1271_cmd_header header;
