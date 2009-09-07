From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net_sched 00/07: classful multiqueue dummy scheduler
Date: Mon, 07 Sep 2009 19:38:11 +0200
Message-ID: <4AA54503.7090409@gmail.com>
References: <20090904164111.27300.29929.sendpatchset@x2.localnet>	<4AA14377.9020200@trash.net> <20090907.015039.154939751.davem@davemloft.net> <4AA503E4.2060504@gmail.com> <4AA50ACF.9010400@trash.net> <4AA5175F.6030600@trash.net> <4AA54128.2050607@gmail.com> <4AA542B4.4090206@trash.net> <4AA54347.8020401@gmail.com> <4AA54401.4010003@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:55776 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753545AbZIGRiL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Sep 2009 13:38:11 -0400
In-Reply-To: <4AA54401.4010003@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy a =E9crit :
> Eric Dumazet wrote:
>> Patrick McHardy a =E9crit :
>>>> Sep  7 16:37:55 erd kernel: [  217.056813] =3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>>>> Sep  7 16:37:55 erd kernel: [  217.056865] BUG kmalloc-256: Poison=
 overwritten
>>>> Sep  7 16:37:55 erd kernel: [  217.056910] -----------------------=
------------------------------------------------------
>>>> Sep  7 16:37:55 erd kernel: [  217.056911]
>>>> Sep  7 16:37:55 erd kernel: [  217.056990] INFO: 0xf6e622bc-0xf6e6=
22bd. First byte 0x76 instead of 0x6b
>>>> Sep  7 16:37:55 erd kernel: [  217.057049] INFO: Allocated in qdis=
c_alloc+0x1b/0x80 age=3D154593 cpu=3D2 pid=3D5165
>>>> Sep  7 16:37:55 erd kernel: [  217.057094] INFO: Freed in qdisc_de=
stroy+0x88/0xa0 age=3D139186 cpu=3D4 pid=3D5173
>>>> Sep  7 16:37:55 erd kernel: [  217.057139] INFO: Slab 0xc16ddc40 o=
bjects=3D26 used=3D6 fp=3D0xf6e62260 flags=3D0x28040c3
>>>> Sep  7 16:37:55 erd kernel: [  217.057184] INFO: Object 0xf6e62260=
 @offset=3D608 fp=3D0xf6e62850
>>>> Sep  7 16:37:55 erd kernel: [  217.057184]
>>> I'm unable to reproduce this. Could you send me the commands you
>>> used that lead to this?
>>>
>> Sorry, this was *before* your last patch.
>>
>> I tried to have more information, because I was not able to get cons=
ole messages at crash time on this remote dev machine.
>>
>> enabling SLUB checks got some hint of what the problem was (using me=
mory block after its freeing by qdisc_destroy)
>=20
> OK, that probably explains it, the spinlock operations were operating
> on already freed memory.
>=20
> I'll do some more testing and will send the final patch if no
> other problems show up.

BTW, you may ignore rate estimation requests on the mq root, since its =
stats
are updated only by user request, when doing a "tc -s -q qdisc" command=
, while
estimator is fired by a cyclic timer...


