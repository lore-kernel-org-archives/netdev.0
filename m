From: Steve Bennett <steveb@workware.net.au>
Subject: Re: Bug in cadence macb driver
Date: Thu, 27 Oct 2016 19:16:39 +1000
Message-ID: <A1A68503-5677-46F4-9C06-6EF194C5ACB6@workware.net.au>
References: <3DDE7A42-84A6-44DC-9919-C0D9166E87EF@workware.net.au> <1da8552b-a7e8-0850-31ce-f608504b01a1@atmel.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, Cyrille Pitchen <cyrille.pitchen@atmel.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:34894 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755959AbcJ0JQu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 05:16:50 -0400
Received: by mail-pf0-f174.google.com with SMTP id s8so14106220pfj.2
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2016 02:16:49 -0700 (PDT)
In-Reply-To: <1da8552b-a7e8-0850-31ce-f608504b01a1@atmel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On 27 Oct 2016, at 7:05 PM, Nicolas Ferre <nicolas.ferre@atmel.com> =
wrote:
>=20
> Le 27/10/2016 =C3=A0 09:22, Steve Bennett a =C3=A9crit :
>> Hi,
>>=20
>> We are seeing the following problem in the cadence macb driver.
>>=20
>> BUG: scheduling while atomic: kworker/0:1/44/0x00000002
>> Modules linked in: 8021q of_serial beacon_sigproc io_processor =
emsattr ems_dma_fifo xaxi_dma libgpioreg leds_gpio
>> CPU: 0 PID: 44 Comm: kworker/0:1 Not tainted 4.4.0 #1
>> Hardware name: Xilinx Zynq Platform
>> Workqueue: events macb_tx_error_task
>> [<c0016a18>] (unwind_backtrace) from [<c0012ad4>] =
(show_stack+0x10/0x14)
>> [<c0012ad4>] (show_stack) from [<c01b089c>] (dump_stack+0x88/0xd8)
>> [<c01b089c>] (dump_stack) from [<c008e94c>] =
(__schedule_bug+0x48/0x60)
>> [<c008e94c>] (__schedule_bug) from [<c03592d4>] =
(__schedule+0x80/0x4c4)
>> [<c03592d4>] (__schedule) from [<c0359968>] (schedule+0xac/0xd4)
>> [<c0359968>] (schedule) from [<c035c284>] =
(schedule_hrtimeout_range_clock+0xc0/0xf4)
>> [<c035c284>] (schedule_hrtimeout_range_clock) from [<c035bebc>] =
(usleep_range+0x44/0x48)
>> [<c035bebc>] (usleep_range) from [<c025ec48>] =
(macb_tx_error_task+0xa0/0x270)
>> [<c025ec48>] (macb_tx_error_task) from [<c0035b6c>] =
(process_one_work+0x1b8/0x2f0)
>> [<c0035b6c>] (process_one_work) from [<c0035fb4>] =
(worker_thread+0x2e4/0x3f0)
>> [<c0035fb4>] (worker_thread) from [<c003ac94>] (kthread+0xdc/0xf0)
>> [<c003ac94>] (kthread) from [<c000f698>] (ret_from_fork+0x14/0x3c)
>>=20
>> Here we are running at 10M half duplex, so tx is slow.
>> The problem was introduced in e4bfd971b where a spinlock is taken =
before
>=20
> I can't find this commit ID. Can you please give the one on Linus' =
tree
> together with the commit subject?

Ahh yes. My apologies. Here it is in Linus' tree

commit 02c958dd344643259212e50f04f0ec90a3ace34c
Author: Cyrille Pitchen <cyrille.pitchen@atmel.com>
Date:   Fri Dec 12 13:26:44 2014 +0100

    net/macb: add TX multiqueue support for gem

>=20
> Thanks,
>=20
>> calling macb_halt_tx() which may then sleep waiting for the current =
packet to finish
>> transmitting.
>>=20
>> We don't need the spinlock on our platform since we don't have =
multiple queues, but
>> this should be fixed properly in the general case.
>>=20
>> Cheers,
>> Steve
>>=20
>> --
>> =C2=B5Web: Embedded Web Framework - http://uweb.workware.net.au/
>> WorkWare Systems Pty Ltd
>> W: www.workware.net.au      P: +61 434 921 300
>> E: steveb@workware.net.au
>>=20
>>=20
>>=20
>>=20
>>=20
>>=20
>=20
>=20
> --=20
> Nicolas Ferre
