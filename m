From: Dave Young <hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [BUG net-2.6] bluetooth/rfcomm : sleeping function called from
	invalid context at mm/slub.c:1719
Date: Sun, 11 Oct 2009 10:39:36 +0800
Message-ID: <a8e1da0910101939u77e8ab30gac1e47f13384865c@mail.gmail.com>
References: <4AC59D8A.6000102@hartkopp.net>
	 <a8e1da0910020401m2fb8493ax95ff55a3b66131a5@mail.gmail.com>
	 <4AC6247E.7050308@hartkopp.net> <20091003070622.GA4110@darkstar>
	 <4AC71CAA.9090704@hartkopp.net>
	 <a8e1da0910032026m66200c08jf9201bbfe34b2f30@mail.gmail.com>
	 <20091004180635.GA11272@vigoh> <20091009004452.GA2395@darkstar>
	 <1255171112.19127.1.camel@localhost.localdomain>
	 <20091010134517.GA2855@darkstar.tsinghua.edu.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Gustavo F. Padovan" <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>,
	Oliver Hartkopp <oliver-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"Gustavo F. Padovan" <gustavo-r7biftawOlEmmTcpzmvVSFAUjnlXr6A1@public.gmane.org>
To: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20091010134517.GA2855-4/PLUo9XfK8ghh91vJqQoSYtLZS1qPHf@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 10, 2009 at 9:45 PM, Dave Young <hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>=
 wrote:
