From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ip_rt_bug route.c:1677 in 3.0
Date: Tue, 06 Sep 2011 23:01:11 +0200
Message-ID: <1315342871.3400.32.camel@edumazet-laptop>
References: <20110906204545.GA29628@tassilo.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:54100 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752436Ab1IFVBY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2011 17:01:24 -0400
Received: by wwf5 with SMTP id 5so6706788wwf.1
        for <netdev@vger.kernel.org>; Tue, 06 Sep 2011 14:01:23 -0700 (PDT)
In-Reply-To: <20110906204545.GA29628@tassilo.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 06 septembre 2011 =C3=A0 13:45 -0700, Andi Kleen a =C3=A9crit =
:
> FYI,
>=20
> My 3.0 workstation just spew:
>=20
> I wonder if a application could have caused this?
>=20
> ip_rt_bug: 10.7.201.108 -> 255.255.255.255, ?
> ------------[ cut here ]------------
> WARNING: at /home/ak/lsrc/git/linux-2.6/net/ipv4/route.c:1677 ip_rt_b=
ug+0x5f/0x70()
> Hardware name: ...
> Modules linked in: vfat fat nls_utf8 udf ses enclosure nfs lockd fsca=
che auth_rpcgss nfs_acl fuse sunrpc cpufreq_ondemand acpi_cpufreq freq_=
table mperf ipv6 kvm_intel kvm uinput snd_hda_codec_hdmi snd_hda_codec_=
realtek snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device sn=
d_pcm iTCO_wdt microcode e1000 snd_timer snd soundcore broadcom iTCO_ve=
ndor_support tg3 i7core_edac edac_core snd_page_alloc i2c_i801 dcdbas s=
erio_raw joydev pcspkr firewire_ohci firewire_core crc_itu_t usb_storag=
e radeon ttm drm_kms_helper drm i2c_algo_bit i2c_core [last unloaded: s=
csi_wait_scan]
> Pid: 28530, comm: xsane Not tainted 3.0.0+ #15
> Call Trace:
>  [<ffffffff810510ef>] warn_slowpath_common+0x7f/0xc0
>  [<ffffffff8105114a>] warn_slowpath_null+0x1a/0x20
>  [<ffffffff814946cf>] ip_rt_bug+0x5f/0x70
>  [<ffffffff8149f149>] ip_local_out+0x29/0x30
>  [<ffffffff814a047b>] ip_send_skb+0x1b/0x70
>  [<ffffffff814c25fa>] udp_send_skb+0x11a/0x3b0
>  [<ffffffff8149d3d0>] ? ip_setup_cork+0x170/0x170
>  [<ffffffff814c475c>] udp_sendmsg+0x37c/0x9b0
>  [<ffffffff814c31b9>] ? udp_lib_get_port+0x2a9/0x3e0
>  [<ffffffff81528d25>] ? _raw_spin_unlock_bh+0x15/0x20
>  [<ffffffff81448ca3>] ? release_sock+0xe3/0x110
>  [<ffffffff814ce214>] inet_sendmsg+0x64/0xb0
>  [<ffffffff81443e19>] sock_sendmsg+0xe9/0x120
>  [<ffffffff8111bb74>] ? handle_pte_fault+0x84/0x980
>  [<ffffffff8112be91>] ? free_pages_and_swap_cache+0xb1/0xe0
>  [<ffffffff812750cd>] ? cpumask_any_but+0x2d/0x40
>  [<ffffffff814464d1>] ? move_addr_to_kernel+0x71/0x80
>  [<ffffffff81446f39>] sys_sendto+0x139/0x190
>  [<ffffffff8144b20e>] ? sock_setsockopt+0x1ae/0x790
>  [<ffffffff811511ed>] ? fd_install+0x3d/0x70
>  [<ffffffff814471f3>] ? sys_setsockopt+0xb3/0xc0
>  [<ffffffff8153092b>] system_call_fastpath+0x16/0x1b
> ---[ end trace ada1d01fefb0d73c ]---
> ip_rt_bug: 10.7.201.108 -> 255.255.255.255, ?
> ------------[ cut here ]------------
> WARNING: at /home/ak/lsrc/git/linux-2.6/net/ipv4/route.c:1677 ip_rt_b=
ug+0x5f/0x70()
> Hardware name: ...
> Modules linked in: vfat fat nls_utf8 udf ses enclosure nfs lockd fsca=
che auth_rpcgss nfs_acl fuse sunrpc cpufreq_ondemand acpi_cpufreq freq_=
table mperf ipv6 kvm_intel kvm uinput snd_hda_codec_hdmi snd_hda_codec_=
realtek snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device sn=
d_pcm iTCO_wdt microcode e1000 snd_timer snd soundcore broadcom iTCO_ve=
ndor_support tg3 i7core_edac edac_core snd_page_alloc i2c_i801 dcdbas s=
erio_raw joydev pcspkr firewire_ohci firewire_core crc_itu_t usb_storag=
e radeon ttm drm_kms_helper drm i2c_algo_bit i2c_core [last unloaded: s=
csi_wait_scan]
> Pid: 28530, comm: xsane Tainted: G        W   3.0.0+ #15
> Call Trace:
>  [<ffffffff810510ef>] warn_slowpath_common+0x7f/0xc0
>  [<ffffffff8105114a>] warn_slowpath_null+0x1a/0x20
>  [<ffffffff814946cf>] ip_rt_bug+0x5f/0x70
>  [<ffffffff8149f149>] ip_local_out+0x29/0x30
>  [<ffffffff814a047b>] ip_send_skb+0x1b/0x70
>  [<ffffffff814c25fa>] udp_send_skb+0x11a/0x3b0
>  [<ffffffff8149d3d0>] ? ip_setup_cork+0x170/0x170
>  [<ffffffff814c475c>] udp_sendmsg+0x37c/0x9b0
>  [<ffffffff814c31b9>] ? udp_lib_get_port+0x2a9/0x3e0
>  [<ffffffff81528d25>] ? _raw_spin_unlock_bh+0x15/0x20
>  [<ffffffff81448ca3>] ? release_sock+0xe3/0x110
>  [<ffffffff814ce214>] inet_sendmsg+0x64/0xb0
>  [<ffffffff81443e19>] sock_sendmsg+0xe9/0x120
> ...
>=20
>=20


Make sure you have this commit=20

commit d547f727df86059104af2234804fdd538e112015
Author: Julian Anastasov <ja@ssi.bg>
Date:   Sun Aug 7 22:20:20 2011 -0700

    ipv4: fix the reusing of routing cache entries
   =20
        compare_keys and ip_route_input_common rely on
    rt_oif for distinguishing of input and output routes
    with same keys values. But sometimes the input route has
    also same hash chain (keyed by iif !=3D 0) with the output
    routes (keyed by orig_oif=3D0). Problem visible if running
    with small number of rhash_entries.
   =20
        Fix them to use rt_route_iif instead. By this way
    input route can not be returned to users that request
    output route.
   =20
        The patch fixes the ip_rt_bug errors that were
    reported in ip_local_out context, mostly for 255.255.255.255
    destinations.
   =20
