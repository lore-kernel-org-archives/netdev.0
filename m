From: Mark Brown <broonie@kernel.org>
Subject: Re: Build failure after merge of the drm-intel tree
Date: Fri, 4 Oct 2013 21:22:26 +0100
Message-ID: <20131004202226.GT27287@sirena.org.uk>
References: <20131003171440.GD27287@sirena.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="0zAvg8I2HpXbmZ+A"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Thierry Reding <thierry.reding@gmail.com>,
	netdev@vger.kernel.org, brcm80211-dev-list@broadcom.com,
	linux-wireless@vger.kernel.org
To: Brett Rudley <brudley@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	Franky Lin <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	Joe Perches <joe@perches.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131003171440.GD27287@sirena.org.uk>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--0zAvg8I2HpXbmZ+A
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

While merging the wireless-next tree into -next there were conflicts in
several headers due to conflicts between various commits from Joe
Perches removing extern from headers in the net-next tree and
development in the wireless tree.

I've resolved this as below (sorry, got some extra stuff that resolved
automatically).

diff --cc drivers/net/wireless/ath/ath10k/debug.h
index bb00633,fa58148..6576b82
--- a/drivers/net/wireless/ath/ath10k/debug.h
+++ b/drivers/net/wireless/ath/ath10k/debug.h
@@@ -37,11 -38,13 +38,13 @@@ enum ath10k_debug_mask=20
 =20
  extern unsigned int ath10k_debug_mask;
 =20
 -extern __printf(1, 2) int ath10k_info(const char *fmt, ...);
 -extern __printf(1, 2) int ath10k_err(const char *fmt, ...);
 -extern __printf(1, 2) int ath10k_warn(const char *fmt, ...);
 +__printf(1, 2) int ath10k_info(const char *fmt, ...);
 +__printf(1, 2) int ath10k_err(const char *fmt, ...);
 +__printf(1, 2) int ath10k_warn(const char *fmt, ...);
 =20
  #ifdef CONFIG_ATH10K_DEBUGFS
