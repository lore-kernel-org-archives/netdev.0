From: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Subject: Re: 2.6.33 dies on modprobe
Date: Mon, 1 Mar 2010 12:22:59 +0800
Message-ID: <2375c9f91002282022n29e83858jd8cadbb2e664b436@mail.gmail.com>
References: <20100228221257.GA8858@invalid>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: M G Berberich <berberic@fmi.uni-passau.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100228221257.GA8858@invalid>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 1, 2010 at 6:12 AM, M G Berberich
<berberic@fmi.uni-passau.de> wrote:
> Hello,
>
> I tried to build a 2.6.33 kernel but on boot it dies on modprobe
> (kernel-Oops). This might be the result of faulty config, but I'm
> totaly clueless what's the fault.
>
> The kernel starts up fine and mounts the root-filesystem, but then
> dies on the first modprobe executed. I can boot it with init=3D/bin/b=
ash
> and get a working bash (until I do modprobe on any module).
>
> System is a Gigabyte M55S-S3 rev 2.0 (nForce 550) with an AMD Athlon6=
4
> X2 5000+ and amd64-kernel architecture. kernel-sources are from
> kernel.org.
>
> =C2=A0 =C2=A0[...]
> =C2=A0 =C2=A0EXT4-fs (sda2): mounted filesystem with ordered data mod=
e
> =C2=A0 =C2=A0VFS: Mounted root (ext4 filesystem) readonly on device 8=
:2.
> =C2=A0 =C2=A0Freeing unused kernel memory: 408k freed
> =C2=A0 =C2=A0BUG: unable to handle kernel paging request at ffffffffa=
001b57f
> =C2=A0 =C2=A0IP: [<ffffffff811895db>] strcmp+0xb/0x30
> =C2=A0 =C2=A0PGD 1498067 PUD 149c063 PMD 12daf2067 PTE 0
> =C2=A0 =C2=A0Oops: 0000 [#1] SMP
> =C2=A0 =C2=A0last sysfs file: /sys/devices/pci0000:00/0000:00:05.0/ho=
st0/target0:0:0/0:0:0:0/
> =C2=A0 =C2=A0type
> =C2=A0 =C2=A0CPU 1
> =C2=A0 =C2=A0Pid: 1249, comm: modprobe Not tainted 2.6.33-bmg #1 M55S=
-S3/
> =C2=A0 =C2=A0[...]
>

You snipped too much. The full backtrace is useful:

BUG: unable to handle kernel paging request at ffffffffa001b57f
IP: [<ffffffff811895db>] strcmp+0xb/0x30
PGD 1498067 PUD 149c063 PMD 12daf2067 PTE 0
Oops: 0000 [#1] SMP
last sysfs file:
/sys/devices/pci0000:00/0000:00:05.0/host0/target0:0:0/0:0:0:0/type
CPU 1
Pid: 1249, comm: modprobe Not tainted 2.6.33-bmg #1 M55S-S3/
RIP: 0010:[<ffffffff811895db>]  [<ffffffff811895db>] strcmp+0xb/0x30
RSP: 0018:ffff88012ebe9e58  EFLAGS: 00010282
RAX: 0000000000000070 RBX: ffff88012f8f4f00 RCX: 00000000ffffffff
RDX: ffff88012f808800 RSI: ffffffffa001b57f RDI: ffff88012fab2420
RBP: ffff88012ebe9e58 R08: 0000000000000000 R09: 0000000000000000
R10: ffff8800284017c0 R11: dead000000200200 R12: ffff88012f9a29c8
R13: ffff88012f8842a0 R14: ffffffffa001b57f R15: 000000000081c050
=46S:  00007f16bd8916f0(0000) GS:ffff880028280000(0000) knlGS:000000000=
0000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: ffffffffa001b57f CR3: 000000012da7c000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process modprobe (pid: 1249, threadinfo ffff88012ebe8000, task ffff8801=
2edec0a0)
Stack:
 ffff88012ebe9e88 ffffffff811852e8 ffffffffa0013080 ffffffffa00130e0
<0> 000000000081e970 000000000081e970 ffff88012ebe9e98 ffffffff81236b87
<0> ffff88012ebe9ed8 ffffffff81236ca7 0000000000000021 0000000000000021
Call Trace:
 [<ffffffff811852e8>] kset_find_obj+0x38/0x80
 [<ffffffff81236b87>] driver_find+0x17/0x30
 [<ffffffff81236ca7>] driver_register+0x67/0x140
 [<ffffffff8119b771>] __pci_register_driver+0x51/0xd0
 [<ffffffffa0017000>] ? init_nic+0x0/0x20 [forcedeth]
 [<ffffffffa001701e>] init_nic+0x1e/0x20 [forcedeth]


It seems something is wrong with forcedeth code or PCI code.
Adding some Cc's.
