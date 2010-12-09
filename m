From: Neil Jones <neiljay@gmail.com>
Subject: Re: rndis gadget: Inconsistent locking
Date: Thu, 9 Dec 2010 17:00:55 +0000
Message-ID: <AANLkTinE1srqkpib0+8Q63XjnhRYEWaaDsX70tc_OeUm@mail.gmail.com>
References: <AANLkTik=Uui7Xk9ZfFvQQKj94ZJUJ_n+bZbTQXbe+08i@mail.gmail.com>
	<AANLkTi==UqNNzokLcLWDpjM0cqM6aXjppsi4p6ogMAqX@mail.gmail.com>
	<op.vnenkvz67p4s8u@pikus>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: =?UTF-8?Q?Micha=C5=82_Nazarewicz?= <m.nazarewicz@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f180.google.com ([209.85.161.180]:50758 "EHLO
	mail-gx0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754739Ab0LIRA4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Dec 2010 12:00:56 -0500
In-Reply-To: <op.vnenkvz67p4s8u@pikus>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Does this help: <https://patchwork.kernel.org/patch/195562/>?

Yes cheers, warning gone and driver seems fine so far.

has this been accepted upstream ?

Neil

2010/12/8 Micha=C5=82 Nazarewicz <m.nazarewicz@samsung.com>:
> On Wed, 08 Dec 2010 16:11:30 +0100, Neil Jones <neiljay@gmail.com> wr=
ote:
>>
>> Im getting another lockdep warning when using the RNDIS gadget:
>>
>> =C2=A0WARNING: at kernel/softirq.c:98 ___local_bh_disable+0xc4/0xd0(=
)
>> =C2=A0Modules linked in: g_ether
>>
>> =C2=A0Call trace:
>> =C2=A0[<40003bf8>] _show_stack+0x68/0x7c
>> =C2=A0[<40003c20>] _dump_stack+0x14/0x28
>> =C2=A0[<40013c3c>] _warn_slowpath_common+0x5c/0x7c
>> =C2=A0[<40013c74>] _warn_slowpath_null+0x18/0x2c
>> =C2=A0[<4001b17c>] ___local_bh_disable+0xc0/0xd0
>> =C2=A0[<4001b1a0>] _local_bh_disable+0x14/0x28
>> =C2=A0[<402e57f8>] __raw_spin_lock_bh+0x18/0x54
>> =C2=A0[<40257f4c>] _dev_txq_stats_fold+0x7c/0x13c
>> =C2=A0[<402580c4>] _dev_get_stats+0xb8/0xc0
>> =C2=A0[<781d4e60>] _rndis_msg_parser+0x288/0xa04 [g_ether]
>> =C2=A0[<781d5600>] _rndis_command_complete+0x24/0x70 [g_ether]
>> =C2=A0[<401d66fc>] _dwc_otg_request_done+0xd8/0x220
>> =C2=A0[<401d928c>] _ep0_complete_request+0x3f4/0x578
>> =C2=A0[<401d95bc>] _handle_ep0+0x1ac/0x146c
>> =C2=A0[<401daf7c>] _dwc_otg_pcd_handle_in_ep_intr+0x1c0/0x8bc
>> =C2=A0[<401db8dc>] _dwc_otg_pcd_handle_intr+0x264/0x294
>> =C2=A0[<401d6288>] _dwc_otg_pcd_irq+0x10/0x30
>> =C2=A0[<40054cf4>] _handle_IRQ_event+0x4c/0x184
>> =C2=A0[<40057b4c>] _handle_level_irq+0xac/0x15c
>> =C2=A0[<4000b204>] _metag_soc_irq_demux+0xac/0xb4
>> =C2=A0[<40002dd4>] _do_IRQ+0x4c/0x78
>> =C2=A0[<40004000>] _trigger_handler+0x38/0xac
>> =C2=A0[<40000b18>] ___TBIBoingVec+0xc/0x10
>> =C2=A0[<40003588>] _cpu_idle+0x54/0x78
>>
>> =C2=A0no locks held by swapper/0.
>> =C2=A0---[ end trace 77ac3cfee0ae5b25 ]---
>
> Known problem.
>
>> It looks like we are calling spin_lock_bh in the completion function
>> which is running in hard_irq, I think the driver should defer handli=
ng
>> this msg (and maybe all requests) to a workqueue?
>
> Does this help: <https://patchwork.kernel.org/patch/195562/>?
>
> --
> Best regards, =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0_ =C2=A0 =C2=A0 _
> | Humble Liege of Serenely Enlightened Majesty of =C2=A0o' \,=3D./ `o
> | Computer Science, =C2=A0Micha=C5=82 "mina86" Nazarewicz =C2=A0 =C2=A0=
 =C2=A0 (o o)
> +----[mina86*mina86.com]---[mina86*jabber.org]----ooO--(_)--Ooo--
>