+ int ath10k_debug_start(struct ath10k *ar);
+ void ath10k_debug_stop(struct ath10k *ar);
  int ath10k_debug_create(struct ath10k *ar);
  void ath10k_debug_read_service_map(struct ath10k *ar,
  				   void *service_map,
diff --cc drivers/net/wireless/brcm80211/brcmfmac/bcmsdh_sdmmc.c
index c3462b7,091c905..2a23bf2
--- a/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh_sdmmc.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh_sdmmc.c
@@@ -464,9 -459,11 +459,9 @@@ static struct sdio_driver brcmf_sdmmc_d
 =20
  static int brcmf_sdio_pd_probe(struct platform_device *pdev)
  {
 -	int ret;
 -
  	brcmf_dbg(SDIO, "Enter\n");
 =20
- 	brcmfmac_sdio_pdata =3D pdev->dev.platform_data;
+ 	brcmfmac_sdio_pdata =3D dev_get_platdata(&pdev->dev);
 =20
  	if (brcmfmac_sdio_pdata->power_on)
  		brcmfmac_sdio_pdata->power_on();
diff --cc drivers/net/wireless/brcm80211/brcmfmac/dhd_bus.h
index 7f1340d,200ee9b..a6eb09e
--- a/drivers/net/wireless/brcm80211/brcmfmac/dhd_bus.h
+++ b/drivers/net/wireless/brcm80211/brcmfmac/dhd_bus.h
@@@ -132,34 -132,34 +132,34 @@@ struct pktq *brcmf_bus_gettxq(struct br
   * interface functions from common layer
   */
 =20
 -extern bool brcmf_c_prec_enq(struct device *dev, struct pktq *q,
 -			 struct sk_buff *pkt, int prec);
 +bool brcmf_c_prec_enq(struct device *dev, struct pktq *q, struct sk_buff =
*pkt,
 +		      int prec);
 =20
  /* Receive frame for delivery to OS.  Callee disposes of rxp. */
- void brcmf_rx_frames(struct device *dev, struct sk_buff_head *rxlist);
 -extern void brcmf_rx_frame(struct device *dev, struct sk_buff *rxp);
++void brcmf_rx_frame(struct device *dev, struct sk_buff *rxp);
 =20
  /* Indication from bus module regarding presence/insertion of dongle. */
 -extern int brcmf_attach(uint bus_hdrlen, struct device *dev);
 +int brcmf_attach(uint bus_hdrlen, struct device *dev);
  /* Indication from bus module regarding removal/absence of dongle */
 -extern void brcmf_detach(struct device *dev);
 +void brcmf_detach(struct device *dev);
  /* Indication from bus module that dongle should be reset */
 -extern void brcmf_dev_reset(struct device *dev);
 +void brcmf_dev_reset(struct device *dev);
  /* Indication from bus module to change flow-control state */
 -extern void brcmf_txflowblock(struct device *dev, bool state);
 +void brcmf_txflowblock(struct device *dev, bool state);
 =20
  /* Notify the bus has transferred the tx packet to firmware */
 -extern void brcmf_txcomplete(struct device *dev, struct sk_buff *txp,
 -			     bool success);
 +void brcmf_txcomplete(struct device *dev, struct sk_buff *txp, bool succe=
ss);
 =20
 -extern int brcmf_bus_start(struct device *dev);
 +int brcmf_bus_start(struct device *dev);
 =20
  #ifdef CONFIG_BRCMFMAC_SDIO
 -extern void brcmf_sdio_exit(void);
 -extern void brcmf_sdio_init(void);
 +void brcmf_sdio_exit(void);
 +void brcmf_sdio_init(void);
 +void brcmf_sdio_register(void);
  #endif
  #ifdef CONFIG_BRCMFMAC_USB
 -extern void brcmf_usb_exit(void);
 -extern void brcmf_usb_init(void);
 +void brcmf_usb_exit(void);
 +void brcmf_usb_register(void);
  #endif
 =20
  #endif				/* _BRCMF_BUS_H_ */
diff --cc drivers/net/wireless/rtlwifi/rtl8188ee/phy.h
index 71ddf4f,d4545f0..8e1f1be
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/phy.h
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/phy.h
@@@ -200,26 -200,29 +200,25 @@@ enum _ANT_DIV_TYPE=20
  	CGCS_RX_SW_ANTDIV		=3D 0x05,
  };
 =20
 -extern u32 rtl88e_phy_query_bb_reg(struct ieee80211_hw *hw,
 -				   u32 regaddr, u32 bitmask);
 -extern void rtl88e_phy_set_bb_reg(struct ieee80211_hw *hw,
 -				  u32 regaddr, u32 bitmask, u32 data);
 -extern u32 rtl88e_phy_query_rf_reg(struct ieee80211_hw *hw,
 -				   enum radio_path rfpath, u32 regaddr,
 -				   u32 bitmask);
 -extern void rtl88e_phy_set_rf_reg(struct ieee80211_hw *hw,
 -				  enum radio_path rfpath, u32 regaddr,
 -				  u32 bitmask, u32 data);
 -extern bool rtl88e_phy_mac_config(struct ieee80211_hw *hw);
 -extern bool rtl88e_phy_bb_config(struct ieee80211_hw *hw);
 -extern bool rtl88e_phy_rf_config(struct ieee80211_hw *hw);
 -extern void rtl88e_phy_get_hw_reg_originalvalue(struct ieee80211_hw *hw);
 -extern void rtl88e_phy_get_txpower_level(struct ieee80211_hw *hw,
 -					 long *powerlevel);
 -extern void rtl88e_phy_set_txpower_level(struct ieee80211_hw *hw, u8 chan=
nel);
 -extern void rtl88e_phy_set_bw_mode_callback(struct ieee80211_hw *hw);
 -extern void rtl88e_phy_set_bw_mode(struct ieee80211_hw *hw,
 -				   enum nl80211_channel_type ch_type);
 -extern void rtl88e_phy_sw_chnl_callback(struct ieee80211_hw *hw);
 -extern u8 rtl88e_phy_sw_chnl(struct ieee80211_hw *hw);
 -extern void rtl88e_phy_iq_calibrate(struct ieee80211_hw *hw, bool b_recov=
ery);
 +u32 rtl88e_phy_query_bb_reg(struct ieee80211_hw *hw, u32 regaddr, u32 bit=
mask);
 +void rtl88e_phy_set_bb_reg(struct ieee80211_hw *hw, u32 regaddr, u32 bitm=
ask,
 +			   u32 data);
 +u32 rtl88e_phy_query_rf_reg(struct ieee80211_hw *hw, enum radio_path rfpa=
th,
 +			    u32 regaddr, u32 bitmask);
 +void rtl88e_phy_set_rf_reg(struct ieee80211_hw *hw, enum radio_path rfpat=
h,
 +			   u32 regaddr, u32 bitmask, u32 data);
 +bool rtl88e_phy_mac_config(struct ieee80211_hw *hw);
 +bool rtl88e_phy_bb_config(struct ieee80211_hw *hw);
 +bool rtl88e_phy_rf_config(struct ieee80211_hw *hw);
 +void rtl88e_phy_get_hw_reg_originalvalue(struct ieee80211_hw *hw);
 +void rtl88e_phy_get_txpower_level(struct ieee80211_hw *hw, long *powerlev=
el);
 +void rtl88e_phy_set_txpower_level(struct ieee80211_hw *hw, u8 channel);
- void rtl88e_phy_scan_operation_backup(struct ieee80211_hw *hw, u8 operati=
on);
 +void rtl88e_phy_set_bw_mode_callback(struct ieee80211_hw *hw);
 +void rtl88e_phy_set_bw_mode(struct ieee80211_hw *hw,
 +			    enum nl80211_channel_type ch_type);
 +void rtl88e_phy_sw_chnl_callback(struct ieee80211_hw *hw);
 +u8 rtl88e_phy_sw_chnl(struct ieee80211_hw *hw);
 +void rtl88e_phy_iq_calibrate(struct ieee80211_hw *hw, bool b_recovery);
  void rtl88e_phy_lc_calibrate(struct ieee80211_hw *hw);
  void rtl88e_phy_set_rfpath_switch(struct ieee80211_hw *hw, bool bmain);
  bool rtl88e_phy_config_rf_with_headerfile(struct ieee80211_hw *hw,
diff --cc drivers/net/wireless/rtlwifi/rtl8192ce/phy.h
index f8973e5,aeb268b..9bb4658
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/phy.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/phy.h
@@@ -199,14 -200,15 +197,14 @@@ bool rtl92c_phy_mac_config(struct ieee8
  bool rtl92ce_phy_bb_config(struct ieee80211_hw *hw);
  bool rtl92c_phy_rf_config(struct ieee80211_hw *hw);
  bool rtl92c_phy_config_rf_with_feaderfile(struct ieee80211_hw *hw,
 -						 enum radio_path rfpath);
 +					  enum radio_path rfpath);
  void rtl92c_phy_get_hw_reg_originalvalue(struct ieee80211_hw *hw);
 -void rtl92c_phy_get_txpower_level(struct ieee80211_hw *hw,
 -					 long *powerlevel);
 +void rtl92c_phy_get_txpower_level(struct ieee80211_hw *hw, long *powerlev=
el);
  void rtl92c_phy_set_txpower_level(struct ieee80211_hw *hw, u8 channel);
- bool rtl92c_phy_update_txpower_dbm(struct ieee80211_hw *hw, long power_in=
dbm);
- void rtl92c_phy_scan_operation_backup(struct ieee80211_hw *hw, u8 operati=
on);
+ bool rtl92c_phy_update_txpower_dbm(struct ieee80211_hw *hw,
+ 					  long power_indbm);
  void rtl92c_phy_set_bw_mode(struct ieee80211_hw *hw,
 -				   enum nl80211_channel_type ch_type);
 +			    enum nl80211_channel_type ch_type);
  void rtl92c_phy_sw_chnl_callback(struct ieee80211_hw *hw);
  u8 rtl92c_phy_sw_chnl(struct ieee80211_hw *hw);
  void rtl92c_phy_iq_calibrate(struct ieee80211_hw *hw, bool b_recovery);
@@@ -217,10 -220,10 +215,10 @@@ void _rtl92ce_phy_lc_calibrate(struct i
  void rtl92c_phy_set_rfpath_switch(struct ieee80211_hw *hw, bool bmain);
  bool rtl92c_phy_config_rf_with_headerfile(struct ieee80211_hw *hw,
  					  enum radio_path rfpath);
- bool rtl8192_phy_check_is_legal_rfpath(struct ieee80211_hw *hw, u32 rfpat=
h);
- bool rtl92c_phy_set_io_cmd(struct ieee80211_hw *hw, enum io_type iotype);
+ bool rtl8192_phy_check_is_legal_rfpath(struct ieee80211_hw *hw,
+ 					      u32 rfpath);
  bool rtl92ce_phy_set_rf_power_state(struct ieee80211_hw *hw,
 -					  enum rf_pwrstate rfpwr_state);
 +				    enum rf_pwrstate rfpwr_state);
  void rtl92ce_phy_set_rf_on(struct ieee80211_hw *hw);
  bool rtl92c_phy_set_io_cmd(struct ieee80211_hw *hw, enum io_type iotype);
  void rtl92c_phy_set_io(struct ieee80211_hw *hw);
diff --cc drivers/net/wireless/rtlwifi/rtl8192de/phy.h
index 0f993f4,bef3040..33df0d1c
--- a/drivers/net/wireless/rtlwifi/rtl8192de/phy.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/phy.h
@@@ -127,24 -125,26 +125,23 @@@ static inline void rtl92d_release_cckan
  			*flag);
  }
 =20
 -extern u32 rtl92d_phy_query_bb_reg(struct ieee80211_hw *hw,
 -				   u32 regaddr, u32 bitmask);
 -extern void rtl92d_phy_set_bb_reg(struct ieee80211_hw *hw,
 -				  u32 regaddr, u32 bitmask, u32 data);
 -extern u32 rtl92d_phy_query_rf_reg(struct ieee80211_hw *hw,
 -				   enum radio_path rfpath, u32 regaddr,
 -				   u32 bitmask);
 -extern void rtl92d_phy_set_rf_reg(struct ieee80211_hw *hw,
 -				  enum radio_path rfpath, u32 regaddr,
 -				  u32 bitmask, u32 data);
 -extern bool rtl92d_phy_mac_config(struct ieee80211_hw *hw);
 -extern bool rtl92d_phy_bb_config(struct ieee80211_hw *hw);
 -extern bool rtl92d_phy_rf_config(struct ieee80211_hw *hw);
 -extern bool rtl92c_phy_config_rf_with_feaderfile(struct ieee80211_hw *hw,
 -						 enum radio_path rfpath);
 -extern void rtl92d_phy_get_hw_reg_originalvalue(struct ieee80211_hw *hw);
 -extern void rtl92d_phy_set_txpower_level(struct ieee80211_hw *hw, u8 chan=
nel);
 -extern void rtl92d_phy_set_bw_mode(struct ieee80211_hw *hw,
 -				   enum nl80211_channel_type ch_type);
 -extern u8 rtl92d_phy_sw_chnl(struct ieee80211_hw *hw);
 +u32 rtl92d_phy_query_bb_reg(struct ieee80211_hw *hw, u32 regaddr, u32 bit=
mask);
 +void rtl92d_phy_set_bb_reg(struct ieee80211_hw *hw, u32 regaddr, u32 bitm=
ask,
 +			   u32 data);
 +u32 rtl92d_phy_query_rf_reg(struct ieee80211_hw *hw, enum radio_path rfpa=
th,
 +			    u32 regaddr, u32 bitmask);
 +void rtl92d_phy_set_rf_reg(struct ieee80211_hw *hw, enum radio_path rfpat=
h,
 +			   u32 regaddr, u32 bitmask, u32 data);
 +bool rtl92d_phy_mac_config(struct ieee80211_hw *hw);
 +bool rtl92d_phy_bb_config(struct ieee80211_hw *hw);
 +bool rtl92d_phy_rf_config(struct ieee80211_hw *hw);
 +bool rtl92c_phy_config_rf_with_feaderfile(struct ieee80211_hw *hw,
 +					  enum radio_path rfpath);
 +void rtl92d_phy_get_hw_reg_originalvalue(struct ieee80211_hw *hw);
 +void rtl92d_phy_set_txpower_level(struct ieee80211_hw *hw, u8 channel);
