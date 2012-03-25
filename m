From: "Justin P. Mattock" <justinmattock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: ath: DMA failed to stop in 10 ms AR_CR=0x00000024 AR_DIAG_SW=0x02000020
 DMADBG_7=0x00008040
Date: Sun, 25 Mar 2012 08:05:04 -0700
Message-ID: <4F6F3420.2070307@gmail.com>
References: <4F576FD5.2050208@gmail.com> <CAD2nsn23UqshHz1ZUn8bHN0rWyOMbBHhn9V8pmCc4_aT_uGYaw@mail.gmail.com> <4F577D9B.7020402@gmail.com> <4F579A88.6030503@openwrt.org> <4F61F551.5010608@gmail.com> <4F639851.5080500@gmail.com> <4F674616.8080103@gmail.com> <CAD2nsn3xpkGenrK50YmE5D7Odg3sBEek5zKcLZF6MAm69p5RJg@mail.gmail.com> <4F674FF5.2060406@gmail.com> <4F6751B2.1030809@openwrt.org> <4F681B78.9000207@gmail.com> <CAD2nsn0d-3edYGH8u+v5mhrUZBMsznDNRDkDHE-tErG8uGk84Q@mail.gmail.com> <4F68235C.5090701@gmail.com> <CAD2nsn0toAjyWw48J7oREES0=x6D72hMntP+WpAjHmR5drd-tQ@mail.gmail.com> <4F682555.3020502@gmail.com> <CAD2nsn2b9yVrX16m4Pc0F96PHF09ySv8ncY8Qnr7_9CC8hrbtA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux-netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Mohammed Shafi <shafi.wireless-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAD2nsn2b9yVrX16m4Pc0F96PHF09ySv8ncY8Qnr7_9CC8hrbtA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 03/20/2012 12:44 AM, Mohammed Shafi wrote:
>> /home/kernel/linux-next/drivers/net/wireless/ath/ath9k/ath9k.o...done.
>> (gdb) l *(ath_tx_start+0x284)
>> 0xcad4 is in ath_tx_start (drivers/net/wireless/ath/ath9k/xmit.c:1878).
>> 1873                    ieee80211_is_data_qos(hdr->frame_control)) {
>> 1874                    tidno = ieee80211_get_qos_ctl(hdr)[0]&
>> 1875                            IEEE80211_QOS_CTL_TID_MASK;
>> 1876                    tid = ATH_AN_2_TID(txctl->an, tidno);
>> 1877
>> 1878                    WARN_ON(tid->ac->txq != txctl->txq);
>> 1879            }
>> 1880
>> 1881            if ((tx_info->flags&  IEEE80211_TX_CTL_AMPDU)&&  tid) {
>> 1882                    /*
>> (gdb
>
> please check with the attached debug patch if tid is 'NULL'
>
>
> its my theory that tid is not initialized in ath_tx_node_init just after resume.
> during suspend ath9k_sta_remove may be called
> ieee80211_suspend ->  drv_sta_state ->
> drv_sta_remove->ath9k_sta_remove->ath_node_detach->ath_tx_node_cleanup
>
> during resume
>
> ieee80211_resume ->
> ieee80211_reconfig->drv_sta_state->ath9k_sta_add->ath_node_attach->ath_tx_node_init
>
> now sta.ht_cap.ht_supported should be true. it will be set to true in
> assoc_sucess path and then sta_add is called.
>
> let me see if i had missed something or my analysis itself is wrong.
>
>>
>
>
>


after a few days of running these patches I did not hit anything, then 
on a reboot I hit this. positive side though is I didnt loose internet 
connectivity altogether i.g. my music streaming stayed connected but 
internet surfing lost connection for a few seconds(30-40) then came back.

this is in dmesg..:

[   18.801995] ieee80211 phy0: Selected rate control algorithm 
'ath9k_rate_control'
[   18.803477] Registered led device: ath9k-phy0
[   18.803489] ieee80211 phy0: Atheros AR9285 Rev:2 mem=0xf8fa0000, irq=17
[   18.863699] input: ETPS/2 Elantech Touchpad as 
/devices/platform/i8042/serio1/input/input8
[   18.905167] HDMI status: Codec=3 Pin=5 Presence_Detect=0 ELD_Valid=0
[   18.905338] input: HDA Intel HDMI/DP,pcm=3 as 
/devices/pci0000:00/0000:00:1b.0/sound/card0/input9
[   22.178072] init: avahi-daemon main process (794) terminated with 
status 2
[   22.178116] init: avahi-daemon main process ended, respawning
[   22.515462] init: ufw pre-start process (503) terminated with status 1
[   22.523987] init: cups pre-start process (802) terminated with status 1
[   23.122716] init: Failed to spawn smbd main process: unable to 
execute: No such file or directory
[   23.146521] init: failsafe main process (907) killed by TERM signal
[   25.011529] ieee80211 phy0: device now idle
[   25.046220] r8169 0000:06:00.0: eth0: bmcr: 1000 bmsr: 7849 gbcr: 
0000 gbsr: 0000
[   25.046223] r8169 0000:06:00.0: eth0: link down
[   25.686361] ieee80211 phy0: device no longer idle - scanning
[   27.311270] ieee80211 phy0: device now idle
[   27.336454] ieee80211 phy0: device no longer idle - scanning
[   28.206726] wlan0: authenticate with 00:1e:2a:62:6b:1e
[   28.206800] ieee80211 phy0: Allocated STA 00:1e:2a:62:6b:1e
[   28.220206] ieee80211 phy0: Inserted STA 00:1e:2a:62:6b:1e
[   28.220211] wlan0: send auth to 00:1e:2a:62:6b:1e (try 1/3)
[   28.222300] wlan0: authenticated
[   28.222317] wlan0: moving STA 00:1e:2a:62:6b:1e to state 2
[   28.229855] wlan0: associate with 00:1e:2a:62:6b:1e (try 1/3)
[   28.232472] wlan0: RX AssocResp from 00:1e:2a:62:6b:1e (capab=0x31 
status=0 aid=5)
[   28.232479] wlan0: associated
[   28.232495] wlan0: moving STA 00:1e:2a:62:6b:1e to state 3
[   28.245788] wlan0: moving STA 00:1e:2a:62:6b:1e to state 4
[   31.910960] init: nmbd pre-start process (1192) terminated with 
status 127
[   32.110327] EXT4-fs (sda9): re-mounted. Opts: 
errors=remount-ro,commit=600
[   35.706391] init: plymouth-stop pre-start process (1295) terminated 
with status 1
[   38.315982] EXT4-fs (sda9): re-mounted. Opts: errors=remount-ro,commit=0
[   48.568651] EXT4-fs (sda9): re-mounted. Opts: 
errors=remount-ro,commit=600
[  941.868195] wlan0: detected beacon loss from AP - sending probe request
[  942.040883] ath: phy0: Failed to stop TX DMA, queues=0x005!
[  942.058737] ath: phy0: DMA failed to stop in 10 ms AR_CR=0x00000024 
AR_DIAG_SW=0x02000020 DMADBG_7=0x00006040
[  942.058749] ath: phy0: Could not stop RX, we could be confusing the 
DMA engine when we start RX up
[  942.058757] ------------[ cut here ]------------
[  942.058778] WARNING: at drivers/net/wireless/ath/ath9k/recv.c:531 
ath_stoprecv+0xfa/0x110 [ath9k]()
[  942.058785] Hardware name: 0914
[  942.058790] Modules linked in: dm_crypt xt_limit xt_tcpudp 
xt_addrtype joydev xt_state snd_hda_codec_hdmi snd_hda_codec_conexant 
arc4 ath9k snd_hda_intel mac80211 nf_conntrack_netbios_ns 
nf_conntrack_broadcast snd_hda_codec snd_hwdep nf_nat_ftp nf_nat snd_pcm 
nf_conntrack_ipv4 nf_defrag_ipv4 snd_seq_midi nf_conntrack_ftp 
nf_conntrack snd_rawmidi ath9k_common snd_seq_midi_event snd_seq 
snd_timer iptable_filter uvcvideo ath9k_hw ath lp parport cfg80211 
snd_seq_device snd ip_tables ideapad_laptop videobuf2_core soundcore 
snd_page_alloc x_tables psmouse sparse_keymap serio_raw videodev 
videobuf2_vmalloc videobuf2_memops intel_ips i915 drm_kms_helper drm 
i2c_algo_bit intel_agp intel_gtt r8169 agpgart video
[  942.058960] Pid: 65, comm: kworker/u:3 Not tainted 
3.3.0-next-20120322-00001-gba6003c #3
[  942.058967] Call Trace:
[  942.058987]  [<c10492c2>] warn_slowpath_common+0x72/0xa0
[  942.059003]  [<f8b0897a>] ? ath_stoprecv+0xfa/0x110 [ath9k]
[  942.059019]  [<f8b0897a>] ? ath_stoprecv+0xfa/0x110 [ath9k]
[  942.059030]  [<c1049312>] warn_slowpath_null+0x22/0x30
[  942.059045]  [<f8b0897a>] ath_stoprecv+0xfa/0x110 [ath9k]
[  942.059066]  [<f8b044cd>] ath_prepare_reset+0x5d/0xd0 [ath9k]
[  942.059082]  [<f8b05adc>] ath_reset_internal+0x6c/0x170 [ath9k]
[  942.059095]  [<c10abcab>] ? trace_hardirqs_on+0xb/0x10
[  942.059110]  [<f8b05c05>] ath_reset+0x25/0xb0 [ath9k]
[  942.059148]  [<c10abc14>] ? trace_hardirqs_on_caller+0xf4/0x180
[  942.059164]  [<f8b07407>] ath_reset_work+0x17/0x20 [ath9k]
[  942.059176]  [<c1068706>] process_one_work+0x166/0x5c0
[  942.059185]  [<c1068692>] ? process_one_work+0xf2/0x5c0
[  942.059199]  [<c12d546b>] ? do_raw_spin_lock+0x3b/0xf0
[  942.059219]  [<f8b073f0>] ? ath_isr+0x270/0x270 [ath9k]
[  942.059235]  [<c1068e74>] worker_thread+0x124/0x2c0
[  942.059245]  [<c1068d50>] ? rescuer_thread+0x1c0/0x1c0
[  942.059257]  [<c106dbed>] kthread+0x7d/0x90
[  942.059267]  [<c106db70>] ? __init_kthread_worker+0x60/0x60
[  942.059283]  [<c15a0082>] kernel_thread_helper+0x6/0x10
[  942.059286] ---[ end trace 6df3dcfe38b1fdb8 ]---
[  942.066296] ieee80211 phy0: wlan0: No ack for nullfunc frame to AP 
00:1e:2a:62:6b:1e, try 1/2
[  942.561934] ieee80211 phy0: wlan0: Failed to send nullfunc to AP 
00:1e:2a:62:6b:1e after 500ms, disconnecting.
[  942.566506] wlan0: moving STA 00:1e:2a:62:6b:1e to state 3
[  942.566514] wlan0: moving STA 00:1e:2a:62:6b:1e to state 2
[  942.566556] wlan0: moving STA 00:1e:2a:62:6b:1e to state 1
[  942.569979] ieee80211 phy0: Removed STA 00:1e:2a:62:6b:1e
[  942.570946] ieee80211 phy0: Destroyed STA 00:1e:2a:62:6b:1e
[  942.574474] ieee80211 phy0: device now idle
[  942.574743] cfg80211: All devices are disconnected, going to restore 
regulatory settings
[  942.574757] cfg80211: Restoring regulatory settings
[  942.574983] cfg80211: Calling CRDA to update world regulatory domain
[  942.585392] cfg80211: Ignoring regulatory request Set by core since 
the driver uses its own custom regulatory domain
[  942.585519] cfg80211: World regulatory domain updated:
[  942.585524] cfg80211:   (start_freq - end_freq @ bandwidth), 
(max_antenna_gain, max_eirp)
[  942.585530] cfg80211:   (2402000 KHz - 2472000 KHz @ 40000 KHz), (300 
mBi, 2000 mBm)
[  942.585536] cfg80211:   (2457000 KHz - 2482000 KHz @ 20000 KHz), (300 
mBi, 2000 mBm)
[  942.585541] cfg80211:   (2474000 KHz - 2494000 KHz @ 20000 KHz), (300 
mBi, 2000 mBm)
[  942.585546] cfg80211:   (5170000 KHz - 5250000 KHz @ 40000 KHz), (300 
mBi, 2000 mBm)
[  942.585552] cfg80211:   (5735000 KHz - 5835000 KHz @ 40000 KHz), (300 
mBi, 2000 mBm)
[  942.965150] ieee80211 phy0: device no longer idle - scanning
[  943.839899] wlan0: authenticate with 00:1e:2a:62:6b:1e
[  943.839961] ieee80211 phy0: Allocated STA 00:1e:2a:62:6b:1e
[  943.853169] ieee80211 phy0: Inserted STA 00:1e:2a:62:6b:1e
[  943.853178] wlan0: send auth to 00:1e:2a:62:6b:1e (try 1/3)
[  943.856967] wlan0: authenticated
[  943.856980] wlan0: moving STA 00:1e:2a:62:6b:1e to state 2
[  943.866660] wlan0: associate with 00:1e:2a:62:6b:1e (try 1/3)
[  943.869352] wlan0: RX AssocResp from 00:1e:2a:62:6b:1e (capab=0x31 
status=0 aid=5)
[  943.869362] wlan0: associated
[  943.869385] wlan0: moving STA 00:1e:2a:62:6b:1e to state 3
[  943.884712] wlan0: moving STA 00:1e:2a:62:6b:1e to state 4

Justin P. Mattock
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
