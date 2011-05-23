From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH 1/3] vlan: Do not support clearing VLAN_FLAG_REORDER_HDR
Date: Mon, 23 May 2011 09:26:59 +0800
Message-ID: <BANLkTik6etR8V1qeDnYBKt6BaODBe8kUOw@mail.gmail.com>
References: <1302241713-3637-1-git-send-email-jpirko@redhat.com>
 <20110412.141645.112604563.davem@davemloft.net> <BANLkTikSKiYoiOLB=i7qjR0N--CAQ2dHWw@mail.gmail.com>
 <20110521072925.GA2588@jirka.orion> <BANLkTinZUATEjBij+rwBTn=n-Tau5qHPWw@mail.gmail.com>
 <4DD7BB61.9050200@gmail.com> <BANLkTinqFJa-B7E7tonzOKGV4etZHUkUug@mail.gmail.com>
 <4DD87C25.4030701@gmail.com> <20110522062915.GA2611@jirka.orion>
 <m17h9jp7js.fsf@fess.ebiederm.org> <BANLkTi=4JJa-J-p_JbY1PfooT75KfSB4uA@mail.gmail.com>
 <m1ei3qjzix.fsf_-_@fess.ebiederm.org> <4DD97A44.2020708@candelatech.com>
 <m1wrhigy37.fsf@fess.ebiederm.org> <BANLkTinXFYzzj3R97mKH-90xM64BDwN8aA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>,
	Jiri Pirko <jpirko@redhat.com>,
	=?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net,
	Jesse Gross <jesse@nicira.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:63019 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751120Ab1EWB1U convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2011 21:27:20 -0400
Received: by bwz15 with SMTP id 15so4317520bwz.19
        for <netdev@vger.kernel.org>; Sun, 22 May 2011 18:27:19 -0700 (PDT)
In-Reply-To: <BANLkTinXFYzzj3R97mKH-90xM64BDwN8aA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 23, 2011 at 8:38 AM, Changli Gao <xiaosuo@gmail.com> wrote:
> On Mon, May 23, 2011 at 6:38 AM, Eric W. Biederman
> <ebiederm@xmission.com> wrote:
>>
>>> Many years ago we supported the REORDER, but we suggested disabling
>>> it for most users because it was a performance drag. =A0Funny that =
now
>>> it seems to be the opposite!
>>
>> Yes it is funny. =A0I looked in history a while back and what I saw =
was
>> that REORDER was always enabled by default and it took some serious
>> effort to figure out how to get vconfig to disable REORDER. ip doesn=
't
>> admit that REORDER can be disabled at all.
>>
>
> Really?
>
> Quoted from the manual page of vconfig
> =A0 =A0 =A0 set_flag [vlan-device] 0 | 1
> =A0 =A0 =A0 =A0 =A0 =A0 =A0When =A01, =A0ethernet =A0header =A0reorde=
rs =A0are turned on. Dumping the
> =A0 =A0 =A0 =A0 =A0 =A0 =A0device will appear as a common ethernet =A0=
device =A0without =A0vlans.
> =A0 =A0 =A0 =A0 =A0 =A0 =A0When =A00(default) =A0however, =A0ethernet=
 =A0headers are not reordered,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0which results in vlan tagged packets when =
=A0dumping =A0the =A0device.
> =A0 =A0 =A0 =A0 =A0 =A0 =A0Usually the default gives no problems, but=
 some packet filtering
> =A0 =A0 =A0 =A0 =A0 =A0 =A0programs might have problems with it.
>
> reordered is disabled by default. I also concern the performance.
> Untag and then tag are expensive for the NICs which don't support
> hw-accel-vlan-rx/tx.
>

=46or ip:
localhost ~ # ip link add link eth0 vlan1 type vlan help
Usage: ... vlan id VLANID [ FLAG-LIST ]
                          [ ingress-qos-map QOS-MAP ] [ egress-qos-map =
QOS-MAP ]

VLANID :=3D 0-4095
=46LAG-LIST :=3D [ FLAG-LIST ] FLAG
=46LAG :=3D [ reorder_hdr { on | off } ] [ gvrp { on | off } ]
        [ loose_binding { on | off } ]
QOS-MAP :=3D [ QOS-MAP ] QOS-MAPPING
QOS-MAPPING :=3D FROM:TO

After checking the code, I found reorder_hdr is off by default.

In another side, is there a specification which defines the hw-accel-vl=
an-rx?

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
