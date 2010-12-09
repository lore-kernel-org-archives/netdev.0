From: Jim Bos <jim876@xs4all.nl>
Subject: Re: [regression, 2.6.37-rc1] 'ip link tap0 up' stuck in do_exit()
Date: Thu, 09 Dec 2010 18:59:48 +0100
Message-ID: <4D011914.3000301@xs4all.nl>
References: <20101103062609.GB31163@dastard> <1288768402.2467.665.camel@edumazet-laptop> <20101103103448.GA9169@dastard> <20101103112936.GB9169@dastard> <20101104002140.GA13830@dastard> <20101104054718.GC5210@cr0.nay.redhat.com> <20101208100245.01cf23c5@schatten.dmk.lab> <20101208134116.GA16923@redhat.com> <20101208134712.GB16923@redhat.com> <20101208140822.GA18681@redhat.com> <20101209164748.GA3218@hack>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oleg Nesterov <oleg@redhat.com>,
	Florian Mickler <florian@mickler.org>,
	Ingo Molnar <mingo@elte.hu>,
	Dave Chinner <david@fromorbit.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Am=E9rico_Wang?= <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101209164748.GA3218@hack>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/09/2010 05:47 PM, Am=E9rico Wang wrote:
> On Wed, Dec 08, 2010 at 03:08:22PM +0100, Oleg Nesterov wrote:
>> On 12/08, Oleg Nesterov wrote:
>>>
>>> On 12/08, Oleg Nesterov wrote:
>>>>
>>>> On 12/08, Florian Mickler wrote:
>>>>>
>>>>> [ ccing Ingo and Oleg ] as suggested
>>>>
>>>> Well. Of course I can't explain this bug. But, looking at this ema=
il
>>>> I do not see amything strange in exit/schedule/etc.
>>>>
>>>>>>>>>>> This is resulting in the command 'ip link set tap0 up' hang=
ing as a zombie:
>>>>>>>>>>>
>>>>>>>>>>> root      3005     1  0 16:53 pts/3    00:00:00 /bin/sh /vm=
-images/qemu-ifup tap0
>>>>>>>>>>> root      3011  3005  0 16:53 pts/3    00:00:00 /usr/bin/su=
do /sbin/ip link set tap0 up
>>>>>>>>>>> root      3012  3011  0 16:53 pts/3    00:00:00 [ip] <defun=
ct>
>>>>
>>>> That is. ip is a zombie.
>>>
>>> And. I do not know if this matters or not, but "the command 'ip lin=
k
>>> set tap0 up' hanging as a zombie" does not look right.
>>>
>>> This was spawned by
>>>
>>>>>>>>> if [ -n "$1" ];then
>>>>>>>>>         /usr/bin/sudo /sbin/ip link set $1 up
>>>>>>>>>         sleep 0.5s
>>>>>>>>>         /usr/bin/sudo /usr/sbin/brctl addif $switch $1
>>>>>>>>>      exit 0
>>>>>>>>> fi
>>>
>>> The command does not hang. But it forks the child with pid =3D=3D 3=
012,
>>> this child exits.
>>
>> Damn, sorry for noise, forgot to mention...
>>
>> The parent's trace (pid =3D=3D 3011) can be more useful. Say, if it
>> hangs in do_wait(), then the kernel is obviously wrong.
>>
>=20
> Yeah, there is no point that a zombie can trigger a BUG_ON in kenrel.
> But it is still interesting to know why it becomes a zombie...
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

ip link tap0 up not working might be this issue:

   http://marc.info/?l=3Dlinux-netdev&m=3D128783852132311&w=3D2

( Latest Virtualbox 3.2.12 works around this issue )

Jim
