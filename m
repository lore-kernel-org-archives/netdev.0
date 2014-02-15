From: John <da_audiophile@yahoo.com>
Subject: Re: [BUG] unable to handle kernel NULL pointer dereference
Date: Sat, 15 Feb 2014 12:08:37 -0800 (PST)
Message-ID: <1392494917.71728.YahooMailNeo@web140002.mail.bf1.yahoo.com>
References: <1392466251.41282.YahooMailNeo@web140003.mail.bf1.yahoo.com>
Reply-To: John <da_audiophile@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "da_audiophile@yahoo.com" <da_audiophile@yahoo.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"mlindner@marvell.com" <mlindner@marvell.com>
To: lkml <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1392466251.41282.YahooMailNeo@web140003.mail.bf1.yahoo.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> When booting into linux v3.13.3, I am unable to mount an nfs share on=
 this=A0

> particular hardware. =A0I get the same problem using v3.12.11. =A0Onl=
y the 3.10.x=20
> series allows normal operation. =A0Partial dmesg output shown inline,=
 additional=20
> logs available upon request.
>=20
> PLEASE cc me on my replies as I am not subscribed to lkml.
>=20
> Hardware: Athlon XP 3200+ on an NVIDIA nForce2 Ultra 400 motherboard.
> Distro: Arch Linux i686.
>=20
> % dmesg
> ...
> [ 137.616014] NFS: Registering the id_resolver key type
> [ 137.616036] Key type id_resolver registered
> [ 137.616038] Key type id_legacy registered
> [ 137.686758] BUG: unable to handle kernel NULL pointer dereference a=
t 00000858
> [ 137.689996] IP: [<f8aa2d99>] put_pipe_version+0x19/0x60 [auth_rpcgs=
s]
> [ 137.689996] *pde =3D 00000000=A0
> [ 137.689996] Oops: 0000 [#1] PREEMPT SMP=A0
> [ 137.689996] Modules linked in: rpcsec_gss_krb5 auth_rpcgss oid_regi=
stry nfsv4=20
> asb100 hwmon_vid snd_wavefront ir_mce_kbd_decoder ir_lirc_codec=20
> ir_rc5_sz_decoder ir_sony_decoder lirc_dev ir_rc5_decoder ir_jvc_deco=
der=20
> ir_sanyo_decoder ir_rc6_decoder ir_nec_decoder rc_streamzap streamzap=
 mousedev=20
> snd_cs4236 rc_core snd_intel8x0 snd_wss_lib snd_opl3_lib snd_hwdep=20
> snd_ac97_codec evdev snd_mpu401 ac97_bus snd_mpu401_uart snd_pcm snd_=
rawmidi=20
> snd_page_alloc snd_seq_device snd_timer snd pcspkr skge shpchp i2c_nf=
orce2=20
> i2c_core soundcore ns558 gameport processor button nvidia_agp agpgart=
 nfs lockd=20
> sunrpc fscache ext4 crc16 mbcache jbd2 hid_generic usbhid hid sr_mod =
cdrom=20
> sd_mod ata_generic pata_acpi sata_sil pata_amd libata ehci_pci ohci_p=
ci ohci_hcd=20
> ehci_hcd scsi_mod usbcore usb_common
> [ 137.689996] CPU: 0 PID: 534 Comm: rpc.gssd Not tainted 3.13.3-1-ARC=
H #1
> [ 137.689996] Hardware name: ASUSTeK Computer INC. A7N8X-E/A7N8X-E, B=
IOS ASUS=20
> A7N8X-E Deluxe ACPI BIOS Rev 1013 11/12/2004
> [ 137.689996] task: f4633210 ti: f568e000 task.ti: f568e000
> [ 137.689996] EIP: 0060:[<f8aa2d99>] EFLAGS: 00010202 CPU: 0
> [ 137.689996] EIP is at put_pipe_version+0x19/0x60 [auth_rpcgss]
> [ 137.689996] EAX: f4633210 EBX: 00000001 ECX: f56efca8 EDX: 00000296
> [ 137.689996] ESI: 00000000 EDI: f56efc00 EBP: f568fee8 ESP: f568fee0
> [ 137.689996] DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
> [ 137.689996] CR0: 8005003b CR2: 00000858 CR3: 34523000 CR4: 000007d0
> [ 137.689996] Stack:
> [ 137.689996] f56efc00 f6c64f78 f568fef4 f8aa2e05 00000010 f568ff40 f=
8aa3b38=20
> 00000374
> [ 137.689996] 00000080 b74dde40 f4644a80 f568ff30 00000246 f8ac1080 f=
fff41c9=20
> f6c64f78
> [ 137.689996] fffffff3 00000010 f4460140 f44d5820 f44d5810 f53df7ec f=
57595a0=20
> f8aa93e8
> [ 137.689996] Call Trace:
> [ 137.689996] [<f8aa2e05>] gss_release_msg+0x25/0x70 [auth_rpcgss]
> [ 137.689996] [<f8aa3b38>] gss_pipe_downcall+0x208/0x4b0 [auth_rpcgss=
]
> [ 137.689996] [<f8a2f9ab>] rpc_pipe_write+0x3b/0x60 [sunrpc]
> [ 137.689996] [<f8a2f970>] ? rpc_pipe_poll+0x90/0x90 [sunrpc]
> [ 137.689996] [<c1156bd5>] vfs_write+0x95/0x1c0
> [ 137.689996] [<c11572a1>] SyS_write+0x51/0x90
> [ 137.689996] [<c145cc0d>] sysenter_do_call+0x12/0x28
> [ 137.689996] Code: f8 e8 4f b8 9a c8 31 c0 eb c6 90 8d b4 26 00 00 0=
0 00 55 89=20
> e5 56 53 3e 8d 74 26 00 8b 1d 28 e9 a3 f8 89 c6 e8 59 64 5f c8 85 db =
<8b>=20
> 86 58 08 00 00 74 3a 3b 18 77 36 8b 5c 98 08 e8 32 66 5f c8
> [ 137.689996] EIP: [<f8aa2d99>] put_pipe_version+0x19/0x60 [auth_rpcg=
ss]=20
> SS:ESP 0068:f568fee0
> [ 137.689996] CR2: 0000000000000858
> [ 138.578433] ---[ end trace 3dcb8d5c35b64fbd ]---
> [ 142.979263] type=3D1006 audit(1392415950.632:4): pid=3D540 uid=3D0 =
old=20
> auid=3D4294967295 new auid=3D1000 old ses=3D4294967295 new ses=3D3 re=
s=3D1


I should add that if I test the same kernel version (v3.13.3 compiled f=
or i686) on a similar machine of the same vintage, there is not a probl=
em. =A0When I looked into the `lspci -v` output on the machine that has=
 the problems, I found that it seems to be related to the skge driver a=
s shown below; the similar machine that does not have the problem is us=
ing the forcedeth driver so I am hypothesizing that the error is with t=
he skge driver.

01:04.0 Ethernet controller: Marvell Technology Group Ltd. 88E8001 Giga=
bit Ethernet Controller (rev 13)
=A0 =A0 =A0 =A0 Subsystem: ASUSTeK Computer Inc. Marvell 88E8001 Gigabi=
t Ethernet Controller (Asus)
=A0 =A0 =A0 =A0 Flags: bus master, 66MHz, medium devsel, latency 32, IR=
Q 17
=A0 =A0 =A0 =A0 Memory at d5000000 (32-bit, non-prefetchable) [size=3D1=
6K]
=A0 =A0 =A0 =A0 I/O ports at a000 [size=3D256]
=A0 =A0 =A0 =A0 [virtual] Expansion ROM at 80080000 [disabled] [size=3D=
128K]
=A0 =A0 =A0 =A0 Capabilities: [48] Power Management version 2
=A0 =A0 =A0 =A0 Capabilities: [50] Vital Product Data
=A0 =A0 =A0 =A0 Kernel driver in use: skge
=A0 =A0 =A0 =A0 Kernel modules: skge