> On Sat, Oct 10, 2009 at 12:38:32PM +0200, Marcel Holtmann wrote:
>> Hi Dave,
>>
>> > > * Dave Young <hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> [2009-10-04 11:26:17 +0=
800]:
>> > >
>> > > >
>> > > > I can reproduce the bug.
>> > > >
>> > > > It's probably caused by the l2cap changes by =C2=A0Gustavo F. =
Padovan
>> > > > <gustavo-r7biftawOlEmmTcpzmvVSFAUjnlXr6A1@public.gmane.org>, I didn't see such problem after r=
everting
>> > > > Gustavo's patch series.
>> > >
>> > > I can't reproduce the bug. I'm trying to reproduce it to figure =
out what of
>> > > my changes cause it.
>> > >
>> > > I' running
>> > >
>> > > $ dund -snu -i 00:11:67:CD:0F:CB # to pretend to be dialup/telep=
hone
>> > >
>> > > and on the other side
>> > >
>> > > $ rfcomm bind 0 00:11:67:CD:0F:CB 1
>> > > $ wvdial =C2=A0# wvdial to /dev/rfcomm0
>> > >
>> > > Both sides are on the same machine. Do you see any real differen=
ce
>> > > between my try and the call that get the bug?
>> > >
>> >
>> > Hi oliver
>> >
>> > Could try following patch?
>> > ---
>> >
>> > When shutdown ppp connection, lockdep waring about non-static key
>> > will happen, it is caused by the lock is not initialized properly
>> > at that time.
>> >
>> > Fix with tuning the lock/skb_queue_head init order
>> >
>> > [ =C2=A0 94.339261] INFO: trying to register non-static key.
>> > [ =C2=A0 94.342509] the code is fine but needs lockdep annotation.
>> > [ =C2=A0 94.342509] turning off the locking correctness validator.
>> > [ =C2=A0 94.342509] Pid: 0, comm: swapper Not tainted 2.6.31-mm1 #=
2
>> > [ =C2=A0 94.342509] Call Trace:
>> > [ =C2=A0 94.342509] =C2=A0[<c0248fbe>] register_lock_class+0x58/0x=
241
>> > [ =C2=A0 94.342509] =C2=A0[<c024b5df>] ? __lock_acquire+0xb57/0xb7=
3
>> > [ =C2=A0 94.342509] =C2=A0[<c024ab34>] __lock_acquire+0xac/0xb73
>> > [ =C2=A0 94.342509] =C2=A0[<c024b7fa>] ? lock_release_non_nested+0=
x17b/0x1de
>> > [ =C2=A0 94.342509] =C2=A0[<c024b662>] lock_acquire+0x67/0x84
>> > [ =C2=A0 94.342509] =C2=A0[<c04cd1eb>] ? skb_dequeue+0x15/0x41
>> > [ =C2=A0 94.342509] =C2=A0[<c054a857>] _spin_lock_irqsave+0x2f/0x3=
f
>> > [ =C2=A0 94.342509] =C2=A0[<c04cd1eb>] ? skb_dequeue+0x15/0x41
>> > [ =C2=A0 94.342509] =C2=A0[<c04cd1eb>] skb_dequeue+0x15/0x41
>> > [ =C2=A0 94.342509] =C2=A0[<c054a648>] ? _read_unlock+0x1d/0x20
>> > [ =C2=A0 94.342509] =C2=A0[<c04cd641>] skb_queue_purge+0x14/0x1b
>> > [ =C2=A0 94.342509] =C2=A0[<fab94fdc>] l2cap_recv_frame+0xea1/0x11=
5a [l2cap]
>> > [ =C2=A0 94.342509] =C2=A0[<c024b5df>] ? __lock_acquire+0xb57/0xb7=
3
>> > [ =C2=A0 94.342509] =C2=A0[<c0249c04>] ? mark_lock+0x1e/0x1c7
>> > [ =C2=A0 94.342509] =C2=A0[<f8364963>] ? hci_rx_task+0xd2/0x1bc [b=
luetooth]
>> > [ =C2=A0 94.342509] =C2=A0[<fab95346>] l2cap_recv_acldata+0xb1/0x1=
c6 [l2cap]
>> > [ =C2=A0 94.342509] =C2=A0[<f8364997>] hci_rx_task+0x106/0x1bc [bl=
uetooth]
>> > [ =C2=A0 94.342509] =C2=A0[<fab95295>] ? l2cap_recv_acldata+0x0/0x=
1c6 [l2cap]
>> > [ =C2=A0 94.342509] =C2=A0[<c02302c4>] tasklet_action+0x69/0xc1
>> > [ =C2=A0 94.342509] =C2=A0[<c022fbef>] __do_softirq+0x94/0x11e
>> > [ =C2=A0 94.342509] =C2=A0[<c022fcaf>] do_softirq+0x36/0x5a
>> > [ =C2=A0 94.342509] =C2=A0[<c022fe14>] irq_exit+0x35/0x68
>> > [ =C2=A0 94.342509] =C2=A0[<c0204ced>] do_IRQ+0x72/0x89
>> > [ =C2=A0 94.342509] =C2=A0[<c02038ee>] common_interrupt+0x2e/0x34
>> > [ =C2=A0 94.342509] =C2=A0[<c024007b>] ? pm_qos_add_requirement+0x=
63/0x9d
>> > [ =C2=A0 94.342509] =C2=A0[<c038e8a5>] ? acpi_idle_enter_bm+0x209/=
0x238
>> > [ =C2=A0 94.342509] =C2=A0[<c049d238>] cpuidle_idle_call+0x5c/0x94
>> > [ =C2=A0 94.342509] =C2=A0[<c02023f8>] cpu_idle+0x4e/0x6f
>> > [ =C2=A0 94.342509] =C2=A0[<c0534153>] rest_init+0x53/0x55
>> > [ =C2=A0 94.342509] =C2=A0[<c0781894>] start_kernel+0x2f0/0x2f5
>> > [ =C2=A0 94.342509] =C2=A0[<c0781091>] i386_start_kernel+0x91/0x96
>> >
>> > Reported-by: Oliver Hartkopp <oliver-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
>> > Signed-off-by: Dave Young <hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>>
>> actually Gustavo send a patch titled "Initialize variables and timer=
s
>> for both channel's sides" that should fix this, too. Can we test tha=
t
>> patch before I include this one.

Marcel, I tested Gustavo's latest patch series including
the "Initialize variables and timers for both channel". Lockdep
warning still happen.

>>
>
> Hi, marcel, of course.
>
>> Regards
>>
>> Marcel
>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-blue=
tooth" in
>> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.h=
tml
>



--=20
Regards
dave
