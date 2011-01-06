From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH 2.6.36] vlan: Avoid hwaccel vlan packets when vid not used
Date: Thu, 6 Jan 2011 16:01:59 -0500
Message-ID: <AANLkTincX-wPQE9gs16v53E4=Skivzc4ZSJS43oNBLD_@mail.gmail.com>
References: <1291536233.2806.102.camel@edumazet-laptop>
	<20101205105528.49fa9a9f@xenia.leun.net>
	<20101205114404.7c0cddc2@xenia.leun.net>
	<AANLkTikrDTCDxsyOG4m0XcrOY=3pTRwWqnPGsio9cBFj@mail.gmail.com>
	<20101206203437.54b550e0@xenia.leun.net>
	<AANLkTikKkAesHc4Fi4SwAkV0e65D0TQRztrRYoDNu3MP@mail.gmail.com>
	<20101206222703.32fbe852@xenia.leun.net>
	<AANLkTinLMCzKz7n45HdeAwNxsWjCADAkgfK+MjXVcFqh@mail.gmail.com>
	<20101213224510.GB17400@mcarlson.broadcom.com>
	<AANLkTi=9BYt=vkNkAiTBxnfnCjCX7AqCG=ML6coc4vdZ@mail.gmail.com>
	<20101214191500.GD19951@mcarlson.broadcom.com>
	<1293901393.2535.49.camel@edumazet-laptop>
	<AANLkTinq9ABi0prxe0m1Ma6rno4UnAOzuW-b5L362ij9@mail.gmail.com>
	<1293984348.2535.101.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Matt Carlson <mcarlson@broadcom.com>,
	Michael Leun <lkml20101129@newton.leun.net>,
	Michael Chan <mchan@broadcom.com>,
	David Miller <davem@davemloft.net>,
	Ben Greear <greearb@candelatech.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1293984348.2535.101.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 2, 2011 at 11:05 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le samedi 01 janvier 2011 =E0 19:27 -0500, Jesse Gross a =E9crit :
>> On Sat, Jan 1, 2011 at 12:03 PM, Eric Dumazet <eric.dumazet@gmail.co=
m> wrote:
>> > Le mardi 14 d=E9cembre 2010 =E0 11:15 -0800, Matt Carlson a =E9cri=
t :
>> >
>> >> Thanks for the comments Jesse. =A0Below is an updated patch.
>> >>
>> >> Michael, I'm wondering if the difference in behavior can be expla=
ined by
>> >> the presence or absence of management firmware. =A0Can you look a=
t the
>> >> driver sign-on messages in your syslogs for ASF[]? =A0I'm half ex=
pecting
>> >> the 5752 to show "ASF[0]" and the 5714 to show "ASF[1]". =A0If yo=
u see
>> >> this, and the below patch doesn't fix the problem, let me know. =A0=
I have
>> >> another test I'd like you to run.
>> >>
>> >> ----
>> >>
>> >> [PATCH] tg3: Use new VLAN code
>> >>
>> >> This patch pivots the tg3 driver to the new VLAN infrastructure.
>> >> All references to vlgrp have been removed and all VLAN code is
>> >> unconditionally active.
>> >>
>> >> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
>>
>> [...]
>>
>> > Hi Matt.
>> >
>> > Any news on this patch ?
>> >
>> > Without it, net-next-2.6 doesnt work for me on a vlan setup on top=
 of
>> > bonding.
>> >
>> > (bond0 : eth1 & eth2, eth1 being bnx2, eth2 beging tg3)
>> >
>> > ip link add link bond0 vlan.103 type vlan id 103
>> > ip addr add 192.168.20.110/24 dev vlan.103
>> > ip link set vlan.103 up
>> >
>> >
>> > If active slave is eth1 (bnx2), everything works, but if active sl=
ave is
>> > eth2 (tg3), incoming tagged frames (on vlan 103) are lost.
>>
>> This patch isn't quite right - it always disables vlan stripping
>> unless management firmware is in use, so it's not really a correct
>> fix.
>>
>> You said that this used to work correctly on this NIC? =A0Does it wo=
rk
>> without a bond, just a vlan on the tg3 device? =A0It sounds like Mic=
hael
>> has a problem with vlan stripping on one of his NICs but if it works
>> with just a vlan or on older kernels, it's probably not the same
>> thing.
>>
>
> 1) current linux-2.6 works OK for me (and previous versions as well, =
I
> am using this vlan/bonding setup since 3 years or so on one of my dev
> machine)
>
> Only net-next-2.6 has the problem.
>
> If I remove bonding of the equation, I still have the problem, and ca=
n
> see the 'dropped' counter increasing while I send packets to eth2 (tg=
3)
>
> $ ifconfig eth2
> eth2 =A0 =A0 =A0Link encap:Ethernet =A0HWaddr 00:1E:0B:92:78:50
> =A0 =A0 =A0 =A0 =A0UP BROADCAST RUNNING MULTICAST =A0MTU:1500 =A0Metr=
ic:1
> =A0 =A0 =A0 =A0 =A0RX packets:94 errors:0 dropped:38686 overruns:0 fr=
ame:0
> =A0 =A0 =A0 =A0 =A0TX packets:18 errors:0 dropped:0 overruns:0 carrie=
r:0
> =A0 =A0 =A0 =A0 =A0collisions:0 txqueuelen:1000
> =A0 =A0 =A0 =A0 =A0RX bytes:8332 (8.1 Kb) =A0TX bytes:1392 (1.3 Kb)
> =A0 =A0 =A0 =A0 =A0Interrupt:19
> $ ifconfig vlan.103
> vlan.103 =A0Link encap:Ethernet =A0HWaddr 00:1E:0B:92:78:50
> =A0 =A0 =A0 =A0 =A0inet addr:192.168.20.110 =A0Bcast:0.0.0.0 =A0Mask:=
255.255.255.0
> =A0 =A0 =A0 =A0 =A0UP BROADCAST RUNNING MULTICAST =A0MTU:1500 =A0Metr=
ic:1
> =A0 =A0 =A0 =A0 =A0RX packets:0 errors:0 dropped:0 overruns:0 frame:0
> =A0 =A0 =A0 =A0 =A0TX packets:15 errors:0 dropped:0 overruns:0 carrie=
r:0
> =A0 =A0 =A0 =A0 =A0collisions:0 txqueuelen:0
> =A0 =A0 =A0 =A0 =A0RX bytes:0 (0.0 b) =A0TX bytes:846 (846.0 b)

Hmm, I thought that it might be some interaction with a corner case in
the networking core but now it seems less likely.  There weren't too
many vlan changes between the working and non-working states.  Plus,
since the rx counter isn't increasing, the packets probably aren't
making it anywhere.

I see that tg3 increases the drop counter in one place, which also
happens to be checking for vlan errors (at tg3.c:4753).  That seems
suspicious - maybe the NIC is only partially configured for vlan
offloading.  If we can confirm that is where the drop counter is being
incremented and what the error code is maybe it would shed some light.

If it's a driver issue I don't have much insight - maybe Matt or
bisect can help.

>> If it works on bnx2, it would seem to be a driver problem but it wou=
ld
>> be good to confirm that the tag in skb->vlan_tci is not being
>> delievered to the networking core in this case.
>
> Hmm, where do you want me to check this ?

I was thinking right before vlan_gro_receive() at tg3.c:4837.  If my
theory above is right then this obviously isn't relevant since it
won't be hit at all.  Otherwise it would be good to know exactly what
the driver is producing.
