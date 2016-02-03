From: Josh Boyer <jwboyer-rxtnV0ftBwyoClj4AeEUq9i2O/JbrIOy@public.gmane.org>
Subject: Re: ibss.c backtrace when batman-adv adds wireless interface
Date: Wed, 3 Feb 2016 10:26:50 -0500
Message-ID: <CA+5PVA55MSh-kKCLGcUV2uMkx+SqwuXY0WbONS8Q0mxh4+_gcw@mail.gmail.com>
References: <CA+5PVA4HVjsEw+j+HMDzO0gnQb4xTRwbAu4H2do3MU41QWvOvw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CA+5PVA4HVjsEw+j+HMDzO0gnQb4xTRwbAu4H2do3MU41QWvOvw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 3, 2016 at 10:24 AM, Josh Boyer <jwboyer-rxtnV0ftBwyoClj4AeEUq9i2O/JbrIOy@public.gmane.org> wrote:
> Hi All,
>
> We've had a user report the backtrace below when loading batman-adv on
> his machine.  It looks like the cfg80211 layer is complaining about a
> null bss returned, but I cannot tell if the rtlwifi driver or
> batman-adv is in error here.
>
> Thoughts?

Sorry, forgot to include the link to the actual bug report:

https://bugzilla.redhat.com/show_bug.cgi?id=1304428

Reporter says this is new with 4.3.y and did not happen on e.g. 4.2.8.


josh

>
> Jan 28 22:29:21 melissa.gathman.org kernel: batman_adv: B.A.T.M.A.N.
> advanced 2015.2 (compatibility version 15) loaded
> Jan 28 22:29:21 melissa.gathman.org kernel: wlp0s26u1u4: Selected IBSS
> BSSID 02:1a:a0:3a:a6:ff based on configured SSID
> Jan 28 22:29:21 melissa.gathman.org kernel: ------------[ cut here ]------------
> Jan 28 22:29:21 melissa.gathman.org kernel: WARNING: CPU: 1 PID: 111
> at net/wireless/ibss.c:35 __cfg80211_ibss_joined+0x166/0x190
> [cfg80211]()
> Jan 28 22:29:21 melissa.gathman.org kernel: Modules linked in:
> batman_adv libcrc32c xt_CHECKSUM ipt_MASQUERADE nf_nat_masquerade_ipv4
> nf_conntrack_netbios_ns nf_conntrack_broadcast ip6t_rpfilter
> ip6t_REJECT nf_reject_ipv6 xt_conntrack tun ebtable_filter ebtable_nat
> ebtable_broute bridge stp llc ebtables ip6table_mangle ip6table_nat
> nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_raw
> ip6table_security ip6table_filter ip6_tables iptable_mangle
> iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat
> nf_conntrack iptable_raw iptable_security arc4 rtl8192cu rtl_usb
> rtl8192c_common rtlwifi mac80211 cfg80211 rfkill uvcvideo
> videobuf2_vmalloc videobuf2_core videobuf2_memops v4l2_common
> intel_rapl snd_hda_codec_hdmi snd_usb_audio joydev snd_usbmidi_lib
> snd_hda_codec_realtek iosf_mbi x86_pkg_temp_thermal videodev coretemp
> kvm_intel
> Jan 28 22:29:21 melissa.gathman.org kernel:  media snd_rawmidi cm109
> snd_hda_codec_generic kvm snd_hda_intel iTCO_wdt snd_hda_codec
> iTCO_vendor_support crct10dif_pclmul snd_hda_core ppdev snd_hwdep
> snd_seq snd_seq_device snd_pcm crc32_pclmul crc32c_intel snd_timer snd
> dcdbas lpc_ich mei_me parport_pc parport shpchp i2c_i801 mei tpm_tis
> tpm soundcore nfsd auth_rpcgss nfs_acl lockd grace sunrpc
> hid_microsoft i915 i2c_algo_bit drm_kms_helper drm e1000e serio_raw
> ptp pps_core fjes video
> Jan 28 22:29:21 melissa.gathman.org kernel: CPU: 1 PID: 111 Comm:
> kworker/u32:5 Not tainted 4.3.3-301.fc23.x86_64 #1
> Jan 28 22:29:21 melissa.gathman.org kernel: Hardware name: Dell Inc.
> OptiPlex 790/0HY9JP, BIOS A06 07/25/2011
> Jan 28 22:29:21 melissa.gathman.org kernel: Workqueue: cfg80211
> cfg80211_event_work [cfg80211]
> Jan 28 22:29:21 melissa.gathman.org kernel:  0000000000000000
> 000000008beeeb5f ffff8800368bfce0 ffffffff813a626f
> Jan 28 22:29:21 melissa.gathman.org kernel:  0000000000000000
> ffff8800368bfd18 ffffffff810a07c2 ffff8800c2bc8850
> Jan 28 22:29:21 melissa.gathman.org kernel:  ffff8800c2bc8000
> ffff8801275bd558 0000000000000000 0000000000000286
> Jan 28 22:29:21 melissa.gathman.org kernel: Call Trace:
> Jan 28 22:29:21 melissa.gathman.org kernel:  [<ffffffff813a626f>]
> dump_stack+0x44/0x55
> Jan 28 22:29:21 melissa.gathman.org kernel:  [<ffffffff810a07c2>]
> warn_slowpath_common+0x82/0xc0
> Jan 28 22:29:21 melissa.gathman.org kernel:  [<ffffffff810a090a>]
> warn_slowpath_null+0x1a/0x20
> Jan 28 22:29:21 melissa.gathman.org kernel:  [<ffffffffa05dfcd6>]
> __cfg80211_ibss_joined+0x166/0x190 [cfg80211]
> Jan 28 22:29:21 melissa.gathman.org kernel:  [<ffffffffa05bb02c>]
> cfg80211_process_wdev_events+0x8c/0x190 [cfg80211]
> Jan 28 22:29:21 melissa.gathman.org kernel:  [<ffffffffa05bb162>]
> cfg80211_process_rdev_events+0x32/0x70 [cfg80211]
> Jan 28 22:29:21 melissa.gathman.org kernel:  [<ffffffffa05b601e>]
> cfg80211_event_work+0x1e/0x30 [cfg80211]
> Jan 28 22:29:21 melissa.gathman.org kernel:  [<ffffffff810b8cde>]
> process_one_work+0x19e/0x3f0
> Jan 28 22:29:21 melissa.gathman.org kernel:  [<ffffffff810b8f7e>]
> worker_thread+0x4e/0x450
> Jan 28 22:29:21 melissa.gathman.org kernel:  [<ffffffff810b8f30>] ?
> process_one_work+0x3f0/0x3f0
> Jan 28 22:29:21 melissa.gathman.org kernel:  [<ffffffff810bede8>]
> kthread+0xd8/0xf0
> Jan 28 22:29:21 melissa.gathman.org kernel:  [<ffffffff810bed10>] ?
> kthread_worker_fn+0x160/0x160
> Jan 28 22:29:21 melissa.gathman.org kernel:  [<ffffffff8178195f>]
> ret_from_fork+0x3f/0x70
> Jan 28 22:29:21 melissa.gathman.org kernel:  [<ffffffff810bed10>] ?
> kthread_worker_fn+0x160/0x160
> Jan 28 22:29:21 melissa.gathman.org kernel: ---[ end trace 04ee7067960ce525 ]---
> Jan 28 22:29:21 melissa.gathman.org kernel: batman_adv: bat0: Adding
> interface: wlp0s26u1u4
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
