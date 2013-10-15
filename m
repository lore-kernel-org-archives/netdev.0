From: Sander Eikelenboom <linux-6SM94LqRVpn6gRhOQ7JHfg@public.gmane.org>
Subject: Re: [Ilw] drivers/net/wireless/iwlwifi/dvm/tx.c:456 iwlagn_tx_skb+0x6c5/0x883()
Date: Tue, 15 Oct 2013 22:19:18 +0200
Message-ID: <1701086355.20131015221918@eikelenboom.it>
References: <9010061839.20131015123940@eikelenboom.it> <0BA3FCBA62E2DC44AF3030971E174FB301DC46E5@HASMSX103.ger.corp.intel.com> <1127865420.20131015151054@eikelenboom.it> <0BA3FCBA62E2DC44AF3030971E174FB301DC4AB7@HASMSX103.ger.corp.intel.com> <1764863131.20131015210406@eikelenboom.it> <0BA3FCBA62E2DC44AF3030971E174FB301DC4E24@HASMSX103.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"Berg, Johannes" <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org" <ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Grumbach, Emmanuel" <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <0BA3FCBA62E2DC44AF3030971E174FB301DC4E24-yLYCJVCiOGwLt2AQoY/u9bfspsVTdybXVpNB7YpNyf8@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Tuesday, October 15, 2013, 9:11:36 PM, you wrote:

>> > Please apply this:
>> > diff --git a/drivers/net/wireless/iwlwifi/dvm/tx.c
>> b/drivers/net/wireless/iwlwifi/dvm/tx.c
>> > index d131f85..5968f19 100644
>> > --- a/drivers/net/wireless/iwlwifi/dvm/tx.c
>> > +++ b/drivers/net/wireless/iwlwifi/dvm/tx.c
>> > @@ -457,8 +457,8 @@ int iwlagn_tx_skb(struct iwl_priv *priv,
>> >         WARN_ON_ONCE(is_agg &&
>> >                      priv->queue_to_mac80211[txq_id] != info->hw_queue);
>> >
>> > -       IWL_DEBUG_TX(priv, "TX to [%d|%d] Q:%d - seq: 0x%x\n", sta_id, tid,
>> > -                    txq_id, seq_number);
>> > +       IWL_DEBUG_TX(priv, "TX to [%d|%d] Q:%d info Q %d - seq: 0x%x\n",
>> sta_id, tid,
>> > +                    txq_id, info->hw_queue, seq_number);
>> >
>> >         if (iwl_trans_tx(priv->trans, skb, dev_cmd, txq_id))
>> >                 goto drop_unlock_sta;
>> 
>> > and send the output back to me
>> 
>> > Thanks.
>> 

> Can you please apply the patch attached (and remove the previous change)?
> Thanks.


That seems to make the warning go away :-)

[    7.306696] iwlwifi 0000:02:00.0: L1 Disabled; Enabling L0S
[    7.315790] iwlwifi 0000:02:00.0: Radio type=0x2-0x1-0x0
[    7.362212] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 9 on FIFO 7 WrPtr: 0
[    7.364973] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 0 on FIFO 3 WrPtr: 0
[    7.365090] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 1 on FIFO 2 WrPtr: 0
[    7.365208] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 2 on FIFO 1 WrPtr: 0
[    7.365324] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 3 on FIFO 0 WrPtr: 0
[    7.365440] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 4 on FIFO 0 WrPtr: 0
[    7.365556] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 5 on FIFO 4 WrPtr: 0
[    7.365672] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 6 on FIFO 2 WrPtr: 0
[    7.365789] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 7 on FIFO 5 WrPtr: 0
[    7.365905] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 8 on FIFO 4 WrPtr: 0
[    7.366034] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 10 on FIFO 5 WrPtr: 0
[    7.602726] iwlwifi 0000:02:00.0: L1 Disabled; Enabling L0S
[    7.612133] iwlwifi 0000:02:00.0: Radio type=0x2-0x1-0x0
[    7.658168] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 9 on FIFO 7 WrPtr: 0
[    7.661021] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 0 on FIFO 3 WrPtr: 0
[    7.663693] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 1 on FIFO 2 WrPtr: 0
[    7.666341] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 2 on FIFO 1 WrPtr: 0
[    7.668914] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 3 on FIFO 0 WrPtr: 0
[    7.671464] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 4 on FIFO 0 WrPtr: 0
[    7.673057] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 5 on FIFO 4 WrPtr: 0
[    7.674631] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 6 on FIFO 2 WrPtr: 0
[    7.676174] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 7 on FIFO 5 WrPtr: 0
[    7.677657] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 8 on FIFO 4 WrPtr: 0
[    7.679133] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 10 on FIFO 5 WrPtr: 0
[    7.730037] device wlan0 entered promiscuous mode
[    7.732390] xen_bridge: port 2(wlan0) entered forwarding state
[    7.733984] xen_bridge: port 2(wlan0) entered forwarding state
[    7.735692] cfg80211: Pending regulatory request, waiting for it to be processed...
[    7.743541] iwlwifi 0000:02:00.0: I iwlagn_tx_skb TX to [14|8] Q:8 - seq: 0x0
[    7.745347] device wlan0 left promiscuous mode
[    7.747088] xen_bridge: port 2(wlan0) entered disabled state
[    7.748034] iwlwifi 0000:02:00.0: I iwl_trans_pcie_reclaim [Q 8] 0 -> 1 (1)
[    7.748039] iwlwifi 0000:02:00.0: I iwlagn_rx_reply_tx TXQ 8 status SUCCESS (0x00000201)
[    7.748042] iwlwifi 0000:02:00.0: I iwlagn_rx_reply_tx                               initial_rate 0x820a retries 0, idx=0 ssn=1 seq_ctl=0x0
[    7.769963] iwlwifi 0000:02:00.0: I iwl_pcie_txq_inc_wr_ptr Q:9 WR: 0x23
[    7.821813] iwlwifi 0000:02:00.0: I iwl_pcie_txq_inc_wr_ptr Q:9 WR: 0x24
[    7.824914] iwlwifi 0000:02:00.0: I iwl_pcie_txq_inc_wr_ptr Q:9 WR: 0x25
[    7.828033] iwlwifi 0000:02:00.0: I iwl_pcie_txq_inc_wr_ptr Q:9 WR: 0x26
[    7.831078] iwlwifi 0000:02:00.0: I iwl_pcie_txq_inc_wr_ptr Q:9 WR: 0x27
[    7.834005] iwlwifi 0000:02:00.0: I iwl_pcie_txq_inc_wr_ptr Q:9 WR: 0x28
[    7.836087] iwlwifi 0000:02:00.0: I iwl_pcie_txq_unmap Q 9 Free 39

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
