From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG] af_unix race in close?
Date: Thu, 24 Sep 2009 06:35:51 +0200
Message-ID: <4ABAF727.8060905@gmail.com>
References: <20090923165421.60e0d49c@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Jike Song <albcamus@gmail.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:58673 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751174AbZIXEfw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2009 00:35:52 -0400
In-Reply-To: <20090923165421.60e0d49c@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
> This oops seems to show lots of times:
> http://www.kerneloops.org/guilty.php?guilty=3Dunix_write_space&versio=
n=3D2.6.31-release&start=3D2064384&end=3D2097151&class=3Doops
> Looks like race in unix domain socket close with data outstanding.
>=20
> BUG: unable to handle kernel paging request at 6b6b6b8f
> IP: [] unix_write_space+0x45/0x87
> *pde =3D 00000000=20
> Oops: 0000 [#1] SMP=20
> last sysfs file: /sys/devices/LNXSYSTM:00/device:00/PNP0C0A:00/power_=
supply/BAT1/charge_full
> Modules linked in: ext2 fuse nfsd lockd nfs_acl auth_rpcgss exportfs =
sunrpc ip6t_REJECT nf_conntrack_ipv6 ip6table_filter ip6_tables ipv6 cp=
ufreq_ondemand acpi_cpufreq dm_multipath uinput uvcvideo videodev v4l1_=
compat arc4 snd_hda_codec_realtek iTCO_wdt iTCO_vendor_support ecb seri=
o_raw i2c_i801 snd_hda_intel joydev snd_hda_codec snd_hwdep snd_pcm snd=
_timer ath5k r8169 snd mac80211 mii soundcore ath snd_page_alloc jmb38x=
_ms cfg80211 memstick rfkill wmi squashfs vfat fat mmc_block i915 sdhci=
_pci ata_generic pata_acpi sdhci mmc_core drm i2c_algo_bit i2c_core usb=
_storage video output [last unloaded: microcode]
>=20
> Pid: 6809, comm: metacity Not tainted (2.6.31-0.125.4.2.rc5.git2.fc12=
=2Ei686 #1) AOA110
> EIP: 0060:[] EFLAGS: 00010202 CPU: 0
> EIP is at unix_write_space+0x45/0x87
> EAX: 6b6b6b6b EBX: ec988780 ECX: 00000000 EDX: 6b6b6b8f
> ESI: ec988950 EDI: ffffff20 EBP: ec941e28 ESP: ec941e1c
>  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
> Process metacity (pid: 6809, ti=3Dec940000 task=3De63095c0 task.ti=3D=
ec940000)
> Stack:
>  37dc7803 ec988780 000000e1 ec941e40 c0772142 37dc7803 dcc1c900 dcc1c=
900
> <0> c07f6a02 ec941e50 c0775766 37dc7803 dcc1c900 ec941e60 c07754ae 37=
dc7803
> <0> dcc1c900 ec941e78 c07755db 37dc7803 ec98b0c0 dcc1c900 00000000 ec=
941ea0
> Call Trace:
>  [] ? sock_wfree+0x44/0x68
>  [] ? unix_release_sock+0x182/0x1e0
>  [] ? skb_release_head_state+0x6c/0xcb
>  [] ? __kfree_skb+0x20/0x94
>  [] ? kfree_skb+0x68/0x7f
>  [] ? unix_release_sock+0x182/0x1e0
>  [] ? unix_release+0x2f/0x42
>  [] ? sock_release+0x29/0x7f
>  [] ? sock_close+0x30/0x45
>  [] ? __fput+0x101/0x1a2
>  [] ? fput+0x27/0x3a
>  [] ? filp_close+0x64/0x7f
>  [] ? put_files_struct+0x68/0xbd
>  [] ? exit_files+0x43/0x59
>  [] ? do_exit+0x1d6/0x648
>  [] ? audit_syscall_entry+0x134/0x167
>  [] ? do_group_exit+0x72/0x99
>  [] ? sys_exit_group+0x27/0x3c
>  [] ? syscall_call+0x7/0xb
> Code: 00 89 45 f4 31 c0 89 f0 e8 9a 76 02 00 8b 83 dc 00 00 00 c1 e0 =
02 3b 83 e4 00 00 00 7f 32 8b 83 a4 00 00 00 85 c0 74 17 8d 50 24 <39> =
50 24 74 0f b9 01 00 00 00 ba 01 00 00 00 e8 bb cf c3 ff b9=20
> EIP: [] unix_write_space+0x45/0x87 SS:ESP 0068:ec941e1c
> CR2: 000000006b6b6b8f
> ---[ end trace 4a36bd1eb2fc9896 ]---
>=20

Hello Stephen

I already took a look at the problem, and I re-sent possible fix for th=
is yesterday

http://patchwork.ozlabs.org/patch/34162/

=46irst reporter I am aware of was Jike Song

Thanks
