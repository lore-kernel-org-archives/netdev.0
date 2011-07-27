From: hubert Liao <liao.hubertt@gmail.com>
Subject: Oops when insmod rtl8192ce
Date: Wed, 27 Jul 2011 17:26:50 +0800
Message-ID: <CAMzZzFGpDiFAhsLAb+SQxjbGMzBoOStF_Lr7Eb3PT6Drcf=VdA@mail.gmail.com>
References: <CAMzZzFGqPv6Nbw8J8JGNKcLA76sAs3oD6+hH9NPCjwA33fYpOQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f171.google.com ([209.85.215.171]:47580 "EHLO
	mail-ey0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754036Ab1G0J0w convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jul 2011 05:26:52 -0400
In-Reply-To: <CAMzZzFGqPv6Nbw8J8JGNKcLA76sAs3oD6+hH9NPCjwA33fYpOQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
We got an oops when insmod rtl8192ce module (the board is an ARM soc),
accroding the oops message, find it's because in rtl_pci_probe()
called _rtl_pci_find_adapter(),
in this funcation, the =A0pdev->bus->self is a NULL pointer .
static boot _rtl_pci_find_adapter(strcut pci_dev *dev,
=A0 =A0 =A0 =A0 =A0 =A0 =A0 struct ieee80211_hw *hw)
{
struct pci_dev *bridge_pdev =3D pdev->bus->self; =A0 //line 1601
=2E..
pcipriv->ndis_adapter.pcibridge_vendorid =3D bridge_pdev->vendor; <--
[oops here] line 1700
=2E..
}
here, I just want to know why the bus->self =A0is NULL?
----
[ =A0148.186632] Unable to handle kernel NULL pointer dereference at
virtual address 00000020
[ =A0148.195255] pgd =3D cfb40000
[ =A0148.198178] [00000020] *pgd=3D0e54d831, *pte=3D00000000, *ppte=3D0=
0000000
[ =A0148.204743] Internal error: Oops: 17 [#1] PREEMPT
[ =A0148.209426] Modules linked in: rtl8192ce(+) rtl8192c_common rtlwif=
i
[ =A0148.215702] CPU: 0 =A0 =A0Not tainted =A0(3.0.0-05684-ge371d46 #34=
)
[ =A0148.221453] PC is at rtl_pci_probe+0x398/0x1bd8 [rtlwifi]
[ =A0148.226827] LR is at 0x4
[ =A0148.229356] pc : [<bf00fdc0>] =A0 =A0lr : [<00000004>] =A0 =A0psr:=
 80000013
[ =A0148.229364] sp : cfb37d10 =A0ip : bf012606 =A0fp : ce518dc0
[ =A0148.240800] r10: ce51abbc =A0r9 : 00008178 =A0r8 : cf807000
[ =A0148.246001] r7 : 00004000 =A0r6 : 00000000 =A0r5 : 00000000 =A0r4 =
: 1fff7fff
[ =A0148.252498] r3 : 0000037c =A0r2 : 00000000 =A0r1 : bf012584 =A0r0 =
: 00000000
[ =A0148.258997] Flags: Nzcv =A0IRQs on =A0FIQs on =A0Mode SVC_32 =A0IS=
A ARM =A0Segment user
[ =A0148.266108] Control: 0005397f =A0Table: 0fb40000 =A0DAC: 00000015
[ =A0148.271826] Process insmod (pid: 650, stack limit =3D 0xcfb36270)
[ =A0148.277718] Stack: (0xcfb37d10 to 0xcfb38000)
[ =A0148.282061] 7d00: =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 00000000
c018928c 00000000 ce54f870
[ =A0148.290212] 7d20: 00000001 cf804680 bf012584 ce518240 ce518dc0
ce51abbc cf807060 000010ec
[ =A0148.298368] 7d40: 00000000 ce54f810 cfb37d90 c00f2194 00000000
000012c7 cfb37d90 ce54f810
[ =A0148.306524] 7d60: cfb37d90 c00f22f8 00000109 01000000 cfb37d90
bf043c80 cf807000 00000000
[ =A0148.314672] 7d80: bf043c50 cfa7df00 c054ba00 bf043c80 bf049000
c01a8d80 bf043c80 c01a901c
[ =A0148.322828] 7da0: cf807068 bf043c50 cf807000 bf0439b0 bf043c80
cf807060 cf807060 bf043c80
[ =A0148.330984] 7dc0: c01dce54 c01dcd04 cf807060 cf807094 bf043c80
c01dce54 cfa7df00 c04bb780
[ =A0148.339140] 7de0: 00000000 c01dcee0 00000000 cfb37df8 bf043c80
c01dc4f8 cf805c38 cf87c810
[ =A0148.347296] 7e00: bf043c50 cf81cb00 bf043c80 bf043c80 c04a4f0c
c01dbd00 bf0437ac 00000000
[ =A0148.355452] 7e20: bf043c50 bf043c50 bf043c80 bf043c80 c04a4f0c
cfb36000 c004e388 c01dd284
[ =A0148.363609] 7e40: bf043c50 cfb0c540 bf043c80 c04a4f0c cfb36000
c01a92dc 00000001 cfb0c540
[ =A0148.371765] 7e60: 00000001 bf04642c cfb36000 bf049014 00000001
c0008578 c004e460 c037204c
[ =A0148.379920] 7e80: c049d93c 00000000 bf04642c ffffffff 00000001
c003d1f8 00000000 ce51e240
[ =A0148.388069] 7ea0: 00000001 00000001 cfb0c540 00000001 bf04642c
00000010 bf046474 c004e388
[ =A0148.396225] 7ec0: c004e460 c004f62c bf046438 00000001 cfb36000
bf046438 d0c0d6da d0bcbcfc
[ =A0148.404381] 7ee0: bf046550 c03786cc d0ad7000 00136709 d0bcb554
d0bcb368 d0c0c554 cfa6a800
[ =A0148.412536] 7f00: 0001156c 0001225c 00000000 00000000 00000031
00000032 00000018 00000000
[ =A0148.420683] 7f20: 00000010 00000000 776c7472 00696669 00000000
00000000 00000000 00000000
[ =A0148.428831] 7f40: 00000000 00000000 00000000 00000000 00000000
00000000 00000000 00000000
[ =A0148.436978] 7f60: 00000000 00000000 00000000 00000000 00000000
00000000 00000000 c009b170
[ =A0148.445127] 7f80: 00000003 40085000 bedf0db4 00000069 00000080
c0008ec4 cfb36000 00000000
[ =A0148.453283] 7fa0: 00000000 c0008d40 40085000 bedf0db4 40389008
00136709 000b72df 00000000
[ =A0148.461439] 7fc0: 40085000 bedf0db4 00000069 00000080 bedf0db8
000b72df bedf0db8 00000000
[ =A0148.469587] 7fe0: 00000001 bedf0a5c 0001c7e8 40326ac4 60000010
40389008 00000000 00000000
[ =A0148.477783] [<bf00fdc0>] (rtl_pci_probe+0x398/0x1bd8 [rtlwifi])
from [<c01a8d80>] (local_pci_probe+0x18/0x1c)
[ =A0148.487677] [<c01a8d80>] (local_pci_probe+0x18/0x1c) from
[<c01a901c>] (pci_device_probe+0x6c/0x90)
[ =A0148.496701] [<c01a901c>] (pci_device_probe+0x6c/0x90) from
[<c01dcd04>] (driver_probe_device+0x80/0x1d0)
[ =A0148.506156] [<c01dcd04>] (driver_probe_device+0x80/0x1d0) from
[<c01dcee0>] (__driver_attach+0x8c/0x90)
[ =A0148.515521] [<c01dcee0>] (__driver_attach+0x8c/0x90) from
[<c01dc4f8>] (bus_for_each_dev+0x60/0x94)
[ =A0148.524541] [<c01dc4f8>] (bus_for_each_dev+0x60/0x94) from
[<c01dbd00>] (bus_add_driver+0xa0/0x25c)
[ =A0148.533561] [<c01dbd00>] (bus_add_driver+0xa0/0x25c) from
[<c01dd284>] (driver_register+0x6c/0x154)
[ =A0148.542581] [<c01dd284>] (driver_register+0x6c/0x154) from
[<c01a92dc>] (__pci_register_driver+0x38/0xa8)
[ =A0148.552148] [<c01a92dc>] (__pci_register_driver+0x38/0xa8) from
[<bf049014>] (rtl92ce_module_init+0x14/0x58 [rtl8192ce])
[ =A0148.563007] [<bf049014>] (rtl92ce_module_init+0x14/0x58
[rtl8192ce]) from [<c0008578>] (do_one_initcall+0x34/0x19c)
[ =A0148.573413] [<c0008578>] (do_one_initcall+0x34/0x19c) from
[<c004f62c>] (sys_init_module+0xf4/0x13a4)
[ =A0148.582609] [<c004f62c>] (sys_init_module+0xf4/0x13a4) from
[<c0008d40>] (ret_fast_syscall+0x0/0x2c)
[ =A0148.591713] Code: e598201c e2022007 e5ca2377 e59d0030 (e1d002b0)
[ =A0148.602704] ---[ end trace be518a2fa6d9a905 ]---
