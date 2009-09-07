From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net_sched 00/07: classful multiqueue dummy scheduler
Date: Mon, 07 Sep 2009 19:30:47 +0200
Message-ID: <4AA54347.8020401@gmail.com>
References: <20090904164111.27300.29929.sendpatchset@x2.localnet>	<4AA14377.9020200@trash.net> <20090907.015039.154939751.davem@davemloft.net> <4AA503E4.2060504@gmail.com> <4AA50ACF.9010400@trash.net> <4AA5175F.6030600@trash.net> <4AA54128.2050607@gmail.com> <4AA542B4.4090206@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:49613 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752619AbZIGRas (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Sep 2009 13:30:48 -0400
In-Reply-To: <4AA542B4.4090206@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy a =E9crit :
> Eric Dumazet wrote:
>>> I figured out the bug, which is likely responsible for both
>>> problems. When grafting a mq class and creating a rate estimator,
>>> the new qdisc is not attached to the device queue yet and also
>>> doesn't have TC_H_ROOT as parent, so qdisc_create() selects
>>> qdisc_root_sleeping_lock() for the estimator, which belongs to
>>> the qdisc that is getting replaced.
>>>
>>> This is a patch I used for testing, but I'll come up with
>>> something more elegant (I hope) as a final fix :)
>> Yes, this was the problem, and your patch fixed it.
>=20
> Thanks for testing.
>=20
>> Now adding CONFIG_SLUB_DEBUG_ON=3Dy for next tries :)
>>
>> Sep  7 16:37:55 erd kernel: [  217.056813] =3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> Sep  7 16:37:55 erd kernel: [  217.056865] BUG kmalloc-256: Poison o=
verwritten
>> Sep  7 16:37:55 erd kernel: [  217.056910] -------------------------=
----------------------------------------------------
>> Sep  7 16:37:55 erd kernel: [  217.056911]
>> Sep  7 16:37:55 erd kernel: [  217.056990] INFO: 0xf6e622bc-0xf6e622=
bd. First byte 0x76 instead of 0x6b
>> Sep  7 16:37:55 erd kernel: [  217.057049] INFO: Allocated in qdisc_=
alloc+0x1b/0x80 age=3D154593 cpu=3D2 pid=3D5165
>> Sep  7 16:37:55 erd kernel: [  217.057094] INFO: Freed in qdisc_dest=
roy+0x88/0xa0 age=3D139186 cpu=3D4 pid=3D5173
>> Sep  7 16:37:55 erd kernel: [  217.057139] INFO: Slab 0xc16ddc40 obj=
ects=3D26 used=3D6 fp=3D0xf6e62260 flags=3D0x28040c3
>> Sep  7 16:37:55 erd kernel: [  217.057184] INFO: Object 0xf6e62260 @=
offset=3D608 fp=3D0xf6e62850
>> Sep  7 16:37:55 erd kernel: [  217.057184]
>=20
> I'm unable to reproduce this. Could you send me the commands you
> used that lead to this?
>=20

Sorry, this was *before* your last patch.

I tried to have more information, because I was not able to get console=
 messages at crash time on this remote dev machine.

enabling SLUB checks got some hint of what the problem was (using memor=
y block after its freeing by qdisc_destroy)
