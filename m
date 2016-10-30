From: Nicholas Mc Guire <der.herr@hofr.at>
Subject: RFC if==else in halbtc8723b1ant.c
Date: Sun, 30 Oct 2016 11:03:12 +0000
Message-ID: <20161030110312.GA26326@osadl.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi !

 in your commit f5b586909581 ("rtlwifi: btcoexist: Modify driver to support 
 BT coexistence in rtl8723be") you introduced a if/else where both branches 
 are the same but the comment in the else branch suggests that this might be
 unintended.

 from code review only I can´t say what the intent is.

/drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtc8723b1ant.c:halbtc8723b1ant_action_wifi_connected_bt_acl_busy()

1838                 if ((bt_rssi_state == BTC_RSSI_STATE_HIGH) ||
1839                     (bt_rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
1840                         halbtc8723b1ant_ps_tdma(btcoexist, NORMAL_EXEC,
1841                                                 true, 14);
1842                         coex_dm->auto_tdma_adjust = false;
1843                 } else { /*for low BT RSSI*/
1844                         halbtc8723b1ant_ps_tdma(btcoexist, NORMAL_EXEC,
1845                                                 true, 14);
1846                         coex_dm->auto_tdma_adjust = false;
1847                 }

  basically the same construct is also in 
 halbtc8723b1ant_run_coexist_mechanism()

2213                         if ((wifi_rssi_state == BTC_RSSI_STATE_HIGH) ||
2214                             (wifi_rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
2215                                 halbtc8723b1ant_limited_tx(btcoexist,
2216                                                            NORMAL_EXEC,
2217                                                            1, 1, 1, 1);
2218                         } else {
2219                                 halbtc8723b1ant_limited_tx(btcoexist,
2220                                                            NORMAL_EXEC,
2221                                                            1, 1, 1, 1);
2222                         }

 where the if condition is the same so the else may also only apply to the
 low BT RSSI - and the if and else are again the same - if this is intended
 or not is not clear. If this is intended it should have appropriate comments.

thx!
hofrat
