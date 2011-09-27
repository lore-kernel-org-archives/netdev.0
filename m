From: Jesse Gross <jesse@nicira.com>
Subject: Re: [net-next 02/10] ixgbevf: Fix broken trunk vlan
Date: Tue, 27 Sep 2011 09:49:06 -0700
Message-ID: <CAEP_g=_DXCPHhWDptJ+WW-gxDCLM6pZtdaTnvFaxZ-NB3GULDg@mail.gmail.com>
References: <1316855863-6091-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1316855863-6091-3-git-send-email-jeffrey.t.kirsher@intel.com>
 <CAEP_g=93GcR7yE7N+GtaB6dpjPuGGtCBXznEmV6Sx=BX-kSbmg@mail.gmail.com>
 <43F901BD926A4E43B106BF17856F0755019C519319@orsmsx508.amr.corp.intel.com>
 <CAEP_g=-xqgrS1hjApx5bPE2GFkAPJa6meaL0nmUcUbvSOPK-hQ@mail.gmail.com>
 <43F901BD926A4E43B106BF17856F0755019C5E5B68@orsmsx508.amr.corp.intel.com>
 <CAEP_g=-OhrQ5QMbj5_d4BhLHEdDim1_STgy96Vdx5mYFagpVGg@mail.gmail.com> <43F901BD926A4E43B106BF17856F0755019C5E5E44@orsmsx508.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	Jiri Pirko <jpirko@redhat.com>
To: "Rose, Gregory V" <gregory.v.rose@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:49949 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751542Ab1I0Qt1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2011 12:49:27 -0400
Received: by vcbfk10 with SMTP id fk10so3846203vcb.19
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2011 09:49:26 -0700 (PDT)
In-Reply-To: <43F901BD926A4E43B106BF17856F0755019C5E5E44@orsmsx508.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 27, 2011 at 9:39 AM, Rose, Gregory V
<gregory.v.rose@intel.com> wrote:
>> -----Original Message-----
>> From: Jesse Gross [mailto:jesse@nicira.com]
>> Sent: Monday, September 26, 2011 5:54 PM
>> To: Rose, Gregory V
>> Cc: Kirsher, Jeffrey T; davem@davemloft.net; netdev@vger.kernel.org;
>> gospo@redhat.com; Jiri Pirko
>> Subject: Re: [net-next 02/10] ixgbevf: Fix broken trunk vlan
>>
>>
>> OK, maybe due to hardware limitations what I'm looking for just real=
ly
>> isn't possible.
>
> From what I can tell that is the case.
>
>> =C2=A0However, what I'm trying to emphasize is that vconfig
>> is not the only way that vlans can be consumed by the network stack
>> and active_vlans is just an indication of whether a vlan filter was
>> set, nothing more (perhaps I should have picked a better name when I
>> originally designed this stuff).
>
> Understood. =C2=A0The VF is incapable of receiving VLAN traffic unles=
s a filter has been set. =C2=A0It doesn't do promiscuous mode and any p=
ath that doesn't actually end up setting a VLAN filter won't receive an=
y VLAN traffic.
>
>> =C2=A0In particular, it is not intended to
>> determine whether a tag should be stripped off or not because
>> non-vconfig users don't necessarily know which vlans they care about
>> (think tcpdump or trunking over a bridge). =C2=A0A major goal of the
>> existing vlan infrastructure is to avoid having drivers make
>> assumptions about the consumer of the tag and instead just hand all
>> information over to the network stack so it can behave in a consiste=
nt
>> manner. =C2=A0That's why I was looking for alternate ways to get thi=
s
>> information without depending on active_vlans as this driver behaves
>> quite a bit differently from others, include the ixgbe PF driver.
>
> There are only two paths for the ixgbevf driver to receive VLAN traff=
ic. =C2=A0Either a VLAN filter has been set, which will result in a bit=
 tag in active_vlans being set or the system administrator in the host =
VMM has put the VF device in trunk VLAN mode using the 'ip link set <de=
v> vf <n> <vlanid>' path. =C2=A0There is no other way for it to receive=
 VLAN traffic, so I think we're fine. =C2=A0And keep in mind, once the =
system admin has put the VF device in trunk vlan mode, the VF is no lon=
ger allowed, as a policy implemented in the PF driver, to set any other=
 VLAN filters. =C2=A0Even if it did, it wouldn't work due to the operat=
ional characteristics of the VF device HW.
>
> The methods by which the ixgbe driver, as a fully featured Physical F=
unction device, are quite a bit more varied. =C2=A0I believe you're thi=
nking of the VF device as a typical Ethernet device and that is just no=
t the case.

Yes, I think you're right.  Thanks for the explanation.
