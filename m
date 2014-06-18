From: Ben Greear <greearb@candelatech.com>
Subject: Re: How is IPv6 dhcp supposed to work?
Date: Wed, 18 Jun 2014 07:17:48 -0700
Message-ID: <53A19F8C.6060505@candelatech.com>
References: <53A0B617.6070600@candelatech.com> <1403044471.16272.20.camel@dcbw.local> <53A0CC31.6090707@candelatech.com> <87ha3isdu6.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dan Williams <dcbw@redhat.com>, netdev <netdev@vger.kernel.org>
To: =?UTF-8?B?QmrDuHJuIE1vcms=?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:52938 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756732AbaFRORt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2014 10:17:49 -0400
In-Reply-To: <87ha3isdu6.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/18/2014 03:37 AM, Bj=C3=B8rn Mork wrote:
> Ben Greear <greearb@candelatech.com> writes:
>=20
>> Does that router advert below look proper?=20
>=20
> No, it doesn't.  How did you create this?

With a radvd config with this section in it:

interface rddVR2
{
   AdvSendAdvert on;
   IgnoreIfMissing on;
   MinRtrAdvInterval 30;
   MaxRtrAdvInterval 100;
   prefix 2001:78::1/64
   {
      AdvOnLink on;
      AdvAutonomous on;
      AdvRouterAddr on;
   };
   route ::/0 {
   };
};


I'll try changing it to zero out the low 64-bits....


> Quoting RFC 4861 (http://tools.ietf.org/html/rfc4861#section-4.6.2 ):
>=20
>       Prefix         An IP address or a prefix of an IP address.  The
>                      Prefix Length field contains the number of valid
>                      leading bits in the prefix.  The bits in the pre=
fix
>                      after the prefix length are reserved and MUST be
>                      initialized to zero by the sender and ignored by
>                      the receiver.=20
>=20
>=20
> So that prefix should have been '2001:78::'
>=20
> Note that you don't necessarily need to include a prefix option in th=
e
> RA.  If you don't want clients on the link connected to the router to
> communicate directly on L2.  This is the typical ISP use case.

I just want the 'rddVR2' interface to effectively give out it's own
IPv6 addr as the default IPv6 gateway for anything connected to rddVR2,
and I want the 'rddVR3' interface (this is a veth pair, by the way)
to use that IPv6 addr as it's gateway.

To answer another question in this thread:  Yes, accept_ra is 1, and
I checked the other pertinent procfs values and they are correct for
my desired behaviour as far as I can tell.

Thanks,
Ben


--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
