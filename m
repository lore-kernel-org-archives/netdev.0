From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: Re: [Ilw] drivers/net/wireless/iwlwifi/dvm/tx.c:456 iwlagn_tx_skb+0x6c5/0x883()
Date: Tue, 15 Oct 2013 21:04:06 +0200
Message-ID: <1764863131.20131015210406@eikelenboom.it>
References: <9010061839.20131015123940@eikelenboom.it> <0BA3FCBA62E2DC44AF3030971E174FB301DC46E5@HASMSX103.ger.corp.intel.com> <1127865420.20131015151054@eikelenboom.it> <0BA3FCBA62E2DC44AF3030971E174FB301DC4AB7@HASMSX103.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"Berg, Johannes" <johannes.berg@intel.com>,
	"ilw@linux.intel.com" <ilw@linux.intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>
To: "Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vserver.eikelenboom.it ([84.200.39.61]:56561 "EHLO
	smtp.eikelenboom.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757504Ab3JOTEO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Oct 2013 15:04:14 -0400
In-Reply-To: <0BA3FCBA62E2DC44AF3030971E174FB301DC4AB7@HASMSX103.ger.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Tuesday, October 15, 2013, 3:35:30 PM, you wrote:

> Please apply this:
> diff --git a/drivers/net/wireless/iwlwifi/dvm/tx.c b/drivers/net/wireless/iwlwifi/dvm/tx.c
> index d131f85..5968f19 100644
> --- a/drivers/net/wireless/iwlwifi/dvm/tx.c
> +++ b/drivers/net/wireless/iwlwifi/dvm/tx.c
> @@ -457,8 +457,8 @@ int iwlagn_tx_skb(struct iwl_priv *priv,
>         WARN_ON_ONCE(is_agg &&
>                      priv->queue_to_mac80211[txq_id] != info->hw_queue);
>  
> -       IWL_DEBUG_TX(priv, "TX to [%d|%d] Q:%d - seq: 0x%x\n", sta_id, tid,
> -                    txq_id, seq_number);
> +       IWL_DEBUG_TX(priv, "TX to [%d|%d] Q:%d info Q %d - seq: 0x%x\n", sta_id, tid,
> +                    txq_id, info->hw_queue, seq_number);
>  
>         if (iwl_trans_tx(priv->trans, skb, dev_cmd, txq_id))
>                 goto drop_unlock_sta;

> and send the output back to me

> Thanks.

With the patch i get:

That results in:

[    7.154856] iwlwifi 0000:02:00.0: L1 Disabled; Enabling L0S
[    7.163961] iwlwifi 0000:02:00.0: Radio type=0x2-0x1-0x0
[    7.210395] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 9 on FIFO 7 WrPtr: 0
[    7.213319] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 0 on FIFO 3 WrPtr: 0
[    7.216195] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 1 on FIFO 2 WrPtr: 0
[    7.218927] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 2 on FIFO 1 WrPtr: 0
[    7.221531] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 3 on FIFO 0 WrPtr: 0
[    7.224168] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 4 on FIFO 0 WrPtr: 0
[    7.226768] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 5 on FIFO 4 WrPtr: 0
[    7.229150] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 6 on FIFO 2 WrPtr: 0
[    7.231449] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 7 on FIFO 5 WrPtr: 0
[    7.235266] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 8 on FIFO 4 WrPtr: 0
[    7.237399] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 10 on FIFO 5 WrPtr: 0
[    7.474222] iwlwifi 0000:02:00.0: L1 Disabled; Enabling L0S
[    7.485102] iwlwifi 0000:02:00.0: Radio type=0x2-0x1-0x0
[    7.534296] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 9 on FIFO 7 WrPtr: 0
[    7.538506] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 0 on FIFO 3 WrPtr: 0
[    7.542438] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 1 on FIFO 2 WrPtr: 0
[    7.546288] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 2 on FIFO 1 WrPtr: 0
[    7.549720] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 3 on FIFO 0 WrPtr: 0
[    7.553037] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 4 on FIFO 0 WrPtr: 0
[    7.556308] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 5 on FIFO 4 WrPtr: 0
[    7.559539] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 6 on FIFO 2 WrPtr: 0
[    7.562506] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 7 on FIFO 5 WrPtr: 0
[    7.565350] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 8 on FIFO 4 WrPtr: 0
[    7.568098] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 10 on FIFO 5 WrPtr: 0
[    7.614245] device wlan0 entered promiscuous mode
[    7.616548] xen_bridge: port 2(wlan0) entered forwarding state
[    7.618444] xen_bridge: port 2(wlan0) entered forwarding state
[    7.620040] cfg80211: Pending regulatory request, waiting for it to be processed...
[    7.630139] ------------[ cut here ]------------
[    7.631729] WARNING: CPU: 2 PID: 2438 at drivers/net/wireless/iwlwifi/dvm/tx.c:456 iwlagn_tx_skb+0x776/0x981()
[    7.633206] Modules linked in: acpi_cpufreq
[    7.634693] CPU: 2 PID: 2438 Comm: hostapd Not tainted 3.12.0-rc5+ #1
[    7.636529] Hardware name:                  /D53427RKE, BIOS RKPPT10H.86A.0017.2013.0425.1251 04/25/2013
[    7.638385]  0000000000000000 0000000000000009 ffffffff818a8082 0000000000000000
[    7.640163]  ffffffff8105a4f2 0000000000000000 ffffffff815f440a ffff8800d736dec0
[    7.641827]  ffff8800d6cf9790 ffff8800d736dec0 0000000000000007 0000000000000000
[    7.643295] Call Trace:
[    7.644708]  [<ffffffff818a8082>] ? dump_stack+0x41/0x51
[    7.646187]  [<ffffffff8105a4f2>] ? warn_slowpath_common+0x78/0x90
[    7.647877]  [<ffffffff815f440a>] ? iwlagn_tx_skb+0x776/0x981
[    7.649587]  [<ffffffff815f440a>] ? iwlagn_tx_skb+0x776/0x981
[    7.651188]  [<ffffffff815f2407>] ? iwlagn_mac_tx+0x19/0x30
[    7.652993]  [<ffffffff8187a261>] ? __ieee80211_tx+0x226/0x29b
[    7.654661]  [<ffffffff8187bcd9>] ? ieee80211_tx+0xa6/0xb5
[    7.656409]  [<ffffffff8187bfa7>] ? ieee80211_monitor_start_xmit+0x1e9/0x204
[    7.658237]  [<ffffffff8172e1f3>] ? dev_hard_start_xmit+0x271/0x3ec
[    7.659800]  [<ffffffff81746540>] ? sch_direct_xmit+0x66/0x164
[    7.661362]  [<ffffffff8172e553>] ? dev_queue_xmit+0x1e5/0x3c8
[    7.663062]  [<ffffffff8180bfee>] ? packet_sendmsg+0xac5/0xb3d
[    7.664683]  [<ffffffff8171ad9d>] ? sock_sendmsg+0x37/0x52
[    7.664686]  [<ffffffff810f9e0c>] ? __do_fault+0x338/0x36b
[    7.664688]  [<ffffffff81724bb4>] ? verify_iovec+0x44/0x94
[    7.664690]  [<ffffffff8171b1f7>] ? ___sys_sendmsg+0x1f1/0x283
[    7.664693]  [<ffffffff81140a73>] ? __inode_wait_for_writeback+0x67/0xae
[    7.664694]  [<ffffffff8111735e>] ? __cache_free.isra.46+0x178/0x187
[    7.664696]  [<ffffffff811173b1>] ? kmem_cache_free+0x44/0x84
[    7.664698]  [<ffffffff81132c22>] ? dentry_kill+0x13d/0x149
[    7.664699]  [<ffffffff81132f6f>] ? dput+0xe5/0xef
[    7.664701]  [<ffffffff81136e04>] ? fget_light+0x2e/0x7c
[    7.664702]  [<ffffffff8171c1f6>] ? __sys_sendmsg+0x39/0x57
[    7.664705]  [<ffffffff818b5e39>] ? system_call_fastpath+0x16/0x1b
[    7.664707] ---[ end trace 6723715cfa72062a ]---
[    7.664711] iwlwifi 0000:02:00.0: I iwlagn_tx_skb TX to [14|8] Q:7 info Q 8 - seq: 0x0
[    7.665934] device wlan0 left promiscuous mode
[    7.665941] xen_bridge: port 2(wlan0) entered disabled state
[    7.667656] iwlwifi 0000:02:00.0: I iwl_trans_pcie_reclaim [Q 7] 0 -> 1 (1)
[    7.667661] iwlwifi 0000:02:00.0: I iwlagn_rx_reply_tx TXQ 7 status SUCCESS (0x00000201)
[    7.667664] iwlwifi 0000:02:00.0: I iwlagn_rx_reply_tx                               initial_rate 0x820a retries 0, idx=0 ssn=1 seq_ctl=0x0
[    7.699446] iwlwifi 0000:02:00.0: I iwl_pcie_txq_inc_wr_ptr Q:9 WR: 0x23
[    7.738105] iwlwifi 0000:02:00.0: I iwl_pcie_txq_inc_wr_ptr Q:9 WR: 0x24
[    7.741555] iwlwifi 0000:02:00.0: I iwl_pcie_txq_inc_wr_ptr Q:9 WR: 0x25
[    7.744882] iwlwifi 0000:02:00.0: I iwl_pcie_txq_inc_wr_ptr Q:9 WR: 0x26
[    7.748108] iwlwifi 0000:02:00.0: I iwl_pcie_txq_inc_wr_ptr Q:9 WR: 0x27
[    7.751367] iwlwifi 0000:02:00.0: I iwl_pcie_txq_inc_wr_ptr Q:9 WR: 0x28
[    7.753309] iwlwifi 0000:02:00.0: I iwl_pcie_txq_unmap Q 9 Free 39
