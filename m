From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [linux-next: May 13] intel/iwlwifi/mvm/mvm.h:1069 suspicious
 rcu_dereference_protected() usage
Date: Sun, 15 May 2016 01:34:37 +0900
Message-ID: <20160514163437.GD15615@swordfish>
References: <20160514163127.GC15615@swordfish>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes.berg@intel.com>,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	Luca Coelho <luciano.coelho@intel.com>,
	Intel Linux Wireless <linuxwifi@intel.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160514163127.GC15615@swordfish>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On (05/15/16 01:31), Sergey Senozhatsky wrote:
> [11455.550649] ===============================
> [11455.550652] [ INFO: suspicious RCU usage. ]
> [11455.550657] 4.6.0-rc7-next-20160513-dbg-00004-g8de8b92-dirty #655 Not tainted
> [11455.550660] -------------------------------
> [11455.550664] drivers/net/wireless/intel/iwlwifi/mvm/mvm.h:1069 suspicious rcu_dereference_protected() usage!
> [11455.550667] 
>                other info that might help us debug this:
> 
> [11455.550671] 
>                rcu_scheduler_active = 1, debug_locks = 0
> [11455.550675] 5 locks held by irq/29-iwlwifi/247:
> [11455.550677]  #0:  (sync_cmd_lockdep_map){++++..}, at: [<ffffffffa02283d8>] iwl_pcie_irq_handler+0x0/0x635 [iwlwifi]
> [11455.550705]  #1:  (&(&rxq->lock)->rlock){+.+...}, at: [<ffffffffa022709d>] iwl_pcie_rx_handle+0x38/0x5d5 [iwlwifi]
> [11455.550725]  #2:  (rcu_read_lock){......}, at: [<ffffffffa033396f>] ieee80211_rx_napi+0x152/0x8e2 [mac80211]
> [11455.550768]  #3:  (&(&local->rx_path_lock)->rlock){+.-...}, at: [<ffffffffa03306a1>] ieee80211_rx_handlers+0x2e/0x1fe1 [mac80211]
> [11455.550804]  #4:  (rcu_read_lock){......}, at: [<ffffffffa03b49f8>] iwl_mvm_update_tkip_key+0x0/0x162 [iwlmvm]
> [11455.550833] 


