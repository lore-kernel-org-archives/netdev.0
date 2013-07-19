From: Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Subject: Re: v3.10/v3.11-rc1: mac80211/minstrel kernel crash
Date: Fri, 19 Jul 2013 13:36:45 +0200
Message-ID: <51E924CD.7000702@openwrt.org>
References: <20130718222113.GJ14385@blackmetal.musicnaut.iki.fi> <51E87A2F.5070305@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Aaro Koskinen <aaro.koskinen-X3B1VOXEql0@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <51E87A2F.5070305-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2013-07-19 1:28 AM, Larry Finger wrote:
> On 07/18/2013 05:21 PM, Aaro Koskinen wrote:
>> Hello,
>>
>> It seems this has been broken already a while, I bisected it back to
>> 06d961a8e210035bff7e82f466107f9ab4a8fd94 (mac80211/minstrel: use the
>> new rate control API).
>>
>> Test case:
>>
>> 	modprobe b43
>> 	ifconfig wlan0 up
>> 	iwlist wlan0 scanning
>>
>> Result:
>>
>> [   95.244268] b43-phy0: Broadcom 4318 WLAN found (core revision 9)
>> [   95.352823] b43-phy0: Found PHY: Analog 3, Type 2 (G), Revision 7
>> [   95.423298] ieee80211 phy0: Selected rate control algorithm 'minstrel'
>> [   95.438266] Broadcom 43xx driver loaded [ Features: PN ]
>> [   99.482832] b43-phy0: Loading firmware version 666.2 (2011-02-23 01:15:07)
>> [   99.522916] b43-pci-bridge 0001:01:01.0: Using 32-bit DMA via iommu
>> [  123.452854] Unable to handle kernel paging request for data at address 0x00000048
>> [  123.466119] Faulting instruction address: 0xc000000000673a1c
>> [  123.479072] Oops: Kernel access of bad area, sig: 11 [#1]
>> [  123.491678] PREEMPT PowerMac
>> [  123.503946] Modules linked in: b43 netconsole
>> [  123.515992] CPU: 0 PID: 490 Comm: kworker/u2:4 Not tainted 3.11.0-rc1-imac #1
>> [  123.527834] Workqueue: phy0 .ieee80211_scan_work
>> [  123.539275] task: c00000011a6bbdb0 ti: c00000011a120000 task.ti: c00000011a120000
>> [  123.551071] NIP: c000000000673a1c LR: c000000000653288 CTR: c0000000006739e0
>> [  123.563010] REGS: c00000011a123310 TRAP: 0300   Not tainted  (3.11.0-rc1-imac)
>> [  123.575142] MSR: 9000000000009032 <SF,HV,EE,ME,IR,DR,RI>  CR: 24002082  XER: 00000000
>> [  123.587884] SOFTE: 1
>> [  123.600276] DAR: 0000000000000048, DSISR: 40000000
>> [  123.612867]
>> GPR00: c000000000653288 c00000011a123590 c0000000009dba98 0000000000000000
>> GPR04: 0000000000000000 c00000011a123730 c00000011a123730 0000000000000000
>> GPR08: c00000011a162609 c0000000009d36d8 c0000000006739e0 c00000011a162600
>> GPR12: 0000000024002088 c00000000ffff000 c000000000077d90 c00000011a4dfa70
>> GPR16: 0000000000000000 0000000000000000 0000000000000001 0000000000000000
>> GPR20: 0000000000000000 0000000000000001 c00000000092df7f c00000011a355130
>> GPR24: 000000000000000a c00000011a123b60 c00000011a356660 c00000011a162600
>> GPR28: c00000011a461fc0 c00000011a162600 c00000011a123730 0000000000000000
>> [  123.728058] NIP [c000000000673a1c] .minstrel_get_rate+0x3c/0x2e0
>> [  123.740466] LR [c000000000653288] .rate_control_get_rate+0xf8/0x140
>> [  123.752720] Call Trace:
>> [  123.764951] [c00000011a123590] [c00000011a123620] 0xc00000011a123620 (unreliable)
>> [  123.777526] [c00000011a123630] [c000000000653288] .rate_control_get_rate+0xf8/0x140
>> [  123.790079] [c00000011a1236c0] [c000000000660ac8] .invoke_tx_handlers+0x8c8/0x14f0
>> [  123.802633] [c00000011a1237f0] [c000000000662304] .ieee80211_tx+0x84/0x140
>> [  123.815205] [c00000011a1238e0] [c000000000663c70] .__ieee80211_tx_skb_tid_band+0x70/0xa0
>> [  123.827893] [c00000011a123970] [c000000000669b70] .ieee80211_send_probe_req+0x100/0x150
>> [  123.840688] [c00000011a123a20] [c000000000645290] .ieee80211_scan_state_send_probe+0xc0/0x120
>> [  123.853578] [c00000011a123af0] [c00000000064624c] .ieee80211_scan_work+0x26c/0x530
>> [  123.866581] [c00000011a123bd0] [c00000000006ef5c] .process_one_work+0x17c/0x410
>> [  123.879178] [c00000011a123c70] [c00000000006fd80] .worker_thread+0x180/0x4d0
>> [  123.891354] [c00000011a123d40] [c000000000077e78] .kthread+0xe8/0xf0
>> [  123.903468] [c00000011a123e30] [c000000000008ea0] .ret_from_kernel_thread+0x5c/0xbc
>> [  123.915706] Instruction dump:
>> [  123.927916] fbe1fff8 fb61ffd8 fba1ffe8 f8010010 f821ff61 7cbf2b78 7c7c1b78 7cc53378
>> [  123.940781] 7c832378 7fe4fb78 7cde3378 eba60018 <8b7f0048> 4bfdec61 60000000 2fa30000
>> [  123.953961] ---[ end trace 5ead5367d5fdf880 ]---
>> [  123.966739]
>> [  124.969488] Kernel panic - not syncing: Fatal exception in interrupt
>> [  124.982408] Rebooting in 180 seconds..
> 
> Does it help if you enable CONFIG_MAC80211_RC_MINSTREL_HT and make it default? I 
> also have a PPC box with a PCMCIA-based BCM4318 and I do not see the problem 
> with those differences. The other difference that I see is that I use the LXDE 
> desktop and control the network with NetworkManager.
That bug is known, and Johannes already picked up my fix for it:
https://git.kernel.org/cgit/linux/kernel/git/jberg/mac80211.git/commit/?id=5c9fc93bc9bc417418fc1b6366833ae6a07b804d
Enabling CONFIG_MAC80211_RC_MINSTREL_HT will indeed completely get rid
of the crash.

- Felix
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
