From: Eric B Munson <emunson@mgebm.net>
Subject: Re: 2.6.39-rc2 boot crash
Date: Wed, 6 Apr 2011 18:05:12 -0400
Message-ID: <20110406220512.GA2460@mgebm.net>
References: <20110406184753.GA7691@mgebm.net>
 <1302115953.8094.217.camel@nimitz>
 <20110406212041.GA2596@mgebm.net>
 <20110406.142157.68145422.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="WIyZ46R2i8wDzkSu"
Cc: dave@linux.vnet.ibm.com, linux-kernel@vger.kernel.org,
	kaber@trash.net, zbr@ioremap.net, gregkh@suse.de,
	ksrinivasan@novell.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110406.142157.68145422.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--WIyZ46R2i8wDzkSu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, 06 Apr 2011, David Miller wrote:

> From: Eric B Munson <emunson@mgebm.net>
> Date: Wed, 6 Apr 2011 17:20:41 -0400
>=20
> > A bisect points at commit 04f482faf50535229a5a5c8d629cf963899f857c for =
the
> > first bad one.  Unfortunately, I have not made netconsole work yet and =
the
> > hang is happening mostly right when X starts so I can't even see the co=
nsole.
> > I will keep at the netconsole and see if I can get it functioning, also=
 I will
> > try to boot this kernel in a VM and see if that helps.
>=20
> Patrick, please help Eric so we can fix this bug.
>=20
> Thanks.
>=20

I have a useful trace now from netconsole:

[   18.029521] BUG: sleeping function called from invalid context at arch/x=
86/mm/fault.c:1087
[   18.029527] in_atomic(): 0, irqs_disabled(): 1, pid: 2018, name: cgrules=
engd
[   18.029693] BUG: unable to handle kernel paging request at 0000100000000=
000
[   18.029730] IP: [<ffffffff814c3db8>] __skb_recv_datagram+0x128/0x2b0
[   18.029756] PGD 0=20
[   18.029768] Oops: 0002 [#1] SMP=20
[   18.029790] last sysfs file: /sys/devices/pci0000:00/0000:00:02.0/0000:0=
2:00.0/usb10/10-0:1.0/bInterfaceClass
[   18.029824] CPU 0=20
[   18.029833] Modules linked in: kvm_intel kvm parport_pc ppdev snd_hda_co=
dec_hdmi snd_hda_codec_realtek nfs lockd fscache auth_rpcgss nfs_acl sunrpc=
 radeon deflate zlib_deflate ctr twofish_generic twofish_x86_64 twofish_com=
mon ttm camellia serpent drm_kms_helper snd_usb_audio blowfish cast5 snd_hd=
a_intel drm des_generic snd_hda_codec snd_hwdep aesni_intel snd_usbmidi_lib=
 cryptd aes_x86_64 aes_generic snd_pcm xcbc snd_seq_midi rmd160 snd_rawmidi=
 sha512_generic sha256_generic uvcvideo snd_seq_midi_event sha1_generic snd=
_seq snd_timer crypto_null snd_seq_device snd af_key xhci_hcd i7core_edac v=
ideodev joydev psmouse edac_core v4l2_compat_ioctl32 w83627ehf soundcore se=
rio_raw hwmon_vid snd_page_alloc max6650 hid_microsoft i2c_algo_bit lp parp=
ort asus_atk0110 usbhid hid firewire_ohci firewire_core crc_itu_t
[   18.030424]=20
[   18.030432] Pid: 2018, comm: cgrulesengd Not tainted 2.6.39-rc2+ #52 Sys=
tem manufacturer System Product Name/P6X58D PREMIUM
[   18.030477] RIP: 0010:[<ffffffff814c3db8>]  [<ffffffff814c3db8>] __skb_r=
ecv_datagram+0x128/0x2b0
[   18.030510] RSP: 0018:ffff880326f03b28  EFLAGS: 00010002
[   18.030528] RAX: 0000000000000286 RBX: ffff8803204c5100 RCX: 00001000000=
00000
[   18.030552] RDX: ffff88031fe47200 RSI: ffff880326f03bf4 RDI: 00000000000=
00046
[   18.030576] RBP: ffff880326f03bd8 R08: 0000000000000000 R09: 00000000000=
00000
[   18.030599] R10: 0000000000000000 R11: 0000000000000001 R12: ffff880327d=
6e928
[   18.030623] R13: ffff880326f03b78 R14: ffff880326f03b90 R15: ffff880327d=
6e940
[   18.030646] FS:  00007f3bf9173b20(0000) GS:ffff880331600000(0000) knlGS:=
0000000000000000
[   18.030673] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   18.030693] CR2: 0000100000000000 CR3: 0000000326dda000 CR4: 00000000000=
006f0
[   18.030716] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 00000000000=
00000
[   18.030740] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 00000000000=
00400
[   18.030763] Process cgrulesengd (pid: 2018, threadinfo ffff880326f02000,=
 task ffff8803275aa300)
