From: Kay Sievers <kay.sievers@vrfy.org>
Subject: Re: [PATCH] igbvf: avoid name clash between PF and VF
Date: Wed, 30 Jun 2010 13:11:33 +0200
Message-ID: <AANLkTin08wA8a5nCnq-djQnTSq1g2TQ7GqYfCEBCTn9l@mail.gmail.com>
References: <4C2B0614.9040004@redhat.com> <1277894679.28819.60.camel@localhost>
	<4C2B22FD.4050705@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	netdev <netdev@vger.kernel.org>,
	e1000-devel@lists.sourceforge.net,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	gregory.v.rose@intel.com, jeffrey.t.kirsher@intel.com,
	Andy Gospodarek <gospo@redhat.com>, harald@redhat.com
To: Stefan Assmann <sassmann@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:42635 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753425Ab0F3LL6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 07:11:58 -0400
Received: by fg-out-1718.google.com with SMTP id 22so139132fge.1
        for <netdev@vger.kernel.org>; Wed, 30 Jun 2010 04:11:57 -0700 (PDT)
In-Reply-To: <4C2B22FD.4050705@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 30, 2010 at 12:57, Stefan Assmann <sassmann@redhat.com> wro=
te:
> On 30.06.2010 12:44, Ben Hutchings wrote:
>> On Wed, 2010-06-30 at 10:53 +0200, Stefan Assmann wrote:
>>> From: Stefan Assmann <sassmann@redhat.com>
>>>
>>> It looks like the VFs get initialized before all the PFs are. There=
fore
>>> the udev mapping MAC <-> ethX (for PFs) gets screwed because the VF=
s
>>> may grab the ethX interface names (reserved by udev) for the PFs.
>>>
>>> Example:
>>> igb max_vfs=3D0
>>> eth0 =C2=A0 =C2=A0 =C2=A0Link encap:Ethernet =C2=A0HWaddr 00:13:20:=
=467:A5:9E
>>> eth1 =C2=A0 =C2=A0 =C2=A0Link encap:Ethernet =C2=A0HWaddr 00:13:20:=
=467:A5:9F
>>> eth2 =C2=A0 =C2=A0 =C2=A0Link encap:Ethernet =C2=A0HWaddr 00:13:20:=
=467:A5:A0
>>> eth3 =C2=A0 =C2=A0 =C2=A0Link encap:Ethernet =C2=A0HWaddr 00:13:20:=
=467:A5:A1
>>> igb max_vfs=3D1
>>> eth0 =C2=A0 =C2=A0 =C2=A0Link encap:Ethernet =C2=A0HWaddr 00:13:20:=
=467:A5:9E
>>> eth1 =C2=A0 =C2=A0 =C2=A0Link encap:Ethernet =C2=A0HWaddr 0A:CF:41:=
69:F7:A9
>>> eth2 =C2=A0 =C2=A0 =C2=A0Link encap:Ethernet =C2=A0HWaddr 3A:FE:20:=
4C:2A:3B
>>> eth3 =C2=A0 =C2=A0 =C2=A0Link encap:Ethernet =C2=A0HWaddr C6:C3:B1:=
56:C9:A4
>>> eth3_rename Link encap:Ethernet =C2=A0HWaddr 00:13:20:F7:A5:9F
>>> eth4 =C2=A0 =C2=A0 =C2=A0Link encap:Ethernet =C2=A0HWaddr 6E:8A:8A:=
A3:5F:69
>>> eth4_rename Link encap:Ethernet =C2=A0HWaddr 00:13:20:F7:A5:A0
>>> eth5_rename Link encap:Ethernet =C2=A0HWaddr 00:13:20:F7:A5:A1
>>>
>>> In the example above VF 0A:CF:41:69:F7:A9 grabs eth1 but udev
>>> has a rule that says eth1 should be assigned PF 00:13:20:F7:A5:9F
>>> (eth3_rename) and waits for the VF to disappear to rename eth3_rena=
me
>>> to eth1. Unfortunately eth1 is not going to disappear.
>>> This is not a udev bug since udev doesn't create persistent rules f=
or
>>> VFs as their MAC address changes every reboot.
>> [...]
>>
>> I think it is a bug in the udev rules: udev should rename the VFs ev=
en
>> though their names won't be persistent.

Udev writes out these configs to a rules file, and therefore can never
handle random MAC addresses, as they would just accumulate in the
rules file with a new entry at every bootup.

Stuff like this is just not supported at the moment with the rather
simple logic it has, and there is no current plan/idea, or anybody
working on changing/improving this at the moment.

Kay
