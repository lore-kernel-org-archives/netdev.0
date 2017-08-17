From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 0/8] staging: Add new driver for RTL8822BE
Date: Thu, 17 Aug 2017 12:46:44 -0500
Message-ID: <20170817174652.17656-1-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, Ping-Ke Shih <pkshih@realtek.com>,
 Yan-Hsuan Chuang <yhchuang@realtek.com>, netdev@vger.kernel.org,
 Birming Chiu <birming@realtek.com>, Shaofu <shaofu@realtek.com>,
 Steven Ting <steventing@realtek.com>, Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

The RTL8822BE, an 802.11ac wireless network card, is now appearing in
new computers. Its driver is being placed in staging to reduce the time
that users of this new card will have access to in-kernel drivers.

Residence in staging should be relatively short as we soon plan to start
introducing the code into the main wireless tree in small pieces.

To minimize interference between the rtlwifi drivers in the wireless tree
and this new driver, the new one can only be built as a module. In
addition, all code is built into a single module.

Larry Finger

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Ping-Ke Shih <pkshih@realtek.com>
Cc: Yan-Hsuan Chuang <yhchuang@realtek.com>
Cc: Birming Chiu <birming@realtek.com>
Cc: Shaofu <shaofu@realtek.com>
Cc: Steven Ting <steventing@realtek.com>