[   18.030794] Stack:
[   18.030803]  ffff880300000000 ffff8803275aa338 ffff880327d6ebd0 ffff8803=
275aa300
[   18.030839]  7fffffffffffffff ffff880326f03c74 ffff880326f03bf4 00000000=
00000001
[   18.030872]  ffff8803275aa300 ffff880327d6e940 00000000000001f7 00000000=
00000001
[   18.030905] Call Trace:
[   18.030916]  [<ffffffff81009833>] ? native_sched_clock+0x13/0x60
[   18.030936]  [<ffffffff814c3f64>] skb_recv_datagram+0x24/0x30
[   18.030956]  [<ffffffff814f463c>] netlink_recvmsg+0x7c/0x430
[   18.030975]  [<ffffffff814bc185>] ? sock_update_classid+0x65/0x100
[   18.030996]  [<ffffffff814bc19d>] ? sock_update_classid+0x7d/0x100
[   18.031016]  [<ffffffff814bc1c0>] ? sock_update_classid+0xa0/0x100
[   18.031037]  [<ffffffff814b7c1d>] sock_recvmsg+0xfd/0x130
[   18.031055]  [<ffffffff81178af8>] ? set_fd_set+0x48/0x60
[   18.031073]  [<ffffffff8117a25b>] ? core_sys_select+0x26b/0x330
[   18.031093]  [<ffffffff8117a03d>] ? core_sys_select+0x4d/0x330
[   18.031112]  [<ffffffff8108cc05>] ? lock_release_holdtime+0x35/0x160
[   18.031133]  [<ffffffff814b7da1>] sys_recvfrom+0xf1/0x170
[   18.031152]  [<ffffffff815d40ba>] ? sysret_check+0x2e/0x69
[   18.031171]  [<ffffffff812f02de>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[   18.031193]  [<ffffffff815d4082>] system_call_fastpath+0x16/0x1b
[   18.031212] Code: 41 5d 41 5e 41 5f c9 c3 eb 01 90 ff 8b 38 01 00 00 48 =
8b 1a 48 8b 4a 08 48 c7 02 00 00 00 00 48 c7 42 08 00 00 00 00 48 89 4b 08=
=20
[   18.031494]  89 19 eb aa eb 01 90 48 8b 83 f0 03 00 00 48 89 85 70 ff ff=
=20
[   18.031601] RIP  [<ffffffff814c3db8>] __skb_recv_datagram+0x128/0x2b0
[   18.031625]  RSP <ffff880326f03b28>
[   18.031637] CR2: 0000100000000000
[   18.039388] ---[ end trace 0e3e016130139f1b ]---
[   18.112703] BUG: unable to handle kernel NULL pointer dereference at    =
       (null)
[   18.112738] IP: [<ffffffff814befed>] skb_queue_tail+0x3d/0x60
[   18.112763] PGD 0=20
[   18.112775] Oops: 0002 [#2] SMP=20
[   18.112796] last sysfs file: /sys/devices/pci0000:00/0000:00:02.0/0000:0=
2:00.0/usb10/10-0:1.0/bInterfaceClass
[   18.112828] CPU 0=20
[   18.112837] Modules linked in: kvm_intel kvm parport_pc ppdev snd_hda_co=
dec_hdmi snd_hda_codec_realtek nfs lockd fscache auth_rpcgss nfs_acl sunrpc=
 radeon deflate zlib_deflate ctr twofish_generic twofish_x86_64 twofish_com=
mon ttm camellia serpent drm_kms_helper snd_usb_audio blowfish cast5 snd_hd=
a_intel drm des_generic snd_hda_codec snd_hwdep aesni_intel snd_usbmidi_lib=
 cryptd aes_x86_64 aes_generic snd_pcm xcbc snd_seq_midi rmd160 snd_rawmidi=
 sha512_generic sha256_generic uvcvideo snd_seq_midi_event sha1_generic snd=
_seq snd_timer crypto_null snd_seq_device snd af_key xhci_hcd i7core_edac v=
ideodev joydev psmouse edac_core v4l2_compat_ioctl32 w83627ehf soundcore se=
rio_raw hwmon_vid snd_page_alloc max6650 hid_microsoft i2c_algo_bit lp parp=
ort asus_atk0110 usbhid hid firewire_ohci firewire_core crc_itu_t
[   18.115476]=20
[   18.117533] Pid: 2178, comm: 0dns-down Tainted: G      D     2.6.39-rc2+=
 #52 System manufacturer System Product Name/P6X58D PREMIUM
[   18.119646] RIP: 0010:[<ffffffff814befed>]  [<ffffffff814befed>] skb_que=
ue_tail+0x3d/0x60
[   18.121757] RSP: 0018:ffff88032666bd08  EFLAGS: 00010096
[   18.123845] RAX: 0000000000000282 RBX: ffff880327d6e928 RCX: 000000000ac=
c7db8
[   18.125948] RDX: 0000000000000000 RSI: 0000000000000282 RDI: ffff880327d=
6e940
[   18.128046] RBP: ffff88032666bd28 R08: 0000000000000000 R09: 00000000000=
00001
[   18.130171] R10: 0000000000000000 R11: 0000000000000000 R12: ffff880327d=
6e940
[   18.132281] R13: ffff880320929b00 R14: ffff880327d6e818 R15: ffff880327d=
6e800
[   18.134388] FS:  0000000000000000(0000) GS:ffff880331600000(0000) knlGS:=
0000000000000000
[   18.136498] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[   18.138610] CR2: 0000000000000000 CR3: 0000000001a03000 CR4: 00000000000=
006f0
[   18.140732] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 00000000000=
00000
[   18.142839] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 00000000000=
00400
[   18.144953] Process 0dns-down (pid: 2178, threadinfo ffff88032666a000, t=
ask ffff880326f0a300)
[   18.147057] Stack:
[   18.149156]  ffff88032666bd28 0000000000000000 ffff88032a7fa800 00000000=
00000000
[   18.151256]  ffff88032666bdb8 ffffffff814f4d12 0000000000000000 ffff8803=
20929b00
[   18.153365]  ffff880327d6e84c ffff880320929bec 0000000026f0a300 00000000=
00000000
[   18.155464] Call Trace:
[   18.157539]  [<ffffffff814f4d12>] netlink_broadcast_filtered+0x322/0x480
[   18.159575]  [<ffffffff814f4e8d>] netlink_broadcast+0x1d/0x20
[   18.161568]  [<ffffffff813a0223>] cn_netlink_send+0x1a3/0x1c0
[   18.163515]  [<ffffffff813a044a>] proc_exit_connector+0xda/0x100
[   18.165538]  [<ffffffff81055a08>] do_exit+0x1d8/0x870
[   18.167428]  [<ffffffff810570fe>] ? sys_wait4+0xae/0x100
[   18.169287]  [<ffffffff812f0354>] ? lockdep_sys_exit_thunk+0x35/0x67
[   18.171133]  [<ffffffff810560fe>] do_group_exit+0x5e/0xd0
[   18.172965]  [<ffffffff81056187>] sys_exit_group+0x17/0x20
[   18.174782]  [<ffffffff815d4082>] system_call_fastpath+0x16/0x1b
[   18.176600] Code: 6d f8 0f 1f 44 00 00 49 89 f5 48 89 fb 4c 8d 67 18 4c =
89 e7 e8 65 c6 10 00 48 8b 53 08 4c 89 e7 49 89 5d 00 49 89 55 08 48 89 c6 =
<4c> 89 2a 4c 89 6b 08 ff 43 10 e8 54 cf 10 00 48 8b 5d e8 4c 8b=20
[   18.178889] RIP  [<ffffffff814befed>] skb_queue_tail+0x3d/0x60
[   18.180925]  RSP <ffff88032666bd08>
[   18.182948] CR2: 0000000000000000
[   18.184969] ---[ end trace 0e3e016130139f1c ]---
[   18.184972] Fixing recursive fault but reboot is needed!

I haven't dug into it at all, but I am happy to help test potential fixes.

Eric

--WIyZ46R2i8wDzkSu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJNnOOYAAoJEH65iIruGRnNLoQIAL6KI8h0jameMGq8WtS1UHB4
Iu6NbYjL7bxeO3Y03eOft6lt8pNLloeMvO90+lOsCyMVfWheo0G+OwwOk9JAeMKl
Lr1abqnguaRmXUmApi9ZllE4IRaOmAkK7HCG+HJIB77f2OkEyCEakhnPBJjJ+qNC
C8f4oYinLrNlKydikLcK2AWcNJ0WI1OHWXXmlPQ6nv4CU2RA1tG3ENKTteruEdvm
XKzbBJLCjqMD6+RlsaF+nXOh/6QPzvavj/S38bva3LtKFhbBJJHrxK0ebwnx4JUE
lrXlfOltqFy8YRV7YS6yyTiHtDbKUuVpJLaPVzpuKOGh6gmzZ8kEefgAdxa2M5w=
=uCed
-----END PGP SIGNATURE-----

--WIyZ46R2i8wDzkSu--