- void rtl92d_phy_scan_operation_backup(struct ieee80211_hw *hw, u8 operati=
on);
 +void rtl92d_phy_set_bw_mode(struct ieee80211_hw *hw,
 +			    enum nl80211_channel_type ch_type);
 +u8 rtl92d_phy_sw_chnl(struct ieee80211_hw *hw);
  bool rtl92d_phy_config_rf_with_headerfile(struct ieee80211_hw *hw,
  					  enum rf_content content,
  					  enum radio_path rfpath);
diff --cc drivers/net/wireless/rtlwifi/rtl8723ae/phy.h
index bbb950d,3d8f9e3..bb18023
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/phy.h
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/phy.h
@@@ -183,33 -183,34 +183,30 @@@ struct tx_power_struct=20
  	u32 mcs_original_offset[4][16];
  };
 =20
 -extern u32 rtl8723ae_phy_query_bb_reg(struct ieee80211_hw *hw,
 -				      u32 regaddr, u32 bitmask);
 -extern void rtl8723ae_phy_set_bb_reg(struct ieee80211_hw *hw,
 -				     u32 regaddr, u32 bitmask, u32 data);
 -extern u32 rtl8723ae_phy_query_rf_reg(struct ieee80211_hw *hw,
 -				      enum radio_path rfpath, u32 regaddr,
 -				      u32 bitmask);
 -extern void rtl8723ae_phy_set_rf_reg(struct ieee80211_hw *hw,
 -				     enum radio_path rfpath, u32 regaddr,
 -				     u32 bitmask, u32 data);
 -extern bool rtl8723ae_phy_mac_config(struct ieee80211_hw *hw);
 -extern bool rtl8723ae_phy_bb_config(struct ieee80211_hw *hw);
 -extern bool rtl8723ae_phy_rf_config(struct ieee80211_hw *hw);
 -extern bool rtl92c_phy_config_rf_with_feaderfile(struct ieee80211_hw *hw,
 -						 enum radio_path rfpath);
 -extern void rtl8723ae_phy_get_hw_reg_originalvalue(struct ieee80211_hw *h=
w);
 -extern void rtl8723ae_phy_get_txpower_level(struct ieee80211_hw *hw,
 -					    long *powerlevel);
 -extern void rtl8723ae_phy_set_txpower_level(struct ieee80211_hw *hw,
 -					    u8 channel);
 -extern bool rtl8723ae_phy_update_txpower_dbm(struct ieee80211_hw *hw,
 -					     long power_indbm);
 -extern void rtl8723ae_phy_set_bw_mode_callback(struct ieee80211_hw *hw);
 -extern void rtl8723ae_phy_set_bw_mode(struct ieee80211_hw *hw,
 -				      enum nl80211_channel_type ch_type);
 -extern void rtl8723ae_phy_sw_chnl_callback(struct ieee80211_hw *hw);
 -extern u8 rtl8723ae_phy_sw_chnl(struct ieee80211_hw *hw);
 -extern void rtl8723ae_phy_iq_calibrate(struct ieee80211_hw *hw, bool reco=
very);
 +u32 rtl8723ae_phy_query_bb_reg(struct ieee80211_hw *hw, u32 regaddr,
 +			       u32 bitmask);
