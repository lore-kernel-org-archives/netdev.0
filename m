From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 27212] New: Warning kmemcheck: Caught 64-bit
 read from uninitialized memory in netlink_broadcast_filtered
Date: Wed, 26 Jan 2011 10:18:38 +0100
Message-ID: <1296033518.2899.41.camel@edumazet-laptop>
References: <bug-27212-10286@https.bugzilla.kernel.org/>
	 <20110120122549.85863a84.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, casteyde.christian@free.fr,
	Andrew Morton <akpm@linux-foundation.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:57674 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752937Ab1AZJSo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jan 2011 04:18:44 -0500
Received: by bwz15 with SMTP id 15so987190bwz.19
        for <netdev@vger.kernel.org>; Wed, 26 Jan 2011 01:18:43 -0800 (PST)
In-Reply-To: <20110120122549.85863a84.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 20 janvier 2011 =C3=A0 12:25 -0800, Andrew Morton a =C3=A9crit=
 :
> (switched to email.  Please respond via emailed reply-to-all, not via=
 the
> bugzilla web interface).
>=20
> On Thu, 20 Jan 2011 20:08:32 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
>=20
> > https://bugzilla.kernel.org/show_bug.cgi?id=3D27212
> >=20
> >            Summary: Warning kmemcheck: Caught 64-bit read from
> >                     uninitialized memory in netlink_broadcast_filte=
red
> >            Product: Other
> >            Version: 2.5
> >     Kernel Version: 2.6.38-rc1
> >           Platform: All
> >         OS/Version: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: normal
> >           Priority: P1
> >          Component: Other
> >         AssignedTo: other_other@kernel-bugs.osdl.org
> >         ReportedBy: casteyde.christian@free.fr
> >         Regression: Yes
> >=20
> >=20
> > Athlon 64 X2 3000 in 64bits
> > Slackware64 13.1
> > Kernel compiled with kmemcheck and other debug options
> >=20
> > At boot I got the following warning:
> >=20
> > PCI: Using ACPI for IRQ routing
> > PCI: pci_cache_line_size set to 64 bytes
> > pci 0000:00:00.0: address space collision: [mem 0xe0000000-0xefffff=
ff pref]
> > conflicts with GART [mem 0x
> > e0000000-0xefffffff]
> > reserve RAM buffer: 000000000009fc00 - 000000000009ffff=20
> > reserve RAM buffer: 000000003ffb0000 - 000000003fffffff
> > WARNING: kmemcheck: Caught 64-bit read from uninitialized memory
> > (ffff88003e170eb0)
> > 0000000000000000010000000000000000000000000000000000000000000000
> >  i i i i i i i i i i i i u u u u u u u u u u u u u u u u u u u u
> >                                  ^
> >=20
> > Pid: 1, comm: swapper Not tainted 2.6.38-rc1 #2 K8 Combo-Z/K8 Combo=
-Z
> > RIP: 0010:[<ffffffff8127ad72>]  [<ffffffff8127ad72>] memmove+0x122/=
0x1a0
> > RSP: 0018:ffff88003e0b3c60  EFLAGS: 00010202
> > RAX: ffff88003e170080 RBX: ffff88003e27b500 RCX: 0000000000000020
> > RDX: 0000000000000018 RSI: ffff88003e170ea0 RDI: ffff88003e1700a0
> > RBP: ffff88003e0b3c60 R08: 0000000000000001 R09: 0000000000000001
> > R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
> > R13: 0000000000000080 R14: 0000000000000000 R15: 0000000000000001
> > FS:  0000000000000000(0000) GS:ffff88003fc00000(0000) knlGS:0000000=
000000000
> > CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> > CR2: ffff88003e018abc CR3: 0000000001a1c000 CR4: 00000000000006f0
> > DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> > DR3: 0000000000000000 DR6: 00000000ffff4ff0 DR7: 0000000000000400
> >  [<ffffffff814741c2>] pskb_expand_head+0xc2/0x2a0
> >  [<ffffffff81498fa7>] netlink_broadcast_filtered+0xa7/0x4a0
> >  [<ffffffff814993b8>] netlink_broadcast+0x18/0x20
> >  [<ffffffff8149b884>] genlmsg_mcast+0x144/0x180
> >  [<ffffffff8149bc4a>] genl_ctrl_event+0xca/0x450
> >  [<ffffffff8149c75d>] genl_register_mc_group+0x10d/0x2a0
> >  [<ffffffff81ad9da4>] genl_init+0x6c/0x84
> >  [<ffffffff810001de>] do_one_initcall+0x3e/0x170
> >  [<ffffffff81aae6ea>] kernel_init+0x197/0x21b
> >  [<ffffffff81003254>] kernel_thread_helper+0x4/0x10
> >  [<ffffffffffffffff>] 0xffffffffffffffff
> > pnp: PnP ACPI init
> > ACPI: bus type pnp registered
> > pnp 00:00: [bus 00-ff]
> > pnp 00:00: [io  0x0cf8-0x0cff]
> >=20
> > This is specific to 2.6.38-rc1.
> >=20

[PATCH] net: add kmemcheck annotation in __alloc_skb()

pskb_expand_head() triggers a kmemcheck warning when copy of
skb_shared_info is done in pskb_expand_head()

This is because destructor_arg field is not necessarily initialized at
this point. Add kmemcheck_annotate_variable() call in __alloc_skb() to
instruct kmemcheck this is a normal situation.

Resolves bugzilla.kernel.org 27212

Reference: https://bugzilla.kernel.org/show_bug.cgi?id=3D27212
Reported-by: Christian Casteyde <casteyde.christian@free.fr>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>
---
 net/core/skbuff.c |    1 +
 1 files changed, 1 insertion(+)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index d31bb36..1762e97 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -210,6 +210,7 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_=
t gfp_mask,
 	shinfo =3D skb_shinfo(skb);
 	memset(shinfo, 0, offsetof(struct skb_shared_info, dataref));
 	atomic_set(&shinfo->dataref, 1);
+	kmemcheck_annotate_variable(shinfo->destructor_arg);
=20
 	if (fclone) {
 		struct sk_buff *child =3D skb + 1;


