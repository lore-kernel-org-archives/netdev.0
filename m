From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 1/3] vlan: Do not support clearing VLAN_FLAG_REORDER_HDR
Date: Sun, 22 May 2011 18:45:53 -0700
Message-ID: <m1ei3qdwa6.fsf@fess.ebiederm.org>
References: <1302241713-3637-1-git-send-email-jpirko@redhat.com>
	<20110412.141645.112604563.davem@davemloft.net>
	<BANLkTikSKiYoiOLB=i7qjR0N--CAQ2dHWw@mail.gmail.com>
	<20110521072925.GA2588@jirka.orion>
	<BANLkTinZUATEjBij+rwBTn=n-Tau5qHPWw@mail.gmail.com>
	<4DD7BB61.9050200@gmail.com>
	<BANLkTinqFJa-B7E7tonzOKGV4etZHUkUug@mail.gmail.com>
	<4DD87C25.4030701@gmail.com> <20110522062915.GA2611@jirka.orion>
	<m17h9jp7js.fsf@fess.ebiederm.org>
	<BANLkTi=4JJa-J-p_JbY1PfooT75KfSB4uA@mail.gmail.com>
	<m1ei3qjzix.fsf_-_@fess.ebiederm.org>
	<4DD97A44.2020708@candelatech.com> <m1wrhigy37.fsf@fess.ebiederm.org>
	<BANLkTinXFYzzj3R97mKH-90xM64BDwN8aA@mail.gmail.com>
	<BANLkTik6etR8V1qeDnYBKt6BaODBe8kUOw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>,
	Jiri Pirko <jpirko@redhat.com>,
	Nicolas de =?utf-8?Q?Peslo=C3=BCan?=
	<nicolas.2p.debian@gmail.com>, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net,
	Jesse Gross <jesse@nicira.com>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:57077 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753538Ab1EWBp7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2011 21:45:59 -0400
In-Reply-To: <BANLkTik6etR8V1qeDnYBKt6BaODBe8kUOw@mail.gmail.com> (Changli
	Gao's message of "Mon, 23 May 2011 09:26:59 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changli Gao <xiaosuo@gmail.com> writes:

> On Mon, May 23, 2011 at 8:38 AM, Changli Gao <xiaosuo@gmail.com> wrot=
e:
>> On Mon, May 23, 2011 at 6:38 AM, Eric W. Biederman
>> <ebiederm@xmission.com> wrote:
>>>
>>>> Many years ago we supported the REORDER, but we suggested disablin=
g
>>>> it for most users because it was a performance drag. =C2=A0Funny t=
hat now
>>>> it seems to be the opposite!
>>>
>>> Yes it is funny. =C2=A0I looked in history a while back and what I =
saw was
>>> that REORDER was always enabled by default and it took some serious
>>> effort to figure out how to get vconfig to disable REORDER. ip does=
n't
>>> admit that REORDER can be disabled at all.
>>>
>>
>> Really?
>>
>> Quoted from the manual page of vconfig
>> =C2=A0 =C2=A0 =C2=A0 set_flag [vlan-device] 0 | 1
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0When =C2=A01, =C2=A0=
ethernet =C2=A0header =C2=A0reorders =C2=A0are turned on. Dumping the
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0device will appear a=
s a common ethernet =C2=A0device =C2=A0without =C2=A0vlans.
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0When =C2=A00(default=
) =C2=A0however, =C2=A0ethernet =C2=A0headers are not reordered,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0which results in vla=
n tagged packets when =C2=A0dumping =C2=A0the =C2=A0device.
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Usually the default =
gives no problems, but some packet filtering
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0programs might have =
problems with it.
>>
>> reordered is disabled by default. I also concern the performance.
>> Untag and then tag are expensive for the NICs which don't support
>> hw-accel-vlan-rx/tx.
>>
>
> For ip:
> localhost ~ # ip link add link eth0 vlan1 type vlan help
> Usage: ... vlan id VLANID [ FLAG-LIST ]
>                           [ ingress-qos-map QOS-MAP ] [ egress-qos-ma=
p QOS-MAP ]

Apparently I was blind when I looked at iproute.  I am certain I didn't
see it there but iproute clearly has the option to set or clear reorder=
_hdr.

> VLANID :=3D 0-4095
> FLAG-LIST :=3D [ FLAG-LIST ] FLAG
> FLAG :=3D [ reorder_hdr { on | off } ] [ gvrp { on | off } ]
>         [ loose_binding { on | off } ]
> QOS-MAP :=3D [ QOS-MAP ] QOS-MAPPING
> QOS-MAPPING :=3D FROM:TO
>
> After checking the code, I found reorder_hdr is off by default.

In iproute reorder_hdr is not modified by default which is subtly
different.

> In another side, is there a specification which defines the
> hw-accel-vlan-rx?

I don't know.

I have just been trying to clean up the mess since some of the
hw-accel-vlan code broke my use case, by delivering packets with
priority but no vlan (aka vlan 0 packets) twice to my pf_packet sockets=
=2E

Eric

