From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] sunrpc: use better NUMA affinities
Date: Sun, 31 Jul 2011 08:58:54 +0200
Message-ID: <1312095534.2873.108.camel@edumazet-laptop>
References: <1311921035.7845.10.camel@edumazet-laptop>
	 <4E3258E1.6020000@fastmail.fm> <20110729103634.GA12050@infradead.org>
	 <5933F48C-49D6-492D-AB7B-B76A3ADDB6C6@fastmail.fm>
	 <1311941491.2843.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <F67B6E82-9FA8-464E-B3FB-DC0D4EC18BB0@fastmail.fm>
	 <20110729164836.GL23194@fieldses.org> <20110729165345.GM23194@fieldses.org>
	 <F562C6F4-3FC2-4952-A903-8E87E9EF2D9D@fastmail.fm>
	 <20110730093025.716f3f50@notabene.brown>
	 <20110729234857.GA30941@fieldses.org>
	 <1311998914.2873.27.camel@edumazet-laptop>
	 <20110730160610.0b751ffd@notabene.brown>
	 <1312006990.2873.75.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Greg Banks <gnb-97jfqw80gc6171pxa8y+qA@public.gmane.org>,
	Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	"linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: NeilBrown <neilb-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1312006990.2873.75.camel@edumazet-laptop>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Le samedi 30 juillet 2011 =C3=A0 08:23 +0200, Eric Dumazet a =C3=A9crit=
 :
> Le samedi 30 juillet 2011 =C3=A0 16:06 +1000, NeilBrown a =C3=A9crit =
:
> > umount /proc/fs/nfsd
> >=20
> >=20
>=20
> Thans  a lot, this was the thing I missed !
>=20
>=20

Hmm, after this, I left things as the were (nfsd module loaded, but a 0
use count )

I got a BUG while updatedb was running,
(I tried this on a debian machine/kernel)

Same bug on :

cat /proc/self/mounts=20

I'll take a look at this issue later, after my vacations, unless someon=
e
wants to take a look before me ;)

[1020029.301174] BUG: unable to handle kernel paging request at fffffff=
fa03da0d0
[1020029.301318] IP: [<ffffffff811105bd>] show_type+0x17/0x5a
[1020029.301436] PGD 1605067 PUD 1609063 PMD 127353067 PTE 0
[1020029.301574] Oops: 0000 [#1] SMP=20
[1020029.301637] last sysfs file: /sys/module/nfsd/initstate
[1020029.301722] CPU 6=20
[1020029.301765] Modules linked in: nfsd fuse btrfs zlib_deflate crc32c=
 libcrc32c ufs qnx4 hfsplus hfs minix ntfs vfat msdos fat jfs xfs reise=
rfs ext4 jbd2 crc16 ext2 dm_mod nls_utf8 isofs lockd fscache auth_rpcgs=
s nfs_acl sunrpc loop i5000_edac radeon edac_core ttm drm_kms_helper sn=
d_pcm drm snd_timer snd i2c_algo_bit soundcore i2c_core snd_page_alloc =
i5k_amb power_supply ipmi_si evdev psmouse rng_core ipmi_msghandler hpi=
lo hpwdt shpchp processor button pcspkr serio_raw pci_hotplug container=
 ext3 jbd mbcache hpsa usbhid hid uhci_hcd cciss scsi_mod ehci_hcd usbc=
ore bnx2 thermal thermal_sys [last unloaded: nfsd]
[1020029.303561]=20
[1020029.303588] Pid: 23460, comm: updatedb.mlocat Tainted: G  R       =
   2.6.39-2-amd64 #1 HP ProLiant BL460c G1
[1020029.303751] RIP: 0010:[<ffffffff811105bd>]  [<ffffffff811105bd>] s=
how_type+0x17/0x5a
[1020029.303866] RSP: 0018:ffff880011da7e48  EFLAGS: 00010296
[1020029.303953] RAX: ffffffffa03da0d0 RBX: ffff8801288a4a80 RCX: 00000=
00000007774
[1020029.304061] RDX: ffffffff814c9935 RSI: ffff880129ea3800 RDI: ffff8=
801288a4a80
[1020029.304169] RBP: ffff880129ea3800 R08: ffff880011da7e68 R09: fffff=
fffffffffff
[1020029.304263] R10: ffff880011d883b2 R11: 0000000000000007 R12: ffff8=
8012794a2c0
[1020029.304263] R13: ffff8801288a4a80 R14: ffff88012794a338 R15: 00000=
00000000000
[1020029.304263] FS:  00007f9cf0dec700(0000) GS:ffff88012fd80000(0000) =
knlGS:0000000000000000
[1020029.304263] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[1020029.304263] CR2: ffffffffa03da0d0 CR3: 0000000058f90000 CR4: 00000=
000000006e0
[1020029.304263] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 00000=
00000000000
[1020029.304263] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 00000=
00000000400
[1020029.304263] Process updatedb.mlocat (pid: 23460, threadinfo ffff88=
0011da6000, task ffff88002741a440)
[1020029.304263] Stack:
[1020029.304263]  ffff8801288a4a80 ffff8801288a4a80 ffff88012794a338 ff=
ffffff81110abf
[1020029.304263]  ffff88012794a2c0 ffff88010d992440 0000000000000400 00=
007f9cf0df3000
[1020029.304263]  ffff880127960cc0 ffff8801288a4a80 ffff88012794a338 ff=
ffffff8111427a
[1020029.304263] Call Trace:
[1020029.304263]  [<ffffffff81110abf>] ? show_vfsmnt+0x9b/0x134
[1020029.304263]  [<ffffffff8111427a>] ? seq_read+0x276/0x350
[1020029.304263]  [<ffffffff810fc207>] ? vfs_read+0xa1/0xfb
[1020029.304263]  [<ffffffff810d8052>] ? sys_mmap_pgoff+0x127/0x15a
[1020029.304263]  [<ffffffff810fc317>] ? sys_read+0x45/0x6e
[1020029.304263]  [<ffffffff81338e52>] ? system_call_fastpath+0x16/0x1b
[1020029.304263] Code: 01 00 65 48 03 14 25 20 dc 00 00 66 ff 02 c3 f0 =
ff 47 38 c3 55 48 89 f5 48 c7 c2 35 99 4c 81 53 48 89 fb 48 83 ec 08 48=
 8b 46 28=20
[1020029.304263]  8b 30 e8 c7 36 00 00 48 8b 85 b8 02 00 00 48 85 c0 74=
 2b 80=20
[1020029.304263] RIP  [<ffffffff811105bd>] show_type+0x17/0x5a
[1020029.304263]  RSP <ffff880011da7e48>
[1020029.304263] CR2: ffffffffa03da0d0
[1020029.311417] ---[ end trace ebf19aff1e083659 ]---


--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
