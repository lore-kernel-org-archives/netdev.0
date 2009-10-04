From: Dave Young <hidave.darkstar@gmail.com>
Subject: Re: [BUG net-2.6] bluetooth/rfcomm : sleeping function called from
	invalid context at mm/slub.c:1719
Date: Sun, 4 Oct 2009 11:26:17 +0800
Message-ID: <a8e1da0910032026m66200c08jf9201bbfe34b2f30@mail.gmail.com>
References: <4AC59D8A.6000102@hartkopp.net>
	 <a8e1da0910020401m2fb8493ax95ff55a3b66131a5@mail.gmail.com>
	 <4AC6247E.7050308@hartkopp.net> <20091003070622.GA4110@darkstar>
	 <4AC71CAA.9090704@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Marcel Holtmann <marcel@holtmann.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-bluetooth@vger.kernel.org,
	"Gustavo F. Padovan" <gustavo@las.ic.unicamp.br>
To: Oliver Hartkopp <oliver@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f211.google.com ([209.85.219.211]:63058 "EHLO
	mail-ew0-f211.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751213AbZJDD0z convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Oct 2009 23:26:55 -0400
In-Reply-To: <4AC71CAA.9090704@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 3, 2009 at 5:43 PM, Oliver Hartkopp <oliver@hartkopp.net> w=
rote:
> Dave Young wrote:
>> On Fri, Oct 02, 2009 at 06:04:14PM +0200, Oliver Hartkopp wrote:
>>> Dave Young wrote:
>>>> On Fri, Oct 2, 2009 at 2:28 PM, Oliver Hartkopp <oliver@hartkopp.n=
et> wrote:
>>>>> Hello Marcel,
>>>>>
>>>>> with current net-2.6 tree ...
>>>>>
>>>>> While starting my PPP Bluetooth dialup networking, i got this:
>>>> Hi, oliver
>>>>
>>>> please try following patch:
>>>> http://patchwork.kernel.org/patch/51326/
>>> Hi Dave,
>>>
>>> that fixed it at ppp startup!
>>>
>>> Tested-by: Oliver Hartkopp <oliver@hartkopp.net>
>>>
>>> Btw. when shutting down the ppp connection i still get this:
>>>
>>> [ =C2=A0361.996887] INFO: trying to register non-static key.
>>> [ =C2=A0361.996897] the code is fine but needs lockdep annotation.
>>> [ =C2=A0361.996902] turning off the locking correctness validator.
>>> [ =C2=A0361.996912] Pid: 0, comm: swapper Not tainted 2.6.31-08939-=
gdb8abec-dirty #22
>>> [ =C2=A0361.996919] Call Trace:
>>> [ =C2=A0361.996933] =C2=A0[<c12e4fb2>] ? printk+0xf/0x11
>>> [ =C2=A0361.996947] =C2=A0[<c1042214>] register_lock_class+0x5a/0x2=
95
>>> [ =C2=A0361.996957] =C2=A0[<c1043af2>] __lock_acquire+0x9b/0xc03
>>> [ =C2=A0361.996967] =C2=A0[<c104464b>] ? __lock_acquire+0xbf4/0xc03
>>> [ =C2=A0361.996985] =C2=A0[<fa59a168>] ? l2cap_get_chan_by_scid+0x3=
5/0x43 [l2cap]
>>> [ =C2=A0361.996995] =C2=A0[<c104491f>] ? lock_release_non_nested+0x=
17b/0x1db
>>> [ =C2=A0361.997008] =C2=A0[<fa59a168>] ? l2cap_get_chan_by_scid+0x3=
5/0x43 [l2cap]
>>> [ =C2=A0361.997018] =C2=A0[<c10426fd>] ? trace_hardirqs_off+0xb/0xd
>>> [ =C2=A0361.997028] =C2=A0[<c10446b6>] lock_acquire+0x5c/0x73
>>> [ =C2=A0361.997039] =C2=A0[<c124cd14>] ? skb_dequeue+0x12/0x4c
>>> [ =C2=A0361.997049] =C2=A0[<c12e6e23>] _spin_lock_irqsave+0x24/0x34
>>> [ =C2=A0361.997058] =C2=A0[<c124cd14>] ? skb_dequeue+0x12/0x4c
>>> [ =C2=A0361.997066] =C2=A0[<c124cd14>] skb_dequeue+0x12/0x4c
>>> [ =C2=A0361.997075] =C2=A0[<c124d579>] skb_queue_purge+0x14/0x1b
>>> [ =C2=A0361.997088] =C2=A0[<fa59ce3f>] l2cap_recv_frame+0xe9e/0x129=
a [l2cap]
>>> [ =C2=A0361.997099] =C2=A0[<c10421d1>] ? register_lock_class+0x17/0=
x295
>>> [ =C2=A0361.997110] =C2=A0[<c104464b>] ? __lock_acquire+0xbf4/0xc03
>>> [ =C2=A0361.997128] =C2=A0[<c104464b>] ? __lock_acquire+0xbf4/0xc03
>>> [ =C2=A0361.997139] =C2=A0[<c120de74>] ? uhci_giveback_urb+0xf2/0x1=
62
>>> [ =C2=A0361.997163] =C2=A0[<f8bb4c45>] ? hci_rx_task+0xfe/0x1f8 [bl=
uetooth]
>>> [ =C2=A0361.997177] =C2=A0[<fa59d2e4>] l2cap_recv_acldata+0xa9/0x1b=
e [l2cap]
>>> [ =C2=A0361.997190] =C2=A0[<fa59d23b>] ? l2cap_recv_acldata+0x0/0x1=
be [l2cap]
>>> [ =C2=A0361.997208] =C2=A0[<f8bb4c77>] hci_rx_task+0x130/0x1f8 [blu=
etooth]
>>> [ =C2=A0361.997219] =C2=A0[<c102a098>] tasklet_action+0x6b/0xb2
>>> [ =C2=A0361.997228] =C2=A0[<c102a46b>] __do_softirq+0x82/0x101
>>> [ =C2=A0361.997237] =C2=A0[<c102a515>] do_softirq+0x2b/0x43
>>> [ =C2=A0361.997246] =C2=A0[<c102a619>] irq_exit+0x35/0x68
>>> [ =C2=A0361.997256] =C2=A0[<c1004513>] do_IRQ+0x80/0x96
>>> [ =C2=A0361.997265] =C2=A0[<c10030ae>] common_interrupt+0x2e/0x34
>>> [ =C2=A0361.997275] =C2=A0[<c104007b>] ? tick_device_uses_broadcast=
+0x71/0x7c
>>> [ =C2=A0361.997286] =C2=A0[<c11747a8>] ? acpi_idle_enter_simple+0x1=
03/0x12e
>>> [ =C2=A0361.997296] =C2=A0[<c1174515>] acpi_idle_enter_bm+0xc3/0x25=
3
>>> [ =C2=A0361.997306] =C2=A0[<c1238b6f>] cpuidle_idle_call+0x60/0x91
>>> [ =C2=A0361.997315] =C2=A0[<c1001d44>] cpu_idle+0x49/0x65
>>> [ =C2=A0361.997324] =C2=A0[<c12e2f0e>] start_secondary+0x190/0x195
>>>
>>>
>>> Thanks,
>>> Oliver
>>>
>>
>> Oliver, does following patch fix the non-static lock problem?
>> --
>>
>> now l2cap conn locks will be initialized after setup l2cap conn time=
r,
>> it will introduce following problem:
>>
>> [ =C2=A0361.996887] INFO: trying to register non-static key.
>> [ =C2=A0361.996897] the code is fine but needs lockdep annotation.
>> [ =C2=A0361.996902] turning off the locking correctness validator.
>> [ =C2=A0361.996912] Pid: 0, comm: swapper Not tainted 2.6.31-08939-g=
db8abec-dirty #22
>> [ =C2=A0361.996919] Call Trace:
>> [ =C2=A0361.996933] =C2=A0[<c12e4fb2>] ? printk+0xf/0x11
>> [ =C2=A0361.996947] =C2=A0[<c1042214>] register_lock_class+0x5a/0x29=
5
>> [ =C2=A0361.996957] =C2=A0[<c1043af2>] __lock_acquire+0x9b/0xc03
>> [ =C2=A0361.996967] =C2=A0[<c104464b>] ? __lock_acquire+0xbf4/0xc03
>> [ =C2=A0361.996985] =C2=A0[<fa59a168>] ? l2cap_get_chan_by_scid+0x35=
/0x43 [l2cap]
>> [ =C2=A0361.996995] =C2=A0[<c104491f>] ? lock_release_non_nested+0x1=
7b/0x1db
>> [ =C2=A0361.997008] =C2=A0[<fa59a168>] ? l2cap_get_chan_by_scid+0x35=
/0x43 [l2cap]
>> [ =C2=A0361.997018] =C2=A0[<c10426fd>] ? trace_hardirqs_off+0xb/0xd
>> [ =C2=A0361.997028] =C2=A0[<c10446b6>] lock_acquire+0x5c/0x73
>> [ =C2=A0361.997039] =C2=A0[<c124cd14>] ? skb_dequeue+0x12/0x4c
>> [ =C2=A0361.997049] =C2=A0[<c12e6e23>] _spin_lock_irqsave+0x24/0x34
>> [ =C2=A0361.997058] =C2=A0[<c124cd14>] ? skb_dequeue+0x12/0x4c
>> [ =C2=A0361.997066] =C2=A0[<c124cd14>] skb_dequeue+0x12/0x4c
>> [ =C2=A0361.997075] =C2=A0[<c124d579>] skb_queue_purge+0x14/0x1b
>> [ =C2=A0361.997088] =C2=A0[<fa59ce3f>] l2cap_recv_frame+0xe9e/0x129a=
 [l2cap]
>> [ =C2=A0361.997099] =C2=A0[<c10421d1>] ? register_lock_class+0x17/0x=
295
>> [ =C2=A0361.997110] =C2=A0[<c104464b>] ? __lock_acquire+0xbf4/0xc03
>> [ =C2=A0361.997128] =C2=A0[<c104464b>] ? __lock_acquire+0xbf4/0xc03
>> [ =C2=A0361.997139] =C2=A0[<c120de74>] ? uhci_giveback_urb+0xf2/0x16=
2
>> [ =C2=A0361.997163] =C2=A0[<f8bb4c45>] ? hci_rx_task+0xfe/0x1f8 [blu=
etooth]
>> [ =C2=A0361.997177] =C2=A0[<fa59d2e4>] l2cap_recv_acldata+0xa9/0x1be=
 [l2cap]
>> [ =C2=A0361.997190] =C2=A0[<fa59d23b>] ? l2cap_recv_acldata+0x0/0x1b=
e [l2cap]
>> [ =C2=A0361.997208] =C2=A0[<f8bb4c77>] hci_rx_task+0x130/0x1f8 [blue=
tooth]
>> [ =C2=A0361.997219] =C2=A0[<c102a098>] tasklet_action+0x6b/0xb2
>> [ =C2=A0361.997228] =C2=A0[<c102a46b>] __do_softirq+0x82/0x101
>> [ =C2=A0361.997237] =C2=A0[<c102a515>] do_softirq+0x2b/0x43
>> [ =C2=A0361.997246] =C2=A0[<c102a619>] irq_exit+0x35/0x68
>> [ =C2=A0361.997256] =C2=A0[<c1004513>] do_IRQ+0x80/0x96
>> [ =C2=A0361.997265] =C2=A0[<c10030ae>] common_interrupt+0x2e/0x34
>> [ =C2=A0361.997275] =C2=A0[<c104007b>] ? tick_device_uses_broadcast+=
0x71/0x7c
>> [ =C2=A0361.997286] =C2=A0[<c11747a8>] ? acpi_idle_enter_simple+0x10=
3/0x12e
>> [ =C2=A0361.997296] =C2=A0[<c1174515>] acpi_idle_enter_bm+0xc3/0x253
>> [ =C2=A0361.997306] =C2=A0[<c1238b6f>] cpuidle_idle_call+0x60/0x91
>> [ =C2=A0361.997315] =C2=A0[<c1001d44>] cpu_idle+0x49/0x65
>> [ =C2=A0361.997324] =C2=A0[<c12e2f0e>] start_secondary+0x190/0x195
>>
>> Here move lock init things before setup_timer to avoid misuse
>> uninitialized locks.
>>
>> Reported-by: Oliver Hartkopp <oliver@hartkopp.net>
>> Signed-off-by: Dave Young <hidave.darkstar@gmail.com>
>> ---
>> net/bluetooth/l2cap.c | =C2=A0 =C2=A06 +++---
>> 1 file changed, 3 insertions(+), 3 deletions(-)
>>
>> --- linux-2.6.31.orig/net/bluetooth/l2cap.c =C2=A0 2009-09-30 16:36:=
10.000000000 +0800
>> +++ linux-2.6.31/net/bluetooth/l2cap.c =C2=A0 =C2=A0 =C2=A0 =C2=A020=
09-10-03 14:44:51.000000000 +0800
>> @@ -555,12 +555,12 @@ static struct l2cap_conn *l2cap_conn_add
>>
>> =C2=A0 =C2=A0 =C2=A0 conn->feat_mask =3D 0;
>>
>> - =C2=A0 =C2=A0 setup_timer(&conn->info_timer, l2cap_info_timeout,
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 (unsigned long) conn);
>> -
>> =C2=A0 =C2=A0 =C2=A0 spin_lock_init(&conn->lock);
>> =C2=A0 =C2=A0 =C2=A0 rwlock_init(&conn->chan_list.lock);
>>
>> + =C2=A0 =C2=A0 setup_timer(&conn->info_timer, l2cap_info_timeout,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 (unsigned long) conn);
>> +
>> =C2=A0 =C2=A0 =C2=A0 conn->disc_reason =3D 0x13;
>>
>> =C2=A0 =C2=A0 =C2=A0 return conn;
>
> No, it does not have any effect.
>

I can reproduce the bug.

It's probably caused by the l2cap changes by  Gustavo F. Padovan
<gustavo@las.ic.unicamp.br>, I didn't see such problem after reverting
Gustavo's patch series.

Add gustavo to cc-list.

BTW, my above patch fix similar things. I need rewrite the patch descri=
ption.

> As the lockdep annotation only appears when shutting down the ppp con=
nection,
> i wonder whether it should help to change things in a _conn_add() fun=
ction.
> :-)
>
> Or didn't i made it clear before, that this annotation one only happe=
ns at ppp
> shutdown?
>
> Best regards,
> Oliver
>
>



--=20
Regards
dave