Larry Finger (8):
  staging: r8822be: Add existing rtlwifi and rtl_pci parts for new
    driver
  staging: r8822be: Copy existing btcoexist code into staging
  staging: r8822be: Add r8822be btcoexist routines to staging
  staging: r8822be: Add code for halmac sub-driver
  staging: r8822be: Add phydm mini driver
  staging: r8822be: Add the driver code
  staging: r8822be: Add Makefiles and Kconfig for new driver
  staging: rtlwifi: Reviewers fixes

 drivers/staging/Kconfig                            |     2 +
 drivers/staging/Makefile                           |     1 +
 drivers/staging/rtlwifi/Kconfig                    |    22 +
 drivers/staging/rtlwifi/Makefile                   |    70 +
 drivers/staging/rtlwifi/TODO                       |    11 +
 drivers/staging/rtlwifi/base.c                     |  2826 ++++
 drivers/staging/rtlwifi/base.h                     |   186 +
 drivers/staging/rtlwifi/btcoexist/Makefile         |     8 +
 drivers/staging/rtlwifi/btcoexist/halbt_precomp.h  |    85 +
 .../staging/rtlwifi/btcoexist/halbtc8822b1ant.c    |  5246 ++++++++
 .../staging/rtlwifi/btcoexist/halbtc8822b1ant.h    |   444 +
 .../staging/rtlwifi/btcoexist/halbtc8822b2ant.c    |  5225 ++++++++
 .../staging/rtlwifi/btcoexist/halbtc8822b2ant.h    |   498 +
 .../rtlwifi/btcoexist/halbtc8822bwifionly.c        |    65 +
 .../rtlwifi/btcoexist/halbtc8822bwifionly.h        |    35 +
 drivers/staging/rtlwifi/btcoexist/halbtcoutsrc.c   |  1881 +++
 drivers/staging/rtlwifi/btcoexist/halbtcoutsrc.h   |   802 ++
 drivers/staging/rtlwifi/btcoexist/rtl_btc.c        |   528 +
 drivers/staging/rtlwifi/btcoexist/rtl_btc.h        |    75 +
 drivers/staging/rtlwifi/cam.c                      |   326 +
 drivers/staging/rtlwifi/cam.h                      |    50 +
 drivers/staging/rtlwifi/core.c                     |  2046 +++
 drivers/staging/rtlwifi/core.h                     |    86 +
 drivers/staging/rtlwifi/debug.c                    |   592 +
 drivers/staging/rtlwifi/debug.h                    |   234 +
 drivers/staging/rtlwifi/efuse.c                    |  1342 ++
 drivers/staging/rtlwifi/efuse.h                    |   120 +
 drivers/staging/rtlwifi/halmac/halmac_2_platform.h |    52 +
 .../halmac_88xx/halmac_8822b/halmac_8822b_cfg.h    |   132 +
 .../halmac_88xx/halmac_8822b/halmac_8822b_phy.c    |   106 +
 .../halmac_8822b/halmac_8822b_pwr_seq.c            |   563 +
 .../halmac_8822b/halmac_8822b_pwr_seq.h            |    40 +
 .../halmac_88xx/halmac_8822b/halmac_api_8822b.c    |   343 +
 .../halmac_88xx/halmac_8822b/halmac_api_8822b.h    |    44 +
 .../halmac_8822b/halmac_api_8822b_pcie.c           |   323 +
 .../halmac_8822b/halmac_api_8822b_pcie.h           |    53 +
 .../halmac_8822b/halmac_api_8822b_sdio.c           |   184 +
 .../halmac_8822b/halmac_api_8822b_sdio.h           |    42 +
 .../halmac_8822b/halmac_api_8822b_usb.c            |   185 +
 .../halmac_8822b/halmac_api_8822b_usb.h            |    45 +
 .../halmac_88xx/halmac_8822b/halmac_func_8822b.c   |   414 +
 .../halmac_88xx/halmac_8822b/halmac_func_8822b.h   |    38 +
 .../rtlwifi/halmac/halmac_88xx/halmac_88xx_cfg.h   |   171 +
 .../rtlwifi/halmac/halmac_88xx/halmac_api_88xx.c   |  5980 +++++++++
 .../rtlwifi/halmac/halmac_88xx/halmac_api_88xx.h   |   396 +
 .../halmac/halmac_88xx/halmac_api_88xx_pcie.c      |   329 +
 .../halmac/halmac_88xx/halmac_api_88xx_pcie.h      |    71 +
 .../halmac/halmac_88xx/halmac_api_88xx_sdio.c      |   974 ++
 .../halmac/halmac_88xx/halmac_api_88xx_sdio.h      |    84 +
 .../halmac/halmac_88xx/halmac_api_88xx_usb.c       |   554 +
 .../halmac/halmac_88xx/halmac_api_88xx_usb.h       |    73 +
 .../rtlwifi/halmac/halmac_88xx/halmac_func_88xx.c  |  4499 +++++++
 .../rtlwifi/halmac/halmac_88xx/halmac_func_88xx.h  |   321 +
 drivers/staging/rtlwifi/halmac/halmac_api.c        |   426 +
 drivers/staging/rtlwifi/halmac/halmac_api.h        |    82 +
 drivers/staging/rtlwifi/halmac/halmac_bit2.h       | 13407 +++++++++++++++++++
 drivers/staging/rtlwifi/halmac/halmac_bit_8822b.h  | 12103 +++++++++++++++++
 drivers/staging/rtlwifi/halmac/halmac_fw_info.h    |   122 +
 .../rtlwifi/halmac/halmac_fw_offload_c2h_nic.h     |   184 +
 .../rtlwifi/halmac/halmac_fw_offload_h2c_nic.h     |   515 +
 .../rtlwifi/halmac/halmac_h2c_extra_info_nic.h     |   115 +
 .../staging/rtlwifi/halmac/halmac_intf_phy_cmd.h   |    54 +
 .../rtlwifi/halmac/halmac_original_c2h_nic.h       |   403 +
 .../rtlwifi/halmac/halmac_original_h2c_nic.h       |  1011 ++
 drivers/staging/rtlwifi/halmac/halmac_pcie_reg.h   |    28 +
 .../staging/rtlwifi/halmac/halmac_pwr_seq_cmd.h    |   116 +
 drivers/staging/rtlwifi/halmac/halmac_reg2.h       |  1132 ++
 drivers/staging/rtlwifi/halmac/halmac_reg_8822b.h  |   728 +
 drivers/staging/rtlwifi/halmac/halmac_rx_bd_chip.h |    48 +
 drivers/staging/rtlwifi/halmac/halmac_rx_bd_nic.h  |    48 +
 .../staging/rtlwifi/halmac/halmac_rx_desc_chip.h   |   118 +
 .../staging/rtlwifi/halmac/halmac_rx_desc_nic.h    |   133 +
 drivers/staging/rtlwifi/halmac/halmac_sdio_reg.h   |    62 +
 drivers/staging/rtlwifi/halmac/halmac_tx_bd_chip.h |   118 +
 drivers/staging/rtlwifi/halmac/halmac_tx_bd_nic.h  |   123 +
 .../staging/rtlwifi/halmac/halmac_tx_desc_chip.h   |   444 +
 .../staging/rtlwifi/halmac/halmac_tx_desc_nic.h    |   506 +
 drivers/staging/rtlwifi/halmac/halmac_type.h       |  1934 +++
 drivers/staging/rtlwifi/halmac/halmac_usb_reg.h    |    28 +
 drivers/staging/rtlwifi/halmac/rtl_halmac.c        |  1410 ++
 drivers/staging/rtlwifi/halmac/rtl_halmac.h        |    94 +
 drivers/staging/rtlwifi/pci.c                      |  2508 ++++
 drivers/staging/rtlwifi/pci.h                      |   329 +
 drivers/staging/rtlwifi/phydm/halphyrf_ce.c        |   965 ++
 drivers/staging/rtlwifi/phydm/halphyrf_ce.h        |    85 +
 drivers/staging/rtlwifi/phydm/mp_precomp.h         |    24 +
 drivers/staging/rtlwifi/phydm/phydm.c              |  1986 +++
 drivers/staging/rtlwifi/phydm/phydm.h              |   946 ++
 drivers/staging/rtlwifi/phydm/phydm_acs.c          |   200 +
 drivers/staging/rtlwifi/phydm/phydm_acs.h          |    57 +
 drivers/staging/rtlwifi/phydm/phydm_adaptivity.c   |   941 ++
 drivers/staging/rtlwifi/phydm/phydm_adaptivity.h   |   119 +
 drivers/staging/rtlwifi/phydm/phydm_adc_sampling.c |   628 +
 drivers/staging/rtlwifi/phydm/phydm_adc_sampling.h |    96 +
 drivers/staging/rtlwifi/phydm/phydm_antdiv.c       |    83 +
 drivers/staging/rtlwifi/phydm/phydm_antdiv.h       |   301 +
 drivers/staging/rtlwifi/phydm/phydm_beamforming.h  |    48 +
 drivers/staging/rtlwifi/phydm/phydm_ccx.c          |   457 +
 drivers/staging/rtlwifi/phydm/phydm_ccx.h          |    83 +
 drivers/staging/rtlwifi/phydm/phydm_cfotracking.c  |   343 +
 drivers/staging/rtlwifi/phydm/phydm_cfotracking.h  |    60 +
 drivers/staging/rtlwifi/phydm/phydm_debug.c        |  2910 ++++
 drivers/staging/rtlwifi/phydm/phydm_debug.h        |   175 +
 drivers/staging/rtlwifi/phydm/phydm_dfs.h          |    59 +
 drivers/staging/rtlwifi/phydm/phydm_dig.c          |  1535 +++
 drivers/staging/rtlwifi/phydm/phydm_dig.h          |   241 +
 .../staging/rtlwifi/phydm/phydm_dynamic_rx_path.h  |    37 +
 .../rtlwifi/phydm/phydm_dynamicbbpowersaving.c     |   129 +
 .../rtlwifi/phydm/phydm_dynamicbbpowersaving.h     |    50 +
 .../staging/rtlwifi/phydm/phydm_dynamictxpower.c   |   102 +
 .../staging/rtlwifi/phydm/phydm_dynamictxpower.h   |    64 +
 .../staging/rtlwifi/phydm/phydm_edcaturbocheck.c   |   139 +
 .../staging/rtlwifi/phydm/phydm_edcaturbocheck.h   |    44 +
 drivers/staging/rtlwifi/phydm/phydm_features.h     |    33 +
 drivers/staging/rtlwifi/phydm/phydm_hwconfig.c     |  1928 +++
 drivers/staging/rtlwifi/phydm/phydm_hwconfig.h     |   510 +
 drivers/staging/rtlwifi/phydm/phydm_interface.c    |   341 +
 drivers/staging/rtlwifi/phydm/phydm_interface.h    |   205 +
 drivers/staging/rtlwifi/phydm/phydm_iqk.h          |    76 +
 drivers/staging/rtlwifi/phydm/phydm_kfree.c        |   228 +
 drivers/staging/rtlwifi/phydm/phydm_kfree.h        |    42 +
 drivers/staging/rtlwifi/phydm/phydm_noisemonitor.c |   330 +
 drivers/staging/rtlwifi/phydm/phydm_noisemonitor.h |    46 +
 .../staging/rtlwifi/phydm/phydm_powertracking_ce.c |   644 +
 .../staging/rtlwifi/phydm/phydm_powertracking_ce.h |   293 +
 drivers/staging/rtlwifi/phydm/phydm_pre_define.h   |   613 +
 drivers/staging/rtlwifi/phydm/phydm_precomp.h      |    85 +
 drivers/staging/rtlwifi/phydm/phydm_psd.c          |   422 +
 drivers/staging/rtlwifi/phydm/phydm_psd.h          |    67 +
 drivers/staging/rtlwifi/phydm/phydm_rainfo.c       |  1208 ++
 drivers/staging/rtlwifi/phydm/phydm_rainfo.h       |   269 +
 drivers/staging/rtlwifi/phydm/phydm_reg.h          |   151 +
 .../staging/rtlwifi/phydm/phydm_regdefine11ac.h    |    94 +
 drivers/staging/rtlwifi/phydm/phydm_regdefine11n.h |   213 +
 drivers/staging/rtlwifi/phydm/phydm_types.h        |   130 +
 .../rtlwifi/phydm/rtl8822b/halhwimg8822b_bb.c      |  1969 +++
 .../rtlwifi/phydm/rtl8822b/halhwimg8822b_bb.h      |    54 +
 .../rtlwifi/phydm/rtl8822b/halhwimg8822b_mac.c     |   222 +
 .../rtlwifi/phydm/rtl8822b/halhwimg8822b_mac.h     |    38 +
 .../rtlwifi/phydm/rtl8822b/halhwimg8822b_rf.c      |  4744 +++++++
 .../rtlwifi/phydm/rtl8822b/halhwimg8822b_rf.h      |   129 +
 .../rtlwifi/phydm/rtl8822b/halphyrf_8822b.c        |   351 +
 .../rtlwifi/phydm/rtl8822b/halphyrf_8822b.h        |    45 +
 .../rtlwifi/phydm/rtl8822b/phydm_hal_api8822b.c    |  1815 +++
 .../rtlwifi/phydm/rtl8822b/phydm_hal_api8822b.h    |    84 +
 .../rtlwifi/phydm/rtl8822b/phydm_iqk_8822b.c       |  1410 ++
 .../rtlwifi/phydm/rtl8822b/phydm_iqk_8822b.h       |    48 +
 .../rtlwifi/phydm/rtl8822b/phydm_regconfig8822b.c  |   168 +
 .../rtlwifi/phydm/rtl8822b/phydm_regconfig8822b.h  |    54 +
 .../rtlwifi/phydm/rtl8822b/phydm_rtl8822b.c        |   225 +
 .../rtlwifi/phydm/rtl8822b/phydm_rtl8822b.h        |    30 +
 .../rtlwifi/phydm/rtl8822b/version_rtl8822b.h      |    34 +
 drivers/staging/rtlwifi/phydm/rtl_phydm.c          |   874 ++
 drivers/staging/rtlwifi/phydm/rtl_phydm.h          |    45 +
 drivers/staging/rtlwifi/phydm/txbf/halcomtxbf.h    |    67 +
 drivers/staging/rtlwifi/phydm/txbf/haltxbf8822b.h  |    39 +
 .../staging/rtlwifi/phydm/txbf/haltxbfinterface.h  |    38 +
 drivers/staging/rtlwifi/phydm/txbf/haltxbfjaguar.h |    36 +
 .../rtlwifi/phydm/txbf/phydm_hal_txbf_api.h        |    41 +
 drivers/staging/rtlwifi/ps.c                       |  1007 ++
 drivers/staging/rtlwifi/ps.h                       |    50 +
 drivers/staging/rtlwifi/pwrseqcmd.h                |    94 +
 drivers/staging/rtlwifi/rc.c                       |   322 +
 drivers/staging/rtlwifi/rc.h                       |    49 +
 drivers/staging/rtlwifi/regd.c                     |   469 +
 drivers/staging/rtlwifi/regd.h                     |    63 +
 drivers/staging/rtlwifi/rtl8822be/Makefile         |     7 +
 drivers/staging/rtlwifi/rtl8822be/def.h            |    82 +
 drivers/staging/rtlwifi/rtl8822be/fw.c             |   968 ++
 drivers/staging/rtlwifi/rtl8822be/fw.h             |   198 +
 drivers/staging/rtlwifi/rtl8822be/hw.c             |  2441 ++++
 drivers/staging/rtlwifi/rtl8822be/hw.h             |    66 +
 drivers/staging/rtlwifi/rtl8822be/led.c            |   127 +
 drivers/staging/rtlwifi/rtl8822be/led.h            |    34 +
 drivers/staging/rtlwifi/rtl8822be/phy.c            |  2233 +++
 drivers/staging/rtlwifi/rtl8822be/phy.h            |   145 +
 drivers/staging/rtlwifi/rtl8822be/reg.h            |  1653 +++
 drivers/staging/rtlwifi/rtl8822be/sw.c             |   481 +
 drivers/staging/rtlwifi/rtl8822be/sw.h             |    32 +
 drivers/staging/rtlwifi/rtl8822be/trx.c            |  1022 ++
 drivers/staging/rtlwifi/rtl8822be/trx.h            |   165 +
 drivers/staging/rtlwifi/stats.c                    |   260 +
 drivers/staging/rtlwifi/stats.h                    |    42 +
 drivers/staging/rtlwifi/wifi.h                     |  3375 +++++
 184 files changed, 125931 insertions(+)
 create mode 100644 drivers/staging/rtlwifi/Kconfig
 create mode 100644 drivers/staging/rtlwifi/Makefile
 create mode 100644 drivers/staging/rtlwifi/TODO
 create mode 100644 drivers/staging/rtlwifi/base.c
 create mode 100644 drivers/staging/rtlwifi/base.h
 create mode 100644 drivers/staging/rtlwifi/btcoexist/Makefile
 create mode 100644 drivers/staging/rtlwifi/btcoexist/halbt_precomp.h
 create mode 100644 drivers/staging/rtlwifi/btcoexist/halbtc8822b1ant.c
 create mode 100644 drivers/staging/rtlwifi/btcoexist/halbtc8822b1ant.h
 create mode 100644 drivers/staging/rtlwifi/btcoexist/halbtc8822b2ant.c
 create mode 100644 drivers/staging/rtlwifi/btcoexist/halbtc8822b2ant.h
 create mode 100644 drivers/staging/rtlwifi/btcoexist/halbtc8822bwifionly.c
 create mode 100644 drivers/staging/rtlwifi/btcoexist/halbtc8822bwifionly.h
 create mode 100644 drivers/staging/rtlwifi/btcoexist/halbtcoutsrc.c
 create mode 100644 drivers/staging/rtlwifi/btcoexist/halbtcoutsrc.h
 create mode 100644 drivers/staging/rtlwifi/btcoexist/rtl_btc.c
 create mode 100644 drivers/staging/rtlwifi/btcoexist/rtl_btc.h
 create mode 100644 drivers/staging/rtlwifi/cam.c
 create mode 100644 drivers/staging/rtlwifi/cam.h
 create mode 100644 drivers/staging/rtlwifi/core.c
 create mode 100644 drivers/staging/rtlwifi/core.h
 create mode 100644 drivers/staging/rtlwifi/debug.c
 create mode 100644 drivers/staging/rtlwifi/debug.h
 create mode 100644 drivers/staging/rtlwifi/efuse.c
 create mode 100644 drivers/staging/rtlwifi/efuse.h
 create mode 100644 drivers/staging/rtlwifi/halmac/halmac_2_platform.h
 create mode 100644 drivers/staging/rtlwifi/halmac/halmac_88xx/halmac_8822b/halmac_8822b_cfg.h
 create mode 100644 drivers/staging/rtlwifi/halmac/halmac_88xx/halmac_8822b/halmac_8822b_phy.c
 create mode 100644 drivers/staging/rtlwifi/halmac/halmac_88xx/halmac_8822b/halmac_8822b_pwr_seq.c
 create mode 100644 drivers/staging/rtlwifi/halmac/halmac_88xx/halmac_8822b/halmac_8822b_pwr_seq.h
 create mode 100644 drivers/staging/rtlwifi/halmac/halmac_88xx/halmac_8822b/halmac_api_8822b.c
 create mode 100644 drivers/staging/rtlwifi/halmac/halmac_88xx/halmac_8822b/halmac_api_8822b.h
 create mode 100644 drivers/staging/rtlwifi/halmac/halmac_88xx/halmac_8822b/halmac_api_8822b_pcie.c
 create mode 100644 drivers/staging/rtlwifi/halmac/halmac_88xx/halmac_8822b/halmac_api_8822b_pcie.h
 create mode 100644 drivers/staging/rtlwifi/halmac/halmac_88xx/halmac_8822b/halmac_api_8822b_sdio.c
 create mode 100644 drivers/staging/rtlwifi/halmac/halmac_88xx/halmac_8822b/halmac_api_8822b_sdio.h
 create mode 100644 drivers/staging/rtlwifi/halmac/halmac_88xx/halmac_8822b/halmac_api_8822b_usb.c
 create mode 100644 drivers/staging/rtlwifi/halmac/halmac_88xx/halmac_8822b/halmac_api_8822b_usb.h
 create mode 100644 drivers/staging/rtlwifi/halmac/halmac_88xx/halmac_8822b/halmac_func_8822b.c
 create mode 100644 drivers/staging/rtlwifi/halmac/halmac_88xx/halmac_8822b/halmac_func_8822b.h
 create mode 100644 drivers/staging/rtlwifi/halmac/halmac_88xx/halmac_88xx_cfg.h
 create mode 100644 drivers/staging/rtlwifi/halmac/halmac_88xx/halmac_api_88xx.c
 create mode 100644 drivers/staging/rtlwifi/halmac/halmac_88xx/halmac_api_88xx.h
 create mode 100644 drivers/staging/rtlwifi/halmac/halmac_88xx/halmac_api_88xx_pcie.c
 create mode 100644 drivers/staging/rtlwifi/halmac/halmac_88xx/halmac_api_88xx_pcie.h
 create mode 100644 drivers/staging/rtlwifi/halmac/halmac_88xx/halmac_api_88xx_sdio.c
 create mode 100644 drivers/staging/rtlwifi/halmac/halmac_88xx/halmac_api_88xx_sdio.h
 create mode 100644 drivers/staging/rtlwifi/halmac/halmac_88xx/halmac_api_88xx_usb.c
 create mode 100644 drivers/staging/rtlwifi/halmac/halmac_88xx/halmac_api_88xx_usb.h
 create mode 100644 drivers/staging/rtlwifi/halmac/halmac_88xx/halmac_func_88xx.c
 create mode 100644 drivers/staging/rtlwifi/halmac/halmac_88xx/halmac_func_88xx.h
 create mode 100644 drivers/staging/rtlwifi/halmac/halmac_api.c
 create mode 100644 drivers/staging/rtlwifi/halmac/halmac_api.h
 create mode 100644 drivers/staging/rtlwifi/halmac/halmac_bit2.h
 create mode 100644 drivers/staging/rtlwifi/halmac/halmac_bit_8822b.h
 create mode 100644 drivers/staging/rtlwifi/halmac/halmac_fw_info.h
 create mode 100644 drivers/staging/rtlwifi/halmac/halmac_fw_offload_c2h_nic.h
 create mode 100644 drivers/staging/rtlwifi/halmac/halmac_fw_offload_h2c_nic.h
 create mode 100644 drivers/staging/rtlwifi/halmac/halmac_h2c_extra_info_nic.h
 create mode 100644 drivers/staging/rtlwifi/halmac/halmac_intf_phy_cmd.h
 create mode 100644 drivers/staging/rtlwifi/halmac/halmac_original_c2h_nic.h
 create mode 100644 drivers/staging/rtlwifi/halmac/halmac_original_h2c_nic.h
 create mode 100644 drivers/staging/rtlwifi/halmac/halmac_pcie_reg.h
 create mode 100644 drivers/staging/rtlwifi/halmac/halmac_pwr_seq_cmd.h
 create mode 100644 drivers/staging/rtlwifi/halmac/halmac_reg2.h
 create mode 100644 drivers/staging/rtlwifi/halmac/halmac_reg_8822b.h
 create mode 100644 drivers/staging/rtlwifi/halmac/halmac_rx_bd_chip.h
 create mode 100644 drivers/staging/rtlwifi/halmac/halmac_rx_bd_nic.h
 create mode 100644 drivers/staging/rtlwifi/halmac/halmac_rx_desc_chip.h
 create mode 100644 drivers/staging/rtlwifi/halmac/halmac_rx_desc_nic.h
 create mode 100644 drivers/staging/rtlwifi/halmac/halmac_sdio_reg.h
 create mode 100644 drivers/staging/rtlwifi/halmac/halmac_tx_bd_chip.h
 create mode 100644 drivers/staging/rtlwifi/halmac/halmac_tx_bd_nic.h
 create mode 100644 drivers/staging/rtlwifi/halmac/halmac_tx_desc_chip.h
 create mode 100644 drivers/staging/rtlwifi/halmac/halmac_tx_desc_nic.h
 create mode 100644 drivers/staging/rtlwifi/halmac/halmac_type.h
 create mode 100644 drivers/staging/rtlwifi/halmac/halmac_usb_reg.h
 create mode 100644 drivers/staging/rtlwifi/halmac/rtl_halmac.c
 create mode 100644 drivers/staging/rtlwifi/halmac/rtl_halmac.h
 create mode 100644 drivers/staging/rtlwifi/pci.c
 create mode 100644 drivers/staging/rtlwifi/pci.h
 create mode 100644 drivers/staging/rtlwifi/phydm/halphyrf_ce.c
 create mode 100644 drivers/staging/rtlwifi/phydm/halphyrf_ce.h
 create mode 100644 drivers/staging/rtlwifi/phydm/mp_precomp.h
 create mode 100644 drivers/staging/rtlwifi/phydm/phydm.c
 create mode 100644 drivers/staging/rtlwifi/phydm/phydm.h
 create mode 100644 drivers/staging/rtlwifi/phydm/phydm_acs.c
 create mode 100644 drivers/staging/rtlwifi/phydm/phydm_acs.h
 create mode 100644 drivers/staging/rtlwifi/phydm/phydm_adaptivity.c
 create mode 100644 drivers/staging/rtlwifi/phydm/phydm_adaptivity.h
 create mode 100644 drivers/staging/rtlwifi/phydm/phydm_adc_sampling.c
 create mode 100644 drivers/staging/rtlwifi/phydm/phydm_adc_sampling.h
 create mode 100644 drivers/staging/rtlwifi/phydm/phydm_antdiv.c
 create mode 100644 drivers/staging/rtlwifi/phydm/phydm_antdiv.h
 create mode 100644 drivers/staging/rtlwifi/phydm/phydm_beamforming.h
 create mode 100644 drivers/staging/rtlwifi/phydm/phydm_ccx.c
 create mode 100644 drivers/staging/rtlwifi/phydm/phydm_ccx.h
 create mode 100644 drivers/staging/rtlwifi/phydm/phydm_cfotracking.c
 create mode 100644 drivers/staging/rtlwifi/phydm/phydm_cfotracking.h
 create mode 100644 drivers/staging/rtlwifi/phydm/phydm_debug.c
 create mode 100644 drivers/staging/rtlwifi/phydm/phydm_debug.h
 create mode 100644 drivers/staging/rtlwifi/phydm/phydm_dfs.h
 create mode 100644 drivers/staging/rtlwifi/phydm/phydm_dig.c
 create mode 100644 drivers/staging/rtlwifi/phydm/phydm_dig.h
 create mode 100644 drivers/staging/rtlwifi/phydm/phydm_dynamic_rx_path.h
 create mode 100644 drivers/staging/rtlwifi/phydm/phydm_dynamicbbpowersaving.c
 create mode 100644 drivers/staging/rtlwifi/phydm/phydm_dynamicbbpowersaving.h
 create mode 100644 drivers/staging/rtlwifi/phydm/phydm_dynamictxpower.c
 create mode 100644 drivers/staging/rtlwifi/phydm/phydm_dynamictxpower.h
 create mode 100644 drivers/staging/rtlwifi/phydm/phydm_edcaturbocheck.c
 create mode 100644 drivers/staging/rtlwifi/phydm/phydm_edcaturbocheck.h
 create mode 100644 drivers/staging/rtlwifi/phydm/phydm_features.h
 create mode 100644 drivers/staging/rtlwifi/phydm/phydm_hwconfig.c
 create mode 100644 drivers/staging/rtlwifi/phydm/phydm_hwconfig.h
 create mode 100644 drivers/staging/rtlwifi/phydm/phydm_interface.c
 create mode 100644 drivers/staging/rtlwifi/phydm/phydm_interface.h
 create mode 100644 drivers/staging/rtlwifi/phydm/phydm_iqk.h
 create mode 100644 drivers/staging/rtlwifi/phydm/phydm_kfree.c
 create mode 100644 drivers/staging/rtlwifi/phydm/phydm_kfree.h
 create mode 100644 drivers/staging/rtlwifi/phydm/phydm_noisemonitor.c
 create mode 100644 drivers/staging/rtlwifi/phydm/phydm_noisemonitor.h
 create mode 100644 drivers/staging/rtlwifi/phydm/phydm_powertracking_ce.c
 create mode 100644 drivers/staging/rtlwifi/phydm/phydm_powertracking_ce.h
 create mode 100644 drivers/staging/rtlwifi/phydm/phydm_pre_define.h
 create mode 100644 drivers/staging/rtlwifi/phydm/phydm_precomp.h
 create mode 100644 drivers/staging/rtlwifi/phydm/phydm_psd.c
 create mode 100644 drivers/staging/rtlwifi/phydm/phydm_psd.h
 create mode 100644 drivers/staging/rtlwifi/phydm/phydm_rainfo.c
 create mode 100644 drivers/staging/rtlwifi/phydm/phydm_rainfo.h
 create mode 100644 drivers/staging/rtlwifi/phydm/phydm_reg.h
 create mode 100644 drivers/staging/rtlwifi/phydm/phydm_regdefine11ac.h
 create mode 100644 drivers/staging/rtlwifi/phydm/phydm_regdefine11n.h
 create mode 100644 drivers/staging/rtlwifi/phydm/phydm_types.h
 create mode 100644 drivers/staging/rtlwifi/phydm/rtl8822b/halhwimg8822b_bb.c
 create mode 100644 drivers/staging/rtlwifi/phydm/rtl8822b/halhwimg8822b_bb.h
 create mode 100644 drivers/staging/rtlwifi/phydm/rtl8822b/halhwimg8822b_mac.c
 create mode 100644 drivers/staging/rtlwifi/phydm/rtl8822b/halhwimg8822b_mac.h
 create mode 100644 drivers/staging/rtlwifi/phydm/rtl8822b/halhwimg8822b_rf.c
 create mode 100644 drivers/staging/rtlwifi/phydm/rtl8822b/halhwimg8822b_rf.h
 create mode 100644 drivers/staging/rtlwifi/phydm/rtl8822b/halphyrf_8822b.c
 create mode 100644 drivers/staging/rtlwifi/phydm/rtl8822b/halphyrf_8822b.h
 create mode 100644 drivers/staging/rtlwifi/phydm/rtl8822b/phydm_hal_api8822b.c
 create mode 100644 drivers/staging/rtlwifi/phydm/rtl8822b/phydm_hal_api8822b.h
 create mode 100644 drivers/staging/rtlwifi/phydm/rtl8822b/phydm_iqk_8822b.c
 create mode 100644 drivers/staging/rtlwifi/phydm/rtl8822b/phydm_iqk_8822b.h
 create mode 100644 drivers/staging/rtlwifi/phydm/rtl8822b/phydm_regconfig8822b.c
 create mode 100644 drivers/staging/rtlwifi/phydm/rtl8822b/phydm_regconfig8822b.h
 create mode 100644 drivers/staging/rtlwifi/phydm/rtl8822b/phydm_rtl8822b.c
 create mode 100644 drivers/staging/rtlwifi/phydm/rtl8822b/phydm_rtl8822b.h
 create mode 100644 drivers/staging/rtlwifi/phydm/rtl8822b/version_rtl8822b.h
 create mode 100644 drivers/staging/rtlwifi/phydm/rtl_phydm.c
 create mode 100644 drivers/staging/rtlwifi/phydm/rtl_phydm.h
 create mode 100644 drivers/staging/rtlwifi/phydm/txbf/halcomtxbf.h
 create mode 100644 drivers/staging/rtlwifi/phydm/txbf/haltxbf8822b.h
 create mode 100644 drivers/staging/rtlwifi/phydm/txbf/haltxbfinterface.h
 create mode 100644 drivers/staging/rtlwifi/phydm/txbf/haltxbfjaguar.h
 create mode 100644 drivers/staging/rtlwifi/phydm/txbf/phydm_hal_txbf_api.h
 create mode 100644 drivers/staging/rtlwifi/ps.c
 create mode 100644 drivers/staging/rtlwifi/ps.h
 create mode 100644 drivers/staging/rtlwifi/pwrseqcmd.h
 create mode 100644 drivers/staging/rtlwifi/rc.c
 create mode 100644 drivers/staging/rtlwifi/rc.h
 create mode 100644 drivers/staging/rtlwifi/regd.c
 create mode 100644 drivers/staging/rtlwifi/regd.h
 create mode 100644 drivers/staging/rtlwifi/rtl8822be/Makefile
 create mode 100644 drivers/staging/rtlwifi/rtl8822be/def.h
 create mode 100644 drivers/staging/rtlwifi/rtl8822be/fw.c
 create mode 100644 drivers/staging/rtlwifi/rtl8822be/fw.h
 create mode 100644 drivers/staging/rtlwifi/rtl8822be/hw.c
 create mode 100644 drivers/staging/rtlwifi/rtl8822be/hw.h
 create mode 100644 drivers/staging/rtlwifi/rtl8822be/led.c
 create mode 100644 drivers/staging/rtlwifi/rtl8822be/led.h
 create mode 100644 drivers/staging/rtlwifi/rtl8822be/phy.c
 create mode 100644 drivers/staging/rtlwifi/rtl8822be/phy.h
 create mode 100644 drivers/staging/rtlwifi/rtl8822be/reg.h
 create mode 100644 drivers/staging/rtlwifi/rtl8822be/sw.c
 create mode 100644 drivers/staging/rtlwifi/rtl8822be/sw.h
 create mode 100644 drivers/staging/rtlwifi/rtl8822be/trx.c
 create mode 100644 drivers/staging/rtlwifi/rtl8822be/trx.h
 create mode 100644 drivers/staging/rtlwifi/stats.c
 create mode 100644 drivers/staging/rtlwifi/stats.h
 create mode 100644 drivers/staging/rtlwifi/wifi.h

-- 
2.12.3
