From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH 2.6.36] vlan: Avoid hwaccel vlan packets when vid not used
Date: Sat, 1 Jan 2011 19:27:49 -0500
Message-ID: <AANLkTinq9ABi0prxe0m1Ma6rno4UnAOzuW-b5L362ij9@mail.gmail.com>
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
In-Reply-To: <1293901393.2535.49.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 1, 2011 at 12:03 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le mardi 14 d=E9cembre 2010 =E0 11:15 -0800, Matt Carlson a =E9crit :
>
>> Thanks for the comments Jesse. =A0Below is an updated patch.
>>
>> Michael, I'm wondering if the difference in behavior can be explaine=
d by
>> the presence or absence of management firmware. =A0Can you look at t=
he
>> driver sign-on messages in your syslogs for ASF[]? =A0I'm half expec=
ting
>> the 5752 to show "ASF[0]" and the 5714 to show "ASF[1]". =A0If you s=
ee
>> this, and the below patch doesn't fix the problem, let me know. =A0I=
 have
>> another test I'd like you to run.
>>
>> ----
>>
>> [PATCH] tg3: Use new VLAN code
>>
>> This patch pivots the tg3 driver to the new VLAN infrastructure.
>> All references to vlgrp have been removed and all VLAN code is
>> unconditionally active.
>>
>> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>

[...]

> Hi Matt.
>
> Any news on this patch ?
>
> Without it, net-next-2.6 doesnt work for me on a vlan setup on top of
> bonding.
>
> (bond0 : eth1 & eth2, eth1 being bnx2, eth2 beging tg3)
>
> ip link add link bond0 vlan.103 type vlan id 103
> ip addr add 192.168.20.110/24 dev vlan.103
> ip link set vlan.103 up
>
>
> If active slave is eth1 (bnx2), everything works, but if active slave=
 is
> eth2 (tg3), incoming tagged frames (on vlan 103) are lost.

This patch isn't quite right - it always disables vlan stripping
unless management firmware is in use, so it's not really a correct
fix.

You said that this used to work correctly on this NIC?  Does it work
without a bond, just a vlan on the tg3 device?  It sounds like Michael
has a problem with vlan stripping on one of his NICs but if it works
with just a vlan or on older kernels, it's probably not the same
thing.

If it works on bnx2, it would seem to be a driver problem but it would
be good to confirm that the tag in skb->vlan_tci is not being
delievered to the networking core in this case.