[ 5406.034379] iwlwifi 0000:02:00.0: Queue 16 stuck for 10000 ms.
[ 5406.034385] iwlwifi 0000:02:00.0: Current SW read_ptr 98 write_ptr 125
[ 5406.034431] iwl data: 00000000: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[ 5406.034454] iwlwifi 0000:02:00.0: FH TRBs(0) = 0x8000300f
[ 5406.034475] iwlwifi 0000:02:00.0: FH TRBs(1) = 0xc0110071
[ 5406.034491] iwlwifi 0000:02:00.0: FH TRBs(2) = 0x00000000
[ 5406.034505] iwlwifi 0000:02:00.0: FH TRBs(3) = 0x8030001e
[ 5406.034520] iwlwifi 0000:02:00.0: FH TRBs(4) = 0x00000000
[ 5406.034536] iwlwifi 0000:02:00.0: FH TRBs(5) = 0x00000000
[ 5406.034551] iwlwifi 0000:02:00.0: FH TRBs(6) = 0x00000000
[ 5406.034566] iwlwifi 0000:02:00.0: FH TRBs(7) = 0x00709087
[ 5406.034625] iwlwifi 0000:02:00.0: Q 0 is active and mapped to fifo 3 ra_tid 0x0000 [31,31]
[ 5406.034690] iwlwifi 0000:02:00.0: Q 1 is active and mapped to fifo 2 ra_tid 0x0000 [0,0]
[ 5406.034756] iwlwifi 0000:02:00.0: Q 2 is active and mapped to fifo 1 ra_tid 0x0000 [17,17]
[ 5406.034821] iwlwifi 0000:02:00.0: Q 3 is active and mapped to fifo 0 ra_tid 0x0000 [16,16]
[ 5406.034886] iwlwifi 0000:02:00.0: Q 4 is inactive and mapped to fifo 0 ra_tid 0x0000 [0,0]
[ 5406.034944] iwlwifi 0000:02:00.0: Q 5 is inactive and mapped to fifo 0 ra_tid 0x0000 [0,0]
[ 5406.035010] iwlwifi 0000:02:00.0: Q 6 is inactive and mapped to fifo 0 ra_tid 0x0000 [0,0]
[ 5406.035068] iwlwifi 0000:02:00.0: Q 7 is inactive and mapped to fifo 0 ra_tid 0x0000 [0,0]
[ 5406.035133] iwlwifi 0000:02:00.0: Q 8 is inactive and mapped to fifo 0 ra_tid 0x0000 [0,0]
[ 5406.035192] iwlwifi 0000:02:00.0: Q 9 is active and mapped to fifo 7 ra_tid 0x0000 [136,136]
[ 5406.035257] iwlwifi 0000:02:00.0: Q 10 is inactive and mapped to fifo 0 ra_tid 0x0000 [0,0]
[ 5406.035323] iwlwifi 0000:02:00.0: Q 11 is inactive and mapped to fifo 0 ra_tid 0x0000 [0,0]
[ 5406.035388] iwlwifi 0000:02:00.0: Q 12 is inactive and mapped to fifo 0 ra_tid 0x0000 [0,0]
[ 5406.035446] iwlwifi 0000:02:00.0: Q 13 is inactive and mapped to fifo 0 ra_tid 0x0000 [0,0]
[ 5406.035505] iwlwifi 0000:02:00.0: Q 14 is inactive and mapped to fifo 0 ra_tid 0x0000 [0,0]
[ 5406.035563] iwlwifi 0000:02:00.0: Q 15 is active and mapped to fifo 5 ra_tid 0x0000 [0,0]
[ 5406.035622] iwlwifi 0000:02:00.0: Q 16 is active and mapped to fifo 1 ra_tid 0x0000 [98,125]
[ 5406.035687] iwlwifi 0000:02:00.0: Q 17 is inactive and mapped to fifo 0 ra_tid 0x0000 [0,0]
[ 5406.035752] iwlwifi 0000:02:00.0: Q 18 is inactive and mapped to fifo 0 ra_tid 0x0000 [0,0]
[ 5406.035817] iwlwifi 0000:02:00.0: Q 19 is inactive and mapped to fifo 0 ra_tid 0x0000 [0,0]
[ 5406.035883] iwlwifi 0000:02:00.0: Q 20 is inactive and mapped to fifo 0 ra_tid 0xfffc [0,0]
[ 5406.035940] iwlwifi 0000:02:00.0: Q 21 is inactive and mapped to fifo 0 ra_tid 0x0003 [0,0]
[ 5406.035999] iwlwifi 0000:02:00.0: Q 22 is inactive and mapped to fifo 0 ra_tid 0x0000 [0,0]
[ 5406.036064] iwlwifi 0000:02:00.0: Q 23 is inactive and mapped to fifo 0 ra_tid 0x0000 [0,0]
[ 5406.036122] iwlwifi 0000:02:00.0: Q 24 is inactive and mapped to fifo 0 ra_tid 0x0000 [0,0]
[ 5406.036188] iwlwifi 0000:02:00.0: Q 25 is inactive and mapped to fifo 0 ra_tid 0x0000 [0,0]
[ 5406.036246] iwlwifi 0000:02:00.0: Q 26 is inactive and mapped to fifo 0 ra_tid 0x0000 [0,0]
[ 5406.036305] iwlwifi 0000:02:00.0: Q 27 is inactive and mapped to fifo 0 ra_tid 0x0000 [0,0]
[ 5406.036370] iwlwifi 0000:02:00.0: Q 28 is inactive and mapped to fifo 0 ra_tid 0x0000 [0,0]
[ 5406.036428] iwlwifi 0000:02:00.0: Q 29 is inactive and mapped to fifo 0 ra_tid 0x0000 [0,0]
[ 5406.036487] iwlwifi 0000:02:00.0: Q 30 is inactive and mapped to fifo 0 ra_tid 0x0000 [0,0]
[ 5406.036555] iwlwifi 0000:02:00.0: Microcode SW error detected.  Restarting 0x2000000.
[ 5406.036558] iwlwifi 0000:02:00.0: CSR values:
[ 5406.036559] iwlwifi 0000:02:00.0: (2nd byte of CSR_INT_COALESCING is CSR_INT_PERIODIC_REG)
[ 5406.036567] iwlwifi 0000:02:00.0:        CSR_HW_IF_CONFIG_REG: 0X40489204
[ 5406.036581] iwlwifi 0000:02:00.0:          CSR_INT_COALESCING: 0X80000040
[ 5406.036595] iwlwifi 0000:02:00.0:                     CSR_INT: 0X00000000
[ 5406.036609] iwlwifi 0000:02:00.0:                CSR_INT_MASK: 0X00000000
[ 5406.036622] iwlwifi 0000:02:00.0:           CSR_FH_INT_STATUS: 0X00000000
[ 5406.036636] iwlwifi 0000:02:00.0:                 CSR_GPIO_IN: 0X00000000
[ 5406.036650] iwlwifi 0000:02:00.0:                   CSR_RESET: 0X00000000
[ 5406.036664] iwlwifi 0000:02:00.0:                CSR_GP_CNTRL: 0X080403c5
[ 5406.036678] iwlwifi 0000:02:00.0:                  CSR_HW_REV: 0X00000144
[ 5406.036692] iwlwifi 0000:02:00.0:              CSR_EEPROM_REG: 0X00000000
[ 5406.036705] iwlwifi 0000:02:00.0:               CSR_EEPROM_GP: 0X80000000
[ 5406.036719] iwlwifi 0000:02:00.0:              CSR_OTP_GP_REG: 0X803a0000
[ 5406.036733] iwlwifi 0000:02:00.0:                 CSR_GIO_REG: 0X001f0042
[ 5406.036747] iwlwifi 0000:02:00.0:            CSR_GP_UCODE_REG: 0X00000000
[ 5406.036761] iwlwifi 0000:02:00.0:           CSR_GP_DRIVER_REG: 0X00000000
[ 5406.036775] iwlwifi 0000:02:00.0:           CSR_UCODE_DRV_GP1: 0X00000000
[ 5406.036789] iwlwifi 0000:02:00.0:           CSR_UCODE_DRV_GP2: 0X00000000
[ 5406.036803] iwlwifi 0000:02:00.0:                 CSR_LED_REG: 0X00000018
[ 5406.036817] iwlwifi 0000:02:00.0:        CSR_DRAM_INT_TBL_REG: 0X88037d12
[ 5406.036830] iwlwifi 0000:02:00.0:        CSR_GIO_CHICKEN_BITS: 0X27800200
[ 5406.036844] iwlwifi 0000:02:00.0:             CSR_ANA_PLL_CFG: 0Xd55555d5
[ 5406.036858] iwlwifi 0000:02:00.0:      CSR_MONITOR_STATUS_REG: 0X3d0801bd
[ 5406.036872] iwlwifi 0000:02:00.0:           CSR_HW_REV_WA_REG: 0X0001001a
[ 5406.036886] iwlwifi 0000:02:00.0:        CSR_DBG_HPET_MEM_REG: 0Xffff0010
[ 5406.036888] iwlwifi 0000:02:00.0: FH register values:
[ 5406.036920] iwlwifi 0000:02:00.0:         FH_RSCSR_CHNL0_STTS_WPTR_REG: 0X41cb6300
[ 5406.036942] iwlwifi 0000:02:00.0:        FH_RSCSR_CHNL0_RBDCB_BASE_REG: 0X041cb620
[ 5406.036957] iwlwifi 0000:02:00.0:                  FH_RSCSR_CHNL0_WPTR: 0X000000a0
[ 5406.036973] iwlwifi 0000:02:00.0:         FH_MEM_RCSR_CHNL0_CONFIG_REG: 0X00801114
[ 5406.036988] iwlwifi 0000:02:00.0:          FH_MEM_RSSR_SHARED_CTRL_REG: 0X000000fc
[ 5406.037003] iwlwifi 0000:02:00.0:            FH_MEM_RSSR_RX_STATUS_REG: 0X03030000
[ 5406.037019] iwlwifi 0000:02:00.0:    FH_MEM_RSSR_RX_ENABLE_ERR_IRQ2DRV: 0X00000000
[ 5406.037034] iwlwifi 0000:02:00.0:                FH_TSSR_TX_STATUS_REG: 0X07ff0001
[ 5406.037049] iwlwifi 0000:02:00.0:                 FH_TSSR_TX_ERROR_REG: 0X00000000
[ 5406.037189] iwlwifi 0000:02:00.0: Start IWL Error Log Dump:
[ 5406.037191] iwlwifi 0000:02:00.0: Status: 0x00000000, count: 6
[ 5406.037193] iwlwifi 0000:02:00.0: Loaded firmware version: 16.242414.0
[ 5406.037195] iwlwifi 0000:02:00.0: 0x00000084 | NMI_INTERRUPT_UNKNOWN       
[ 5406.037196] iwlwifi 0000:02:00.0: 0x00800634 | trm_hw_status0
[ 5406.037198] iwlwifi 0000:02:00.0: 0x00000000 | trm_hw_status1
[ 5406.037199] iwlwifi 0000:02:00.0: 0x00000B2C | branchlink2
[ 5406.037201] iwlwifi 0000:02:00.0: 0x00016A90 | interruptlink1
[ 5406.037202] iwlwifi 0000:02:00.0: 0x00000118 | interruptlink2
[ 5406.037203] iwlwifi 0000:02:00.0: 0x00000000 | data1
[ 5406.037205] iwlwifi 0000:02:00.0: 0x00000080 | data2
[ 5406.037206] iwlwifi 0000:02:00.0: 0x07030000 | data3
[ 5406.037207] iwlwifi 0000:02:00.0: 0x860034C0 | beacon time
[ 5406.037209] iwlwifi 0000:02:00.0: 0xE1B61B33 | tsf low
[ 5406.037210] iwlwifi 0000:02:00.0: 0x00000021 | tsf hi
[ 5406.037212] iwlwifi 0000:02:00.0: 0x00000000 | time gp1
[ 5406.037213] iwlwifi 0000:02:00.0: 0x401F310B | time gp2
[ 5406.037214] iwlwifi 0000:02:00.0: 0x00000000 | uCode revision type
[ 5406.037216] iwlwifi 0000:02:00.0: 0x00000010 | uCode version major
[ 5406.037217] iwlwifi 0000:02:00.0: 0x0003B2EE | uCode version minor
[ 5406.037218] iwlwifi 0000:02:00.0: 0x00000144 | hw version
[ 5406.037220] iwlwifi 0000:02:00.0: 0x40489204 | board version
[ 5406.037221] iwlwifi 0000:02:00.0: 0x1062001C | hcmd
[ 5406.037222] iwlwifi 0000:02:00.0: 0xA4022002 | isr0
[ 5406.037224] iwlwifi 0000:02:00.0: 0x00800000 | isr1
[ 5406.037225] iwlwifi 0000:02:00.0: 0x0000000B | isr2
[ 5406.037226] iwlwifi 0000:02:00.0: 0x0040A8C5 | isr3
[ 5406.037228] iwlwifi 0000:02:00.0: 0x00000000 | isr4
[ 5406.037229] iwlwifi 0000:02:00.0: 0x00004110 | last cmd Id
[ 5406.037230] iwlwifi 0000:02:00.0: 0x00000000 | wait_event
[ 5406.037232] iwlwifi 0000:02:00.0: 0x00000080 | l2p_control
[ 5406.037233] iwlwifi 0000:02:00.0: 0x00012030 | l2p_duration
[ 5406.037234] iwlwifi 0000:02:00.0: 0x0000003F | l2p_mhvalid
[ 5406.037236] iwlwifi 0000:02:00.0: 0x00000080 | l2p_addr_match
[ 5406.037237] iwlwifi 0000:02:00.0: 0x00000005 | lmpm_pmg_sel
[ 5406.037238] iwlwifi 0000:02:00.0: 0x17111905 | timestamp
[ 5406.037240] iwlwifi 0000:02:00.0: 0x0034A0B0 | flow_handler
[ 5406.037258] ieee80211 phy0: Hardware restart was requested
[ 5406.496737] iwlwifi 0000:02:00.0: L1 Enabled - LTR Enabled
[ 5406.497046] iwlwifi 0000:02:00.0: L1 Enabled - LTR Enabled
[ 5406.710336] iwlwifi 0000:02:00.0: L1 Enabled - LTR Enabled
[ 5406.710613] iwlwifi 0000:02:00.0: L1 Enabled - LTR Enabled


	-ss