- void rtl8723ae_phy_set_bb_reg(struct ieee80211_hw *hw, u32 regaddr, u32 b=
itmask,
- 			      u32 data);
- u32 rtl8723ae_phy_query_rf_reg(struct ieee80211_hw *hw,
- 			       enum radio_path rfpath, u32 regaddr,
- 			       u32 bitmask);
- void rtl8723ae_phy_set_rf_reg(struct ieee80211_hw *hw,
- 			      enum radio_path rfpath, u32 regaddr, u32 bitmask,
- 			      u32 data);
++void rtl8723ae_phy_set_bb_reg(struct ieee80211_hw *hw, u32 regaddr,
++			      u32 bitmask, u32 data);
++u32 rtl8723ae_phy_query_rf_reg(struct ieee80211_hw *hw, enum radio_path r=
fpath,
++			       u32 regaddr, u32 bitmask);
++void rtl8723ae_phy_set_rf_reg(struct ieee80211_hw *hw, enum radio_path rf=
path,
++			      u32 regaddr, u32 bitmask, u32 data);
 +bool rtl8723ae_phy_mac_config(struct ieee80211_hw *hw);
 +bool rtl8723ae_phy_bb_config(struct ieee80211_hw *hw);
 +bool rtl8723ae_phy_rf_config(struct ieee80211_hw *hw);
 +bool rtl92c_phy_config_rf_with_feaderfile(struct ieee80211_hw *hw,
 +					  enum radio_path rfpath);
 +void rtl8723ae_phy_get_hw_reg_originalvalue(struct ieee80211_hw *hw);
 +void rtl8723ae_phy_get_txpower_level(struct ieee80211_hw *hw, long *power=
level);
 +void rtl8723ae_phy_set_txpower_level(struct ieee80211_hw *hw, u8 channel);
 +bool rtl8723ae_phy_update_txpower_dbm(struct ieee80211_hw *hw,
- 				      long power_indbm);
- void rtl8723ae_phy_scan_operation_backup(struct ieee80211_hw *hw, u8 oper=
ation);
++                                      long power_indbm);
 +void rtl8723ae_phy_set_bw_mode_callback(struct ieee80211_hw *hw);
 +void rtl8723ae_phy_set_bw_mode(struct ieee80211_hw *hw,
 +			       enum nl80211_channel_type ch_type);
 +void rtl8723ae_phy_sw_chnl_callback(struct ieee80211_hw *hw);
 +u8 rtl8723ae_phy_sw_chnl(struct ieee80211_hw *hw);
 +void rtl8723ae_phy_iq_calibrate(struct ieee80211_hw *hw, bool recovery);
  void rtl8723ae_phy_lc_calibrate(struct ieee80211_hw *hw);
  void rtl8723ae_phy_set_rfpath_switch(struct ieee80211_hw *hw, bool bmain);
  bool rtl8723ae_phy_config_rf_with_headerfile(struct ieee80211_hw *hw,

--0zAvg8I2HpXbmZ+A
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.21 (GNU/Linux)

iQIcBAEBAgAGBQJSTyN/AAoJELSic+t+oim9IpcP/Ru2wNtFkC0wubXhZyUqAeMY
XRf5xAjGydiYCogx0O79dmuOW6VvHYUYPImxxnoWxo0zGSSFwAgP2x4pHdTQG1lP
5mNdvbp67x9H+KesgLmK//xANTNLY115cY6JhcPEGyGUlGFYphyocJ9lRhj5FUP/
s116DQUZN8R545EPmM6QQ4IFZ+IxP/ZdS4YUrjtPJ4bnJuhzn3LP43c6AIujUF87
YwaVEhLibDC/IecMaEQR3MCn45UUtDe0TiLrCrmsh7VUda/2yfwE8p/05BT3SYek
5PsO+Sd9Nnwa6gm2RUgd/k0ygKSnc4S4QDyfKmBAzT5S/Dvc5NMt+pCbKNwDZD9H
LRiL9XMR7X2QoD+qH/BXOaMYpl4YYeLAwvs3OuMu5KJEvHXlbBd2wI3o/yfGzz/N
peVCzYeQx4L2Mpj1m3QZZJS8PbxtDnEtKWoV1zbSzPEpBFol2pBDX8Xx/eLCKWgt
2Qgth1ywmfKvIeEqLH+nhB2dykAaMqDxT4M579tSPGdGAn1XV8AXFaJ/8prrK4iv
4SKzo1cYD+iZ65vHaZVGD/7AZ+i61Ju9rKFH08mUmmgAfmWnjCMfCscjm4OXIhwy
7uylCks3Fdg3AEw8cutYKO6mDQrwfGYc+ByP0QYpWl0oQwyVoyop5SJPGYMSVgLn
D86obr3yttrhKD1KVD1u
=Q9i1
-----END PGP SIGNATURE-----

--0zAvg8I2HpXbmZ+A--
