From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG in skb_dequeue (skb->next is NULL) (was: Re: Kernel crash
 with 2.6.36)
Date: Wed, 01 Dec 2010 11:28:19 +0100
Message-ID: <1291199299.2856.499.camel@edumazet-laptop>
References: <alpine.LNX.2.00.1011071631550.2636@dyndns.pervalidus.net>
	 <loom.20101201T095252-592@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Simon Schubert <2@0x2c.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <loom.20101201T095252-592@post.gmane.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 01 d=C3=A9cembre 2010 =C3=A0 09:02 +0000, Simon Schubert a =
=C3=A9crit :
> Fr=C3=A9d=C3=A9ric L. W. Meunier <2 <at> pervalidus.net> writes:

CC netdev

>=20
> > Nov  7 16:21:23 pervalidus kernel: BUG: unable to handle kernel NUL=
L pointer=20
> dereference at (null)
>=20
> I can confirm the bug reported by Frederic.  The culprit is at:
>=20
>         next->prev =3D prev;
>=20
> in __skb_unlink().
>=20
> Something must be putting NULL pointers in the skb list.
>=20
> Let me know how I can be of further help.
>=20
>=20
> BUG: unable to handle kernel NULL pointer dereference at (null)
> IP: [<ffffffff81459069>] skb_dequeue+0x59/0x90
> PGD 208379067 PUD 20a523067 PMD 0=20
> Oops: 0002 [#1] SMP=20
> last sysfs file: /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_fre=
q
> CPU 1=20
> Modules linked in: binfmt_misc kvm_intel kvm ipt_MASQUERADE iptable_n=
at nf_nat=20
> xfrm_user nf_conntrack_ipv4 xfrm4_tunnel tunnel4 nf_conntrack ipcomp =
xfrm_ipcomp=20
> esp4 ah4 nf_defrag_ipv4 xt_TCPMSS xt_tcpmss xt_tcpudp iptable_mangle =
deflate=20
> ip_tables zlib_deflate ctr x_tables twofish_generic twofish_x86_64=20
> twofish_common camellia serpent blowfish cast5 des_generic xcbc rmd16=
0=20
> sha512_generic sha1_generic crypto_null af_key pppoe pppox xfs export=
fs=20
> snd_hda_codec_via snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss=20
> snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawm=
idi=20
> snd_seq_midi_event snd_seq snd_timer ftdi_sio snd_seq_device usbseria=
l hwmon_vid=20
> coretemp snd lp tpm_tis ppdev tpm parport_pc asus_atk0110 tpm_bios pa=
rport=20
> soundcore snd_page_alloc sha256_generic cryptd aes_x86_64 aes_generic=
 dm_crypt=20
> raid10 raid1 raid0 multipath linear raid456 async_pq async_xor xor as=
ync_memcpy=20
> async_raid6_recov raid6_pq async_tx fbcon tileblit font bitblit softc=
ursor usb
>=20
> Pid: 2229, comm: pulseaudio Not tainted 2.6.36 #10 P5Q-VM DO/System P=
roduct Name
> RIP: 0010:[<ffffffff81459069>]  [<ffffffff81459069>] skb_dequeue+0x59=
/0x90
> RSP: 0018:ffff880221927a78  EFLAGS: 00010097
> RAX: 0000000000000282 RBX: ffff88017a6d5e14 RCX: ffff88022236d200
> RDX: 0000000000000000 RSI: 0000000000000282 RDI: ffff88017a6d5e14
> RBP: ffff880221927a98 R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000293 R12: ffff88022236d200
> R13: ffff88017a6d5e00 R14: 0000000000000000 R15: 0000000000000000
> FS:  00007fedd4d9f740(0000) GS:ffff880001e80000(0000) knlGS:000000000=
0000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 0000000000000000 CR3: 000000020837a000 CR4: 00000000000006e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process pulseaudio (pid: 2229, threadinfo ffff880221926000, task=20
> ffff8802210096d0)
> Stack:
>  ffff88022236d200 ffff88022236d228 ffff88022236d200 ffff880221927f18
> <0> ffff880221927be8 ffffffff814ef0fa ffff880221927e4c ffff880221927e=
b4
> <0> 0000000000000040 ffff8802210096d0 ffff8802210096d0 ffff88017a6d5e=
a4
> Call Trace:
>  [<ffffffff814ef0fa>] unix_stream_recvmsg+0x1aa/0x790
>  [<ffffffff8145124d>] sock_recvmsg+0xfd/0x130
>  [<ffffffff81155fd0>] ? pollwake+0x0/0x60
>  [<ffffffff81452b54>] __sys_recvmsg+0x144/0x2e0
>  [<ffffffff81155fd0>] ? pollwake+0x0/0x60
>  [<ffffffff8104d88a>] ? finish_task_switch+0x4a/0xd0
>  [<ffffffff8154fa91>] ? schedule+0x411/0xa50
>  [<ffffffff81452f99>] sys_recvmsg+0x49/0x80
>  [<ffffffff8100b0b2>] system_call_fastpath+0x16/0x1b
> Code: e5 74 4f 4d 85 e4 74 26 41 83 6d 10 01 49 8b 0c 24 49 8b 54 24 =
08 49 c7 04=20
> 24 00 00 00 00 49 c7 44 24 08 00 00 00 00 48 89 51 08 <48> 89 0a 48 8=
9 c6 48 89=20
> df e8 39 93 0f 00 4c 89 e0 48 8b 5d e8=20
> RIP  [<ffffffff81459069>] skb_dequeue+0x59/0x90
>  RSP <ffff880221927a78>
> CR2: 0000000000000000
> ---[ end trace d4be3de9fdd70935 ]---
>=20
> cheers
>   simon
>=20
>=20

Is it reproductible ?

On previous kernel (say 2.6.35) you never hit this bug ?
