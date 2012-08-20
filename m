From: Arnd Hannemann <arnd-BCMAnToX5e2ELgA04lAiVw@public.gmane.org>
Subject: WARNING: at include/net/mac80211.h:3630 rate_control_send_low+0xc1/0x1a1
Date: Mon, 20 Aug 2012 14:51:51 +0200
Message-ID: <503232E7.2080802@arndnet.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

I just observed the above kernel warning after issuing an "wpa_cli reassociate",
followed by some "iwconfig" calls to check the status.
Kernel is 3.4.7, Hardware is x86 (32bit) and ath9k

WARNING comes from inline function "rate_lowest_index":
3629         /* warn when we cannot find a rate. */
3630         WARN_ON_ONCE(1);

Full stacktrace below:


[1793205.090602] wlan0: deauthenticating from XX:XX:XX:XX:XX:XX by local choice (reason=3)
[1793205.090754] ------------[ cut here ]------------
[1793205.105295] WARNING: at include/net/mac80211.h:3630 rate_control_send_low+0xc1/0x1a1 [mac80211]()
[1793205.132424] Modules linked in: aes_generic xt_TCPMSS ipt_ULOG ipt_MASQUERADE xt_LOG xt_time xt_connlimit xt_helper xt_realm xt_NFQUEUE xt_tcpmss xt_addrtype xt_pkttype iptab
le_raw xt_TPROXY nf_tproxy_core ip6_tables nf_defrag_ipv6 xt_hashlimit xt_comment xt_length xt_connmark xt_owner xt_recent xt_iprange xt_physdev xt_policy xt_multiport iptable_na
t nf_nat xt_conntrack nf_conntrack_tftp nf_conntrack_sip nf_conntrack_proto_sctp nf_conntrack_pptp nf_conntrack_proto_gre nf_conntrack_netlink nfnetlink nf_conntrack_irc nf_connt
rack_h323 nf_conntrack_ftp nf_conntrack_ipv4 nf_defrag_ipv4 nf_conntrack ath9k ath5k ath9k_common ath9k_hw mac80211 ath ohci_hcd ehci_hcd cfg80211
[1793205.313648] Pid: 1959, comm: wpa_supplicant Not tainted 3.4.7-ela1 #1
[1793205.333502] Call Trace:
[1793205.341407]  [<c1016dee>] warn_slowpath_common+0x65/0x7a
[1793205.357935]  [<d094178b>] ? rate_control_send_low+0xc1/0x1a1 [mac80211]
[1793205.378312]  [<c1016e12>] warn_slowpath_null+0xf/0x13
[1793205.394073]  [<d094178b>] rate_control_send_low+0xc1/0x1a1 [mac80211]
[1793205.414008]  [<d095af6c>] minstrel_ht_get_rate+0x25/0x295 [mac80211]
[1793205.433675]  [<d09414fb>] rate_control_get_rate+0x7e/0x24d [mac80211]
[1793205.453528]  [<c102e7f4>] ? T.295+0xe/0x128
[1793205.466632]  [<c1167ffe>] ? rb_insert_color+0x58/0xc5
[1793205.482397]  [<d09494d1>] invoke_tx_handlers+0x78f/0xfa5 [mac80211]
[1793205.501799]  [<d094a648>] ieee80211_tx+0x50/0x77 [mac80211]
[1793205.519112]  [<d094a971>] ieee80211_xmit+0xae/0xb6 [mac80211]
[1793205.536956]  [<d094a9bf>] ieee80211_tx_skb_tid+0x46/0x50 [mac80211]
[1793205.556368]  [<d094e4d4>] ieee80211_send_deauth_disassoc+0xbb/0xc1 [mac80211]
[1793205.578365]  [<d094e5ff>] ieee80211_set_disassoc+0x125/0x275 [mac80211]
[1793205.598803]  [<d094e8b9>] ieee80211_mgd_deauth+0x92/0x102 [mac80211]
[1793205.618455]  [<d0943b87>] ieee80211_deauth+0x10/0x12 [mac80211]
[1793205.636812]  [<d0878348>] __cfg80211_mlme_deauth+0x84/0x90 [cfg80211]
[1793205.656702]  [<d087a9d5>] __cfg80211_disconnect+0xc3/0x125 [cfg80211]
[1793205.676594]  [<d087d330>] cfg80211_mgd_wext_siwessid+0xec/0x18d [cfg80211]
[1793205.697778]  [<d087c639>] cfg80211_wext_siwessid+0x31/0x3e [cfg80211]
[1793205.717648]  [<c1293b8a>] ioctl_standard_call+0x1e6/0x27a
[1793205.734374]  [<c1293ccf>] wext_handle_ioctl+0xb1/0x132
[1793205.750374]  [<d087c608>] ? cfg80211_wext_giwessid+0x4a/0x4a [cfg80211]
[1793205.770755]  [<c11df9db>] dev_ioctl+0x53f/0x57c
[1793205.784892]  [<c10683f8>] ? do_sync_write+0x93/0xce
[1793205.800077]  [<c11d0250>] ? kernel_sendmsg+0x37/0x37
[1793205.815514]  [<c11d0428>] sock_ioctl+0x1d8/0x1e4
[1793205.829892]  [<c11d0250>] ? kernel_sendmsg+0x37/0x37
[1793205.845341]  [<c10733b8>] do_vfs_ioctl+0x424/0x463
[1793205.860263]  [<c11d0b76>] ? sys_send+0x18/0x1a
[1793205.874146]  [<c11d1ad4>] ? sys_socketcall+0xc9/0x19c
[1793205.889848]  [<c1073425>] sys_ioctl+0x2e/0x48
[1793205.903477]  [<c129d095>] syscall_call+0x7/0xb
[1793205.917356]  [<c1290000>] ? rsi_parse+0xbf/0x331
[1793205.931752] ---[ end trace 9c8890d6ce64a00b ]---
[1793205.966909] cfg80211: Calling CRDA to update world regulatory domain
[1793205.986669] wlan0: authenticate with XX:XX:XX:XX:XX:XY


Best regards
Arnd
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
