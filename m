From: Dave Young <hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [BUG net-2.6] bluetooth/rfcomm : sleeping function called from
	invalid context at mm/slub.c:1719
Date: Thu, 8 Oct 2009 09:25:07 +0800
Message-ID: <a8e1da0910071825m7b7f4f1fw400dba4e97ff1427@mail.gmail.com>
References: <4AC59D8A.6000102@hartkopp.net>
	 <a8e1da0910020401m2fb8493ax95ff55a3b66131a5@mail.gmail.com>
	 <4AC6247E.7050308@hartkopp.net> <4ACCCCF5.9060203@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Oliver Hartkopp <oliver-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4ACCCCF5.9060203-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 8, 2009 at 1:16 AM, Oliver Hartkopp <oliver-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org> w=
rote:
> Oliver Hartkopp wrote:
>> Dave Young wrote:
>>> On Fri, Oct 2, 2009 at 2:28 PM, Oliver Hartkopp <oliver-fJ+pQTUTwRSDGRHsOpWV0g@public.gmane.org=
t> wrote:
>>>> Hello Marcel,
>>>>
>>>> with current net-2.6 tree ...
>>>>
>>>> While starting my PPP Bluetooth dialup networking, i got this:
>>> Hi, oliver
>>>
>>> please try following patch:
>>> http://patchwork.kernel.org/patch/51326/
>>
>> Hi Dave,
>>
>> that fixed it at ppp startup!
>>
>> Tested-by: Oliver Hartkopp <oliver-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
>
> Hi Dave,
>
> what's the state of this patch?
>
> Has it gone upstream?

Not yet.

Marcel, could you pick it?  If there's potential problem please tell.

>
> Regards,
> Oliver
>
>>
>> Btw. when shutting down the ppp connection i still get this:
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
>>
>> Thanks,
>> Oliver
>>
>>
>
>



--=20
Regards
dave