>                stack backtrace:
> [11455.550840] CPU: 4 PID: 247 Comm: irq/29-iwlwifi Not tainted 4.6.0-rc7-next-20160513-dbg-00004-g8de8b92-dirty #655
> [11455.550844]  0000000000000000 ffff880037ff78e8 ffffffff81187f9c ffff88041b7ea980
> [11455.550854]  0000000000000001 ffff880037ff7918 ffffffff8106b836 ffff88041bc0e028
> [11455.550863]  0000000000000000 ffff88041d247878 ffff88041bc0e028 ffff880037ff7938
> [11455.550872] Call Trace:
> [11455.550883]  [<ffffffff81187f9c>] dump_stack+0x68/0x92
> [11455.550890]  [<ffffffff8106b836>] lockdep_rcu_suspicious+0xf7/0x100
> [11455.550911]  [<ffffffffa03b2321>] iwl_mvm_get_key_sta.part.0+0x5d/0x80 [iwlmvm]
> [11455.550930]  [<ffffffffa03b4acb>] iwl_mvm_update_tkip_key+0xd3/0x162 [iwlmvm]
> [11455.550945]  [<ffffffffa03a2b60>] iwl_mvm_mac_update_tkip_key+0x17/0x19 [iwlmvm]
> [11455.550973]  [<ffffffffa0329646>] ieee80211_tkip_decrypt_data+0x22c/0x24b [mac80211]
> [11455.550996]  [<ffffffffa0318bb1>] ieee80211_crypto_tkip_decrypt+0xc5/0x110 [mac80211]
> [11455.551026]  [<ffffffffa033102e>] ieee80211_rx_handlers+0x9bb/0x1fe1 [mac80211]
> [11455.551035]  [<ffffffff8106b08f>] ? __lock_is_held+0x3c/0x57
> [11455.551063]  [<ffffffffa0333773>] ieee80211_prepare_and_rx_handle+0xe89/0xf33 [mac80211]
> [11455.551071]  [<ffffffff8119d10f>] ? debug_smp_processor_id+0x17/0x19
> [11455.551098]  [<ffffffffa0333cdc>] ieee80211_rx_napi+0x4bf/0x8e2 [mac80211]
> [11455.551119]  [<ffffffffa03acd99>] iwl_mvm_rx_rx_mpdu+0x6af/0x754 [iwlmvm]
> [11455.551134]  [<ffffffffa03a75be>] iwl_mvm_rx+0x44/0x6d [iwlmvm]
> [11455.551147]  [<ffffffffa02274c6>] iwl_pcie_rx_handle+0x461/0x5d5 [iwlwifi]
> [11455.551160]  [<ffffffffa022882a>] iwl_pcie_irq_handler+0x452/0x635 [iwlwifi]
> [11455.551167]  [<ffffffff8107797d>] ? irq_finalize_oneshot+0xc9/0xc9
> [11455.551172]  [<ffffffff81077995>] irq_thread_fn+0x18/0x2f
> [11455.551176]  [<ffffffff81077c1d>] irq_thread+0x108/0x1b0
> [11455.551183]  [<ffffffff8134338d>] ? __schedule+0x48d/0x58f
> [11455.551188]  [<ffffffff81077a82>] ? wake_threads_waitq+0x28/0x28
> [11455.551193]  [<ffffffff81077b15>] ? irq_thread_dtor+0x93/0x93
> [11455.551198]  [<ffffffff8104e913>] kthread+0xf3/0xfb
> [11455.551205]  [<ffffffff81347647>] ? _raw_spin_unlock_irq+0x27/0x45
> [11455.551212]  [<ffffffff81347fff>] ret_from_fork+0x1f/0x40
> [11455.551217]  [<ffffffff8104e820>] ? kthread_create_on_node+0x1ca/0x1ca
