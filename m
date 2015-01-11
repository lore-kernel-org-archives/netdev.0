From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Subject: Re: [PATCH 1/3] rtlwifi: btcoexist: Remove some unused functions
Date: Sun, 11 Jan 2015 12:56:06 +0100
Message-ID: <CAKXHbyPga1M=amuAvmZpFjvqCbO-heOOLn6hpfwMBpGJuZO2Mg@mail.gmail.com>
References: <1420907079-27102-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
	<54B15D57.5060709@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Kalle Valo <kvalo@adurom.com>,
	Masanari Iida <standby24x7@gmail.com>,
	Sachin Kamat <sachin.kamat@linaro.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54B15D57.5060709@lwfinger.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2015-01-10 18:11 GMT+01:00 Larry Finger <Larry.Finger@lwfinger.net>:
> On 01/10/2015 10:24 AM, Rickard Strandqvist wrote:
>>
>> Removes some functions that are not used anywhere:
>> ex_halbtc8821a1ant_periodical() ex_halbtc8821a1ant_pnp_notify()
>> ex_halbtc8821a1ant_halt_notify() ex_halbtc8821a1ant_bt_info_notify()
>> ex_halbtc8821a1ant_special_packet_notify()
>> ex_halbtc8821a1ant_connect_notify()
>> ex_halbtc8821a1ant_scan_notify() ex_halbtc8821a1ant_lps_notify()
>> ex_halbtc8821a1ant_ips_notify() ex_halbtc8821a1ant_display_coex_info()
>> ex_halbtc8821a1ant_init_coex_dm() ex_halbtc8821a1ant_init_hwconfig()
>>
>> This was partially found by using a static code analysis program called
>> cppcheck.
>>
>> Signed-off-by: Rickard Strandqvist
>> <rickard_strandqvist@spectrumdigital.se>
>
>
> NACK!!!!!!!!!
>
> I told you to stay away from these routines until I finish my update. Not
> only might you remove some functions that I will be needing later, but you
> run the risk of merge complications.
>
> Kalle: Please ignore EVERYTHING from this person. Obviously, he is incapable
> of understanding even the simplest instructions.
>
> Larry
>
>
>> ---
>>   .../wireless/rtlwifi/btcoexist/halbtc8821a1ant.c   |  707
>> --------------------
>>   .../wireless/rtlwifi/btcoexist/halbtc8821a1ant.h   |   14 -
>>   2 files changed, 721 deletions(-)
>>
>> diff --git a/drivers/net/wireless/rtlwifi/btcoexist/halbtc8821a1ant.c
>> b/drivers/net/wireless/rtlwifi/btcoexist/halbtc8821a1ant.c
>> index b72e537..a86e6b6 100644
>> --- a/drivers/net/wireless/rtlwifi/btcoexist/halbtc8821a1ant.c
>> +++ b/drivers/net/wireless/rtlwifi/btcoexist/halbtc8821a1ant.c
>> @@ -2213,435 +2213,6 @@ static void halbtc8821a1ant_init_hw_config(struct
>> btc_coexist *btcoexist,
>>   /*============================================================*/
>>   /* extern function start with EXhalbtc8821a1ant_*/
>>   /*============================================================*/
>> -void ex_halbtc8821a1ant_init_hwconfig(struct btc_coexist *btcoexist)
>> -{
>> -       halbtc8821a1ant_init_hw_config(btcoexist, true);
>> -}
>> -
>> -void ex_halbtc8821a1ant_init_coex_dm(struct btc_coexist *btcoexist)
>> -{
>> -       BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
>> -                 "[BTCoex], Coex Mechanism Init!!\n");
>> -
>> -       btcoexist->stop_coex_dm = false;
>> -
>> -       halbtc8821a1ant_init_coex_dm(btcoexist);
>> -
>> -       halbtc8821a1ant_query_bt_info(btcoexist);
>> -}
>> -
>> -void ex_halbtc8821a1ant_display_coex_info(struct btc_coexist *btcoexist)
>> -{
>> -       struct btc_board_info *board_info = &btcoexist->board_info;
>> -       struct btc_stack_info *stack_info = &btcoexist->stack_info;
>> -       struct btc_bt_link_info *bt_link_info = &btcoexist->bt_link_info;
>> -       struct rtl_priv *rtlpriv = btcoexist->adapter;
>> -       u8 u1_tmp[4], i, bt_info_ext, ps_tdma_case = 0;
>> -       u16 u2_tmp[4];
>> -       u32 u4_tmp[4];
>> -       bool roam = false, scan = false, link = false, wifi_under_5g =
>> false;
>> -       bool bt_hs_on = false, wifi_busy = false;
>> -       long wifi_rssi = 0, bt_hs_rssi = 0;
>> -       u32 wifi_bw, wifi_traffic_dir;
>> -       u8 wifi_dot11_chnl, wifi_hs_chnl;
>> -       u32 fw_ver = 0, bt_patch_ver = 0;
>> -
>> -       RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
>> -                  "\r\n ============[BT Coexist info]============");
>> -
>> -       if (btcoexist->manual_control) {
>> -               RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
>> -                          "\r\n ============[Under Manual
>> Control]============");
>> -               RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
>> -                          "\r\n
>> ==========================================");
>> -       }
>> -       if (btcoexist->stop_coex_dm) {
>> -               RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
>> -                          "\r\n ============[Coex is
>> STOPPED]============");
>> -               RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
>> -                          "\r\n
>> ==========================================");
>> -       }
>> -
>> -       if (!board_info->bt_exist) {
>> -               RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n BT not
>> exists !!!");
>> -               return;
>> -       }
>> -
>> -       RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
>> -                  "\r\n %-35s = %d/ %d/ %d",
>> -                  "Ant PG Num/ Ant Mech/ Ant Pos:",
>> -                  board_info->pg_ant_num,
>> -                  board_info->btdm_ant_num,
>> -                  board_info->btdm_ant_pos);
>> -
>> -       RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
>> -                  "\r\n %-35s = %s / %d", "BT stack/ hci ext ver",
>> -                  ((stack_info->profile_notified) ? "Yes" : "No"),
>> -               stack_info->hci_version);
>> -
>> -       btcoexist->btc_get(btcoexist, BTC_GET_U4_BT_PATCH_VER,
>> -                          &bt_patch_ver);
>> -       btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_FW_VER, &fw_ver);
>> -       RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
>> -                  "\r\n %-35s = %d_%x/ 0x%x/ 0x%x(%d)",
>> -                  "CoexVer/ FwVer/ PatchVer",
>> -                  glcoex_ver_date_8821a_1ant,
>> -                  glcoex_ver_8821a_1ant,
>> -                  fw_ver, bt_patch_ver,
>> -                  bt_patch_ver);
>> -
>> -       btcoexist->btc_get(btcoexist, BTC_GET_BL_HS_OPERATION,
>> -                          &bt_hs_on);
>> -       btcoexist->btc_get(btcoexist, BTC_GET_U1_WIFI_DOT11_CHNL,
>> -                          &wifi_dot11_chnl);
>> -       btcoexist->btc_get(btcoexist, BTC_GET_U1_WIFI_HS_CHNL,
>> -                          &wifi_hs_chnl);
>> -       RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
>> -                  "\r\n %-35s = %d / %d(%d)",
>> -                  "Dot11 channel / HsChnl(HsMode)",
>> -                  wifi_dot11_chnl, wifi_hs_chnl, bt_hs_on);
>> -
>> -       RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
>> -                  "\r\n %-35s = %02x %02x %02x ",
>> -                  "H2C Wifi inform bt chnl Info",
>> -                  coex_dm->wifi_chnl_info[0], coex_dm->wifi_chnl_info[1],
>> -                  coex_dm->wifi_chnl_info[2]);
>> -
>> -       btcoexist->btc_get(btcoexist, BTC_GET_S4_WIFI_RSSI, &wifi_rssi);
>> -       btcoexist->btc_get(btcoexist, BTC_GET_S4_HS_RSSI, &bt_hs_rssi);
>> -       RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
>> -                  "\r\n %-35s = %d/ %d", "Wifi rssi/ HS rssi",
>> -                  (int)wifi_rssi, (int)bt_hs_rssi);
>> -
>> -       btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_SCAN, &scan);
>> -       btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_LINK, &link);
>> -       btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_ROAM, &roam);
>> -       RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
>> -                  "\r\n %-35s = %d/ %d/ %d ", "Wifi link/ roam/ scan",
>> -                  link, roam, scan);
>> -
>> -       btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_UNDER_5G,
>> -                          &wifi_under_5g);
>> -       btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_BW,
>> -                          &wifi_bw);
>> -       btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_BUSY,
>> -                          &wifi_busy);
>> -       btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_TRAFFIC_DIRECTION,
>> -                          &wifi_traffic_dir);
>> -       RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
>> -                  "\r\n %-35s = %s / %s/ %s ", "Wifi status",
>> -                  (wifi_under_5g ? "5G" : "2.4G"),
>> -                  ((BTC_WIFI_BW_LEGACY == wifi_bw) ? "Legacy" :
>> -                  (((BTC_WIFI_BW_HT40 == wifi_bw) ? "HT40" : "HT20"))),
>> -                  ((!wifi_busy) ? "idle" :
>> -                  ((BTC_WIFI_TRAFFIC_TX == wifi_traffic_dir) ?
>> -                  "uplink" : "downlink")));
>> -       RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
>> -                  "\r\n %-35s = [%s/ %d/ %d] ", "BT [status/ rssi/
>> retryCnt]",
>> -                  ((btcoexist->bt_info.bt_disabled) ? ("disabled") :
>> -                  ((coex_sta->c2h_bt_inquiry_page) ? ("inquiry/page
>> scan") :
>> -                  ((BT_8821A_1ANT_BT_STATUS_NON_CONNECTED_IDLE ==
>> -                    coex_dm->bt_status) ?
>> -                  "non-connected idle" :
>> -                  ((BT_8821A_1ANT_BT_STATUS_CONNECTED_IDLE ==
>> -                    coex_dm->bt_status) ?
>> -                  "connected-idle" : "busy")))),
>> -                  coex_sta->bt_rssi, coex_sta->bt_retry_cnt);
>> -
>> -       RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
>> -                  "\r\n %-35s = %d / %d / %d / %d", "SCO/HID/PAN/A2DP",
>> -                  bt_link_info->sco_exist,
>> -                  bt_link_info->hid_exist,
>> -                  bt_link_info->pan_exist,
>> -                  bt_link_info->a2dp_exist);
>> -       btcoexist->btc_disp_dbg_msg(btcoexist, BTC_DBG_DISP_BT_LINK_INFO);
>> -
>> -       bt_info_ext = coex_sta->bt_info_ext;
>> -       RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
>> -                  "\r\n %-35s = %s",
>> -                  "BT Info A2DP rate",
>> -                  (bt_info_ext&BIT0) ?
>> -                  "Basic rate" : "EDR rate");
>> -
>> -       for (i = 0; i < BT_INFO_SRC_8821A_1ANT_MAX; i++) {
>> -               if (coex_sta->bt_info_c2h_cnt[i]) {
>> -                       RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
>> -                                  "\r\n %-35s = %02x %02x %02x %02x %02x
>> %02x %02x(%d)",
>> -                                  glbt_info_src_8821a_1ant[i],
>> -                                  coex_sta->bt_info_c2h[i][0],
>> -                                  coex_sta->bt_info_c2h[i][1],
>> -                                  coex_sta->bt_info_c2h[i][2],
>> -                                  coex_sta->bt_info_c2h[i][3],
>> -                                  coex_sta->bt_info_c2h[i][4],
>> -                                  coex_sta->bt_info_c2h[i][5],
>> -                                  coex_sta->bt_info_c2h[i][6],
>> -                                  coex_sta->bt_info_c2h_cnt[i]);
>> -               }
>> -       }
>> -       RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
>> -                  "\r\n %-35s = %s/%s, (0x%x/0x%x)",
>> -                  "PS state, IPS/LPS, (lps/rpwm)",
>> -                  ((coex_sta->under_ips ? "IPS ON" : "IPS OFF")),
>> -                  ((coex_sta->under_Lps ? "LPS ON" : "LPS OFF")),
>> -                  btcoexist->bt_info.lps_val,
>> -                  btcoexist->bt_info.rpwm_val);
>> -       btcoexist->btc_disp_dbg_msg(btcoexist,
>> BTC_DBG_DISP_FW_PWR_MODE_CMD);
>> -
>> -       if (!btcoexist->manual_control) {
>> -               /* Sw mechanism*/
>> -               RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
>> -                          "\r\n %-35s", "============[Sw
>> mechanism]============");
>> -
>> -               RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
>> -                          "\r\n %-35s = %d", "SM[LowPenaltyRA]",
>> -                          coex_dm->cur_low_penalty_ra);
>> -
>> -               RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
>> -                          "\r\n %-35s = %s/ %s/ %d ",
>> -                          "DelBA/ BtCtrlAgg/ AggSize",
>> -                          (btcoexist->bt_info.reject_agg_pkt ? "Yes" :
>> "No"),
>> -                          (btcoexist->bt_info.bt_ctrl_buf_size ? "Yes" :
>> "No"),
>> -                          btcoexist->bt_info.agg_buf_size);
>> -               RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
>> -                          "\r\n %-35s = 0x%x ", "Rate Mask",
>> -                          btcoexist->bt_info.ra_mask);
>> -
>> -               /* Fw mechanism*/
>> -               RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s",
>> -                          "============[Fw mechanism]============");
>> -
>> -               ps_tdma_case = coex_dm->cur_ps_tdma;
>> -               RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
>> -                          "\r\n %-35s = %02x %02x %02x %02x %02x case-%d
>> (auto:%d)",
>> -                          "PS TDMA",
>> -                          coex_dm->ps_tdma_para[0],
>> -                          coex_dm->ps_tdma_para[1],
>> -                          coex_dm->ps_tdma_para[2],
>> -                          coex_dm->ps_tdma_para[3],
>> -                          coex_dm->ps_tdma_para[4],
>> -                          ps_tdma_case,
>> -                          coex_dm->auto_tdma_adjust);
>> -
>> -               RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
>> -                          "\r\n %-35s = 0x%x ",
>> -                          "Latest error condition(should be 0)",
>> -                          coex_dm->error_condition);
>> -
>> -               RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
>> -                          "\r\n %-35s = %d ", "IgnWlanAct",
>> -                          coex_dm->cur_ignore_wlan_act);
>> -       }
>> -
>> -       /* Hw setting*/
>> -       RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
>> -                  "\r\n %-35s", "============[Hw setting]============");
>> -
>> -       RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
>> -                  "\r\n %-35s = 0x%x/0x%x/0x%x/0x%x",
>> -                  "backup ARFR1/ARFR2/RL/AMaxTime",
>> -                  coex_dm->backup_arfr_cnt1,
>> -                  coex_dm->backup_arfr_cnt2,
>> -                  coex_dm->backup_retry_limit,
>> -                  coex_dm->backup_ampdu_max_time);
>> -
>> -       u4_tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0x430);
>> -       u4_tmp[1] = btcoexist->btc_read_4byte(btcoexist, 0x434);
>> -       u2_tmp[0] = btcoexist->btc_read_2byte(btcoexist, 0x42a);
>> -       u1_tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x456);
>> -       RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
>> -                  "\r\n %-35s = 0x%x/0x%x/0x%x/0x%x",
>> -                  "0x430/0x434/0x42a/0x456",
>> -                  u4_tmp[0], u4_tmp[1], u2_tmp[0], u1_tmp[0]);
>> -
>> -       u1_tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x778);
>> -       u4_tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0xc58);
>> -       RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
>> -                  "\r\n %-35s = 0x%x/ 0x%x", "0x778/ 0xc58[29:25]",
>> -                  u1_tmp[0], (u4_tmp[0]&0x3e000000) >> 25);
>> -
>> -       u1_tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x8db);
>> -       RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
>> -                  "\r\n %-35s = 0x%x", "0x8db[6:5]",
>> -                  ((u1_tmp[0]&0x60)>>5));
>> -
>> -       u1_tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x975);
>> -       u4_tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0xcb4);
>> -       RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
>> -                  "\r\n %-35s = 0x%x/ 0x%x/ 0x%x",
>> -                  "0xcb4[29:28]/0xcb4[7:0]/0x974[9:8]",
>> -                  (u4_tmp[0] & 0x30000000)>>28,
>> -                   u4_tmp[0] & 0xff,
>> -                   u1_tmp[0] & 0x3);
>> -
>> -       u1_tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x40);
>> -       u4_tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0x4c);
>> -       u1_tmp[1] = btcoexist->btc_read_1byte(btcoexist, 0x64);
>> -       RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
>> -                  "\r\n %-35s = 0x%x/ 0x%x/ 0x%x",
>> -                  "0x40/0x4c[24:23]/0x64[0]",
>> -                  u1_tmp[0], ((u4_tmp[0]&0x01800000)>>23),
>> u1_tmp[1]&0x1);
>> -
>> -       u4_tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0x550);
>> -       u1_tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x522);
>> -       RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
>> -                  "\r\n %-35s = 0x%x/ 0x%x", "0x550(bcn ctrl)/0x522",
>> -                  u4_tmp[0], u1_tmp[0]);
>> -
>> -       u4_tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0xc50);
>> -       RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
>> -                  "\r\n %-35s = 0x%x", "0xc50(dig)",
>> -                  u4_tmp[0]&0xff);
>> -
>> -       u4_tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0xf48);
>> -       u1_tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0xa5d);
>> -       u1_tmp[1] = btcoexist->btc_read_1byte(btcoexist, 0xa5c);
>> -       RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
>> -                  "\r\n %-35s = 0x%x/ 0x%x", "OFDM-FA/ CCK-FA",
>> -                  u4_tmp[0], (u1_tmp[0]<<8) + u1_tmp[1]);
>> -
>> -       u4_tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0x6c0);
>> -       u4_tmp[1] = btcoexist->btc_read_4byte(btcoexist, 0x6c4);
>> -       u4_tmp[2] = btcoexist->btc_read_4byte(btcoexist, 0x6c8);
>> -       u1_tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x6cc);
>> -       RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
>> -                  "\r\n %-35s = 0x%x/ 0x%x/ 0x%x/ 0x%x",
>> -                  "0x6c0/0x6c4/0x6c8/0x6cc(coexTable)",
>> -                  u4_tmp[0], u4_tmp[1], u4_tmp[2], u1_tmp[0]);
>> -
>> -       RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
>> -                  "\r\n %-35s = %d/ %d", "0x770(high-pri rx/tx)",
>> -                  coex_sta->high_priority_rx,
>> coex_sta->high_priority_tx);
>> -       RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
>> -                  "\r\n %-35s = %d/ %d", "0x774(low-pri rx/tx)",
>> -                  coex_sta->low_priority_rx, coex_sta->low_priority_tx);
>> -#if (BT_AUTO_REPORT_ONLY_8821A_1ANT == 1)
>> -       halbtc8821a1ant_monitor_bt_ctr(btcoexist);
>> -#endif
>> -       btcoexist->btc_disp_dbg_msg(btcoexist,
>> BTC_DBG_DISP_COEX_STATISTICS);
>> -}
>> -
>> -void ex_halbtc8821a1ant_ips_notify(struct btc_coexist *btcoexist, u8
>> type)
>> -{
>> -       if (btcoexist->manual_control || btcoexist->stop_coex_dm)
>> -               return;
>> -
>> -       if (BTC_IPS_ENTER == type) {
>> -               BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
>> -                         "[BTCoex], IPS ENTER notify\n");
>> -               coex_sta->under_ips = true;
>> -               halbtc8821a1ant_set_ant_path(btcoexist,
>> -                                            BTC_ANT_PATH_BT, false,
>> true);
>> -               /*set PTA control*/
>> -               halbtc8821a1ant_ps_tdma(btcoexist, NORMAL_EXEC, false, 8);
>> -               halbtc8821a1ant_coex_table_with_type(btcoexist,
>> -                                                    NORMAL_EXEC, 0);
>> -       } else if (BTC_IPS_LEAVE == type) {
>> -               BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
>> -                         "[BTCoex], IPS LEAVE notify\n");
>> -               coex_sta->under_ips = false;
>> -
>> -               halbtc8821a1ant_run_coexist_mechanism(btcoexist);
>> -       }
>> -}
>> -
>> -void ex_halbtc8821a1ant_lps_notify(struct btc_coexist *btcoexist, u8
>> type)
>> -{
>> -       if (btcoexist->manual_control || btcoexist->stop_coex_dm)
>> -               return;
>> -
>> -       if (BTC_LPS_ENABLE == type) {
>> -               BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
>> -                         "[BTCoex], LPS ENABLE notify\n");
>> -               coex_sta->under_Lps = true;
>> -       } else if (BTC_LPS_DISABLE == type) {
>> -               BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
>> -                         "[BTCoex], LPS DISABLE notify\n");
>> -               coex_sta->under_Lps = false;
>> -       }
>> -}
>> -
>> -void ex_halbtc8821a1ant_scan_notify(struct btc_coexist *btcoexist, u8
>> type)
>> -{
>> -       bool wifi_connected = false, bt_hs_on = false;
>> -
>> -       if (btcoexist->manual_control ||
>> -           btcoexist->stop_coex_dm ||
>> -           btcoexist->bt_info.bt_disabled)
>> -               return;
>> -
>> -       btcoexist->btc_get(btcoexist,
>> -                BTC_GET_BL_HS_OPERATION, &bt_hs_on);
>> -       btcoexist->btc_get(btcoexist,
>> -                BTC_GET_BL_WIFI_CONNECTED, &wifi_connected);
>> -
>> -       halbtc8821a1ant_query_bt_info(btcoexist);
>> -
>> -       if (coex_sta->c2h_bt_inquiry_page) {
>> -               halbtc8821a1ant_action_bt_inquiry(btcoexist);
>> -               return;
>> -       } else if (bt_hs_on) {
>> -               halbtc8821a1ant_action_hs(btcoexist);
>> -               return;
>> -       }
>> -
>> -       if (BTC_SCAN_START == type) {
>> -               BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
>> -                         "[BTCoex], SCAN START notify\n");
>> -               if (!wifi_connected) {
>> -                       /* non-connected scan*/
>> -                       btc8821a1ant_act_wifi_not_conn_scan(btcoexist);
>> -               } else {
>> -                       /* wifi is connected*/
>> -
>> halbtc8821a1ant_action_wifi_connected_scan(btcoexist);
>> -               }
>> -       } else if (BTC_SCAN_FINISH == type) {
>> -               BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
>> -                         "[BTCoex], SCAN FINISH notify\n");
>> -               if (!wifi_connected) {
>> -                       /* non-connected scan*/
>> -
>> halbtc8821a1ant_action_wifi_not_connected(btcoexist);
>> -               } else {
>> -                       halbtc8821a1ant_action_wifi_connected(btcoexist);
>> -               }
>> -       }
>> -}
>> -
>> -void ex_halbtc8821a1ant_connect_notify(struct btc_coexist *btcoexist, u8
>> type)
>> -{
>> -       bool    wifi_connected = false, bt_hs_on = false;
>> -
>> -       if (btcoexist->manual_control ||
>> -           btcoexist->stop_coex_dm ||
>> -           btcoexist->bt_info.bt_disabled)
>> -               return;
>> -
>> -       btcoexist->btc_get(btcoexist, BTC_GET_BL_HS_OPERATION, &bt_hs_on);
>> -       if (coex_sta->c2h_bt_inquiry_page) {
>> -               halbtc8821a1ant_action_bt_inquiry(btcoexist);
>> -               return;
>> -       } else if (bt_hs_on) {
>> -               halbtc8821a1ant_action_hs(btcoexist);
>> -               return;
>> -       }
>> -
>> -       if (BTC_ASSOCIATE_START == type) {
>> -               BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
>> -                         "[BTCoex], CONNECT START notify\n");
>> -               btc8821a1ant_act_wifi_not_conn_scan(btcoexist);
>> -       } else if (BTC_ASSOCIATE_FINISH == type) {
>> -               BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
>> -                         "[BTCoex], CONNECT FINISH notify\n");
>> -
>> -               btcoexist->btc_get(btcoexist,
>> -                        BTC_GET_BL_WIFI_CONNECTED, &wifi_connected);
>> -               if (!wifi_connected) {
>> -                       /* non-connected scan*/
>> -
>> halbtc8821a1ant_action_wifi_not_connected(btcoexist);
>> -               } else {
>> -                       halbtc8821a1ant_action_wifi_connected(btcoexist);
>> -               }
>> -       }
>> -}
>>
>>   void ex_halbtc8821a1ant_media_status_notify(struct btc_coexist
>> *btcoexist,
>>                                             u8 type)
>> @@ -2690,281 +2261,3 @@ void ex_halbtc8821a1ant_media_status_notify(struct
>> btc_coexist *btcoexist,
>>         btcoexist->btc_fill_h2c(btcoexist, 0x66, 3, h2c_parameter);
>>   }
>>
>> -void ex_halbtc8821a1ant_special_packet_notify(struct btc_coexist
>> *btcoexist,
>> -                                             u8 type)
>> -{
>> -       bool bt_hs_on = false;
>> -
>> -       if (btcoexist->manual_control ||
>> -           btcoexist->stop_coex_dm ||
>> -           btcoexist->bt_info.bt_disabled)
>> -               return;
>> -
>> -       coex_sta->special_pkt_period_cnt = 0;
>> -
>> -       btcoexist->btc_get(btcoexist, BTC_GET_BL_HS_OPERATION, &bt_hs_on);
>> -       if (coex_sta->c2h_bt_inquiry_page) {
>> -               halbtc8821a1ant_action_bt_inquiry(btcoexist);
>> -               return;
>> -       } else if (bt_hs_on) {
>> -               halbtc8821a1ant_action_hs(btcoexist);
>> -               return;
>> -       }
>> -
>> -       if (BTC_PACKET_DHCP == type ||
>> -           BTC_PACKET_EAPOL == type) {
>> -               BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
>> -                         "[BTCoex], special Packet(%d) notify\n", type);
>> -               btc8821a1ant_act_wifi_conn_sp_pkt(btcoexist);
>> -       }
>> -}
>> -
>> -void ex_halbtc8821a1ant_bt_info_notify(struct btc_coexist *btcoexist,
>> -                                      u8 *tmp_buf, u8 length)
>> -{
>> -       u8 bt_info = 0;
>> -       u8 i, rsp_source = 0;
>> -       bool wifi_connected = false;
>> -       bool bt_busy = false;
>> -       bool wifi_under_5g = false;
>> -
>> -       coex_sta->c2h_bt_info_req_sent = false;
>> -
>> -       btcoexist->btc_get(btcoexist,
>> -                BTC_GET_BL_WIFI_UNDER_5G, &wifi_under_5g);
>> -
>> -       rsp_source = tmp_buf[0]&0xf;
>> -       if (rsp_source >= BT_INFO_SRC_8821A_1ANT_MAX)
>> -               rsp_source = BT_INFO_SRC_8821A_1ANT_WIFI_FW;
>> -       coex_sta->bt_info_c2h_cnt[rsp_source]++;
>> -
>> -       BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
>> -                 "[BTCoex], Bt info[%d], length = %d, hex data = [",
>> -                 rsp_source, length);
>> -       for (i = 0; i < length; i++) {
>> -               coex_sta->bt_info_c2h[rsp_source][i] = tmp_buf[i];
>> -               if (i == 1)
>> -                       bt_info = tmp_buf[i];
>> -               if (i == length-1) {
>> -                       BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
>> -                                 "0x%02x]\n", tmp_buf[i]);
>> -               } else {
>> -                       BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
>> -                                 "0x%02x, ", tmp_buf[i]);
>> -               }
>> -       }
>> -
>> -       if (BT_INFO_SRC_8821A_1ANT_WIFI_FW != rsp_source) {
>> -               coex_sta->bt_retry_cnt =        /* [3:0]*/
>> -                       coex_sta->bt_info_c2h[rsp_source][2]&0xf;
>> -
>> -               coex_sta->bt_rssi =
>> -                       coex_sta->bt_info_c2h[rsp_source][3]*2+10;
>> -
>> -               coex_sta->bt_info_ext =
>> -                       coex_sta->bt_info_c2h[rsp_source][4];
>> -
>> -               /* Here we need to resend some wifi info to BT*/
>> -               /* because bt is reset and loss of the info.*/
>> -               if (coex_sta->bt_info_ext & BIT1) {
>> -                       BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
>> -                                 "[BTCoex], BT ext info bit1 check, send
>> wifi BW&Chnl to BT!!\n");
>> -                       btcoexist->btc_get(btcoexist,
>> -                                          BTC_GET_BL_WIFI_CONNECTED,
>> -                                          &wifi_connected);
>> -                       if (wifi_connected) {
>> -
>> ex_halbtc8821a1ant_media_status_notify(btcoexist,
>> -
>> BTC_MEDIA_CONNECT);
>> -                       } else {
>> -
>> ex_halbtc8821a1ant_media_status_notify(btcoexist,
>> -
>> BTC_MEDIA_DISCONNECT);
>> -                       }
>> -               }
>> -
>> -               if ((coex_sta->bt_info_ext & BIT3) && !wifi_under_5g) {
>> -                       if (!btcoexist->manual_control &&
>> -                           !btcoexist->stop_coex_dm) {
>> -                               BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
>> -                                         "[BTCoex], BT ext info bit3
>> check, set BT NOT to ignore Wlan active!!\n");
>> -                               halbtc8821a1ant_ignore_wlan_act(btcoexist,
>> -
>> FORCE_EXEC,
>> -                                                               false);
>> -                       }
>> -               }
>> -#if (BT_AUTO_REPORT_ONLY_8821A_1ANT == 0)
>> -               if (!(coex_sta->bt_info_ext & BIT4)) {
>> -                       BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
>> -                                 "[BTCoex], BT ext info bit4 check, set
>> BT to enable Auto Report!!\n");
>> -                       halbtc8821a1ant_bt_auto_report(btcoexist,
>> -                                                      FORCE_EXEC, true);
>> -               }
>> -#endif
>> -       }
>> -
>> -       /* check BIT2 first ==> check if bt is under inquiry or page
>> scan*/
>> -       if (bt_info & BT_INFO_8821A_1ANT_B_INQ_PAGE)
>> -               coex_sta->c2h_bt_inquiry_page = true;
>> -       else
>> -               coex_sta->c2h_bt_inquiry_page = false;
>> -
>> -       /* set link exist status*/
>> -       if (!(bt_info&BT_INFO_8821A_1ANT_B_CONNECTION)) {
>> -               coex_sta->bt_link_exist = false;
>> -               coex_sta->pan_exist = false;
>> -               coex_sta->a2dp_exist = false;
>> -               coex_sta->hid_exist = false;
>> -               coex_sta->sco_exist = false;
>> -       } else {
>> -               /* connection exists*/
>> -               coex_sta->bt_link_exist = true;
>> -               if (bt_info & BT_INFO_8821A_1ANT_B_FTP)
>> -                       coex_sta->pan_exist = true;
>> -               else
>> -                       coex_sta->pan_exist = false;
>> -               if (bt_info & BT_INFO_8821A_1ANT_B_A2DP)
>> -                       coex_sta->a2dp_exist = true;
>> -               else
>> -                       coex_sta->a2dp_exist = false;
>> -               if (bt_info & BT_INFO_8821A_1ANT_B_HID)
>> -                       coex_sta->hid_exist = true;
>> -               else
>> -                       coex_sta->hid_exist = false;
>> -               if (bt_info & BT_INFO_8821A_1ANT_B_SCO_ESCO)
>> -                       coex_sta->sco_exist = true;
>> -               else
>> -                       coex_sta->sco_exist = false;
>> -       }
>> -
>> -       halbtc8821a1ant_update_bt_link_info(btcoexist);
>> -
>> -       if (!(bt_info&BT_INFO_8821A_1ANT_B_CONNECTION)) {
>> -               coex_dm->bt_status =
>> BT_8821A_1ANT_BT_STATUS_NON_CONNECTED_IDLE;
>> -               BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
>> -                         "[BTCoex], BtInfoNotify(), BT Non-Connected
>> idle!!!\n");
>> -       } else if (bt_info == BT_INFO_8821A_1ANT_B_CONNECTION) {
>> -               /* connection exists but no busy*/
>> -               coex_dm->bt_status =
>> BT_8821A_1ANT_BT_STATUS_CONNECTED_IDLE;
>> -               BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
>> -                         "[BTCoex], BtInfoNotify(), BT
>> Connected-idle!!!\n");
>> -       } else if ((bt_info&BT_INFO_8821A_1ANT_B_SCO_ESCO) ||
>> -               (bt_info&BT_INFO_8821A_1ANT_B_SCO_BUSY)) {
>> -               coex_dm->bt_status = BT_8821A_1ANT_BT_STATUS_SCO_BUSY;
>> -               BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
>> -                         "[BTCoex], BtInfoNotify(), BT SCO busy!!!\n");
>> -       } else if (bt_info&BT_INFO_8821A_1ANT_B_ACL_BUSY) {
>> -               if (BT_8821A_1ANT_BT_STATUS_ACL_BUSY !=
>> coex_dm->bt_status)
>> -                       coex_dm->auto_tdma_adjust = false;
>> -               coex_dm->bt_status = BT_8821A_1ANT_BT_STATUS_ACL_BUSY;
>> -               BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
>> -                         "[BTCoex], BtInfoNotify(), BT ACL busy!!!\n");
>> -       } else {
>> -               coex_dm->bt_status = BT_8821A_1ANT_BT_STATUS_MAX;
>> -               BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
>> -                         "[BTCoex], BtInfoNotify(), BT Non-Defined
>> state!!!\n");
>> -       }
>> -
>> -       if ((BT_8821A_1ANT_BT_STATUS_ACL_BUSY == coex_dm->bt_status) ||
>> -           (BT_8821A_1ANT_BT_STATUS_SCO_BUSY == coex_dm->bt_status) ||
>> -           (BT_8821A_1ANT_BT_STATUS_ACL_SCO_BUSY == coex_dm->bt_status))
>> -               bt_busy = true;
>> -       else
>> -               bt_busy = false;
>> -       btcoexist->btc_set(btcoexist,
>> -                          BTC_SET_BL_BT_TRAFFIC_BUSY, &bt_busy);
>> -
>> -       halbtc8821a1ant_run_coexist_mechanism(btcoexist);
>> -}
>> -
>> -void ex_halbtc8821a1ant_halt_notify(struct btc_coexist *btcoexist)
>> -{
>> -       BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
>> -                 "[BTCoex], Halt notify\n");
>> -
>> -       btcoexist->stop_coex_dm = true;
>> -
>> -       halbtc8821a1ant_set_ant_path(btcoexist,
>> -                                    BTC_ANT_PATH_BT, false, true);
>> -       halbtc8821a1ant_ignore_wlan_act(btcoexist, FORCE_EXEC, true);
>> -
>> -       halbtc8821a1ant_power_save_state(btcoexist,
>> -                                        BTC_PS_WIFI_NATIVE, 0x0, 0x0);
>> -       halbtc8821a1ant_ps_tdma(btcoexist, FORCE_EXEC, false, 0);
>> -
>> -       ex_halbtc8821a1ant_media_status_notify(btcoexist,
>> -                                              BTC_MEDIA_DISCONNECT);
>> -}
>> -
>> -void ex_halbtc8821a1ant_pnp_notify(struct btc_coexist *btcoexist, u8
>> pnp_state)
>> -{
>> -       BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
>> -                 "[BTCoex], Pnp notify\n");
>> -
>> -       if (BTC_WIFI_PNP_SLEEP == pnp_state) {
>> -               BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
>> -                         "[BTCoex], Pnp notify to SLEEP\n");
>> -               btcoexist->stop_coex_dm = true;
>> -               halbtc8821a1ant_ignore_wlan_act(btcoexist, FORCE_EXEC,
>> true);
>> -               halbtc8821a1ant_power_save_state(btcoexist,
>> BTC_PS_WIFI_NATIVE,
>> -                                                0x0, 0x0);
>> -               halbtc8821a1ant_ps_tdma(btcoexist, NORMAL_EXEC, false, 9);
>> -       } else if (BTC_WIFI_PNP_WAKE_UP == pnp_state) {
>> -               BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
>> -                         "[BTCoex], Pnp notify to WAKE UP\n");
>> -               btcoexist->stop_coex_dm = false;
>> -               halbtc8821a1ant_init_hw_config(btcoexist, false);
>> -               halbtc8821a1ant_init_coex_dm(btcoexist);
>> -               halbtc8821a1ant_query_bt_info(btcoexist);
>> -       }
>> -}
>> -
>> -void
>> -ex_halbtc8821a1ant_periodical(
>> -       struct btc_coexist *btcoexist) {
>> -       static u8       dis_ver_info_cnt;
>> -       u32             fw_ver = 0, bt_patch_ver = 0;
>> -       struct btc_board_info *board_info = &btcoexist->board_info;
>> -       struct btc_stack_info *stack_info = &btcoexist->stack_info;
>> -
>> -       BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
>> -                 "[BTCoex],
>> ==========================Periodical===========================\n");
>> -
>> -       if (dis_ver_info_cnt <= 5) {
>> -               dis_ver_info_cnt += 1;
>> -               BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
>> -                         "[BTCoex],
>> ****************************************************************\n");
>> -               BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
>> -                         "[BTCoex], Ant PG Num/ Ant Mech/ Ant Pos = %d/
>> %d/ %d\n",
>> -                         board_info->pg_ant_num,
>> -                         board_info->btdm_ant_num,
>> -                         board_info->btdm_ant_pos);
>> -               BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
>> -                         "[BTCoex], BT stack/ hci ext ver = %s / %d\n",
>> -                         ((stack_info->profile_notified) ? "Yes" : "No"),
>> -                         stack_info->hci_version);
>> -               btcoexist->btc_get(btcoexist, BTC_GET_U4_BT_PATCH_VER,
>> -                                  &bt_patch_ver);
>> -               btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_FW_VER,
>> &fw_ver);
>> -               BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
>> -                         "[BTCoex], CoexVer/ FwVer/ PatchVer = %d_%x/
>> 0x%x/ 0x%x(%d)\n",
>> -                       glcoex_ver_date_8821a_1ant,
>> -                       glcoex_ver_8821a_1ant,
>> -                       fw_ver, bt_patch_ver,
>> -                       bt_patch_ver);
>> -               BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
>> -                         "[BTCoex],
>> ****************************************************************\n");
>> -       }
>> -
>> -#if (BT_AUTO_REPORT_ONLY_8821A_1ANT == 0)
>> -       halbtc8821a1ant_query_bt_info(btcoexist);
>> -       halbtc8821a1ant_monitor_bt_ctr(btcoexist);
>> -       btc8821a1ant_mon_bt_en_dis(btcoexist);
>> -#else
>> -       if (halbtc8821a1ant_Is_wifi_status_changed(btcoexist) ||
>> -           coex_dm->auto_tdma_adjust) {
>> -               if (coex_sta->special_pkt_period_cnt > 2)
>> -                       halbtc8821a1ant_run_coexist_mechanism(btcoexist);
>> -       }
>> -
>> -       coex_sta->special_pkt_period_cnt++;
>> -#endif
>> -}
>> diff --git a/drivers/net/wireless/rtlwifi/btcoexist/halbtc8821a1ant.h
>> b/drivers/net/wireless/rtlwifi/btcoexist/halbtc8821a1ant.h
>> index 20e9048..c3eab15 100644
>> --- a/drivers/net/wireless/rtlwifi/btcoexist/halbtc8821a1ant.h
>> +++ b/drivers/net/wireless/rtlwifi/btcoexist/halbtc8821a1ant.h
>> @@ -168,21 +168,7 @@ struct coex_sta_8821a_1ant {
>>    * The following is interface which will notify coex module.
>>    *===========================================
>>    */
>> -void ex_halbtc8821a1ant_init_hwconfig(struct btc_coexist *btcoexist);
>> -void ex_halbtc8821a1ant_init_coex_dm(struct btc_coexist *btcoexist);
>> -void ex_halbtc8821a1ant_ips_notify(struct btc_coexist *btcoexist, u8
>> type);
>> -void ex_halbtc8821a1ant_lps_notify(struct btc_coexist *btcoexist, u8
>> type);
>> -void ex_halbtc8821a1ant_scan_notify(struct btc_coexist *btcoexist, u8
>> type);
>> -void ex_halbtc8821a1ant_connect_notify(struct btc_coexist *btcoexist, u8
>> type);
>>   void ex_halbtc8821a1ant_media_status_notify(struct btc_coexist
>> *btcoexist,
>>                                             u8 type);
>> -void ex_halbtc8821a1ant_special_packet_notify(struct btc_coexist
>> *btcoexist,
>> -                                             u8 type);
>> -void ex_halbtc8821a1ant_bt_info_notify(struct btc_coexist *btcoexist,
>> -                                      u8 *tmpbuf, u8 length);
>> -void ex_halbtc8821a1ant_halt_notify(struct btc_coexist *btcoexist);
>> -void ex_halbtc8821a1ant_pnp_notify(struct btc_coexist *btcoexist, u8
>> pnpstate);
>> -void ex_halbtc8821a1ant_periodical(struct btc_coexist *btcoexist);
>> -void ex_halbtc8821a1ant_display_coex_info(struct btc_coexist *btcoexist);
>>   void ex_halbtc8821a1ant_dbg_control(struct btc_coexist *btcoexist, u8
>> op_code,
>>                                     u8 op_len, u8 *data);
>>


Hi

I was absolutely sure that was in the brcm80211/brcmsmac part for some
reason, but I should of course double-checked it!

Apologies, I will not send any more patches.


Kind regards
Rickard Strandqvist
