From: Mike Galbraith <umgwanakikbuti@gmail.com>
Subject: Re: [PATCH V3.18] rtlwifi: Add check for get_btc_status callback
Date: Sat, 25 Oct 2014 04:57:05 +0200
Message-ID: <1414205825.5196.5.camel@marge.simpson.net>
References: <1414081629-23002-1-git-send-email-Larry.Finger@lwfinger.net>
	 <1414087731.5231.19.camel@marge.simpson.net>
	 <5449478B.4070908@lwfinger.net>
	 <1414116580.23080.10.camel@marge.simpson.net>
	 <544A80B5.1090604@lwfinger.net> <544A96C0.8030107@gmail.com>
	 <544AA3EE.7080806@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Larry Finger <Larry.Finger@lwfinger.net>, linville@tuxdriver.com,
	linux-wireless@vger.kernel.org, troy_tan@realsil.com.cn,
	netdev@vger.kernel.org, Thadeu Cascardo <cascardo@cascardo.eti.br>
To: Murilo Opsfelder Araujo <mopsfelder@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:46135 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751102AbaJYC5L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2014 22:57:11 -0400
In-Reply-To: <544AA3EE.7080806@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-10-24 at 17:09 -0200, Murilo Opsfelder Araujo wrote: 
> On 10/24/2014 04:13 PM, Murilo Opsfelder Araujo wrote:
> > On 10/24/2014 02:39 PM, Larry Finger wrote:
> > [...]
> >>
> >> Please try the attached patch. It replaces the second one I sent you. I
> >> will probably redo it before submitting the final copy, but this should
> >> work.
> >>
> >> Larry
> >>
> > Hi, Larry.
> >
> > I've tried your patch on top of next-20141023 and it is still crashing
> > on my laptop:
> >
> > http://opsfelder.com/~murilo/lkml/next-20141023_plus_larry_patch_v2.jpg
> >
> It seems a get_btc_status() check was still missing:
> 
> diff --git a/drivers/net/wireless/rtlwifi/pci.c 
> b/drivers/net/wireless/rtlwifi/pci.c
> index a5a350a..ed3364d 100644
> --- a/drivers/net/wireless/rtlwifi/pci.c
> +++ b/drivers/net/wireless/rtlwifi/pci.c
> @@ -1796,7 +1796,8 @@ static int rtl_pci_start(struct ieee80211_hw *hw)
>          rtl_pci_reset_trx_ring(hw);
> 
>          rtlpci->driver_is_goingto_unload = false;
> -       if (rtlpriv->cfg->ops->get_btc_status()) {
> +       if (rtlpriv->cfg->ops->get_btc_status &&
> +           rtlpriv->cfg->ops->get_btc_status()) {
>                  rtlpriv->btcoexist.btc_ops->btc_init_variables(rtlpriv);
>                  rtlpriv->btcoexist.btc_ops->btc_init_hal_vars(rtlpriv);
>          }
> 
> With this minor change and Larry's latest fix_misc_desc patch, 
> next-20141023 booted normally and kernel panic disappeared.
> 
> Now, there is no wifi network available or found by wlan0.

I don't need your addition, but our end results are the same.

[  312.126598] cfg80211: Calling CRDA to update world regulatory domain
[  312.131076] cfg80211: World regulatory domain updated:
[  312.131107] cfg80211:  DFS Master region: unset                                                                                                                                                                                          
[  312.131112] cfg80211:   (start_freq - end_freq @ bandwidth), (max_antenna_gain, max_eirp), (dfs_cac_time)                                                                                                                                
[  312.131123] cfg80211:   (2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2000 mBm), (N/A)                                                                                                                                              
[  312.131129] cfg80211:   (2457000 KHz - 2482000 KHz @ 40000 KHz), (300 mBi, 2000 mBm), (N/A)                                                                                                                                              
[  312.131136] cfg80211:   (2474000 KHz - 2494000 KHz @ 20000 KHz), (300 mBi, 2000 mBm), (N/A)                                                                                                                                              
[  312.131142] cfg80211:   (5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 2000 mBm), (N/A)                                                                                                                                              
[  312.131149] cfg80211:   (5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 2000 mBm), (N/A)                                                                                                                                              
[  312.210452] rtl8192se: FW Power Save off (module option)                                                                                                                                                                                 
[  312.210561] rtl8192se: Driver for Realtek RTL8192SE/RTL8191SE                                                                                                                                                                            
[  312.210561] Loading firmware rtlwifi/rtl8192sefw.bin                                                                                                                                                                                     
[  312.212496] ieee80211 phy0: Selected rate control algorithm 'rtl_rc'
[  312.758613] IPv6: ADDRCONF(NETDEV_UP): wlan0: link is not ready

Interface doesn't associate.

3.17.1
[  266.849622] cfg80211: Calling CRDA to update world regulatory domain
[  266.853632] cfg80211: World regulatory domain updated:
[  266.853661] cfg80211:  DFS Master region: unset
[  266.853667] cfg80211:   (start_freq - end_freq @ bandwidth), (max_antenna_gain, max_eirp), (dfs_cac_time)
[  266.853680] cfg80211:   (2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2000 mBm), (N/A)
[  266.853686] cfg80211:   (2457000 KHz - 2482000 KHz @ 40000 KHz), (300 mBi, 2000 mBm), (N/A)
[  266.853691] cfg80211:   (2474000 KHz - 2494000 KHz @ 20000 KHz), (300 mBi, 2000 mBm), (N/A)
[  266.853697] cfg80211:   (5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 2000 mBm), (N/A)
[  266.853704] cfg80211:   (5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 2000 mBm), (N/A)
[  266.926560] rtl8192se: FW Power Save off (module option)
[  266.926661] rtl8192se: Driver for Realtek RTL8192SE/RTL8191SE
[  266.926661] Loading firmware rtlwifi/rtl8192sefw.bin
[  266.927054] ieee80211 phy0: Selected rate control algorithm 'rtl_rc'
[  267.437850] IPv6: ADDRCONF(NETDEV_UP): wlan0: link is not ready
[  268.389049] wlan0: authenticate with 20:4e:7f:86:09:40
[  268.410174] wlan0: send auth to 20:4e:7f:86:09:40 (try 1/3)
[  268.411974] wlan0: authenticated
[  268.416222] wlan0: associate with 20:4e:7f:86:09:40 (try 1/3)
[  268.420555] wlan0: RX AssocResp from 20:4e:7f:86:09:40 (capab=0x431 status=0 aid=1)
[  268.423403] wlan0: associated
[  268.423427] IPv6: ADDRCONF(NETDEV_CHANGE): wlan0: link becomes ready
