From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: phy address in the device tree, vs auto probing
Date: Wed, 10 Feb 2010 12:12:14 -0700
Message-ID: <fa686aa41002101112o66a74f60jc65fdffb48fd7213@mail.gmail.com>
References: <7d35ae9a-9ac0-46e6-8817-15315e0dcc07@SG2EHSMHS004.ehs.local>
	<fa686aa41002101014s43682e3cra55854b82a40bb5f@mail.gmail.com>
	<4B72FAB2.5000804@freescale.com> <20100210.113720.1026572228166328165.imp@bsdimp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: scottwood@freescale.com, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org, afleming@freescale.com
To: "M. Warner Losh" <imp@bsdimp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f204.google.com ([209.85.210.204]:63852 "EHLO
	mail-yx0-f204.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755987Ab0BJTMg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2010 14:12:36 -0500
Received: by yxe42 with SMTP id 42so355400yxe.22
        for <netdev@vger.kernel.org>; Wed, 10 Feb 2010 11:12:36 -0800 (PST)
In-Reply-To: <20100210.113720.1026572228166328165.imp@bsdimp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 10, 2010 at 11:37 AM, M. Warner Losh <imp@bsdimp.com> wrote=
:
> In message: <4B72FAB2.5000804@freescale.com>
> =A0 =A0 =A0 =A0 =A0 =A0Scott Wood <scottwood@freescale.com> writes:
> : Grant Likely wrote:
> : >> 2. Or a special value (-1 or something not 0 - 31) in the phy ad=
dress
> : >> that specifies to auto probe as illustrated below.
> : >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0p=
hy0: phy@7 {
> : >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0reg =3D <-1>;
> : >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}=
 ;
> : > I don't like abusing the reg property in this way. =A0I wonder if=
 a new
> : > empty property would be a better way to indicate this. =A0Maybe
> : > "phy-probe-address;"? =A0It would also be important to specify in=
 the
> : > binding that only one phy node is allowed when phy-probe-address =
is
> : > used.
> : > Also, without a known reg the 'phy@7' name is inaccurate. =A0Drop=
 the
> : > @7.
> : > Scott, Andy: any thoughts?
> :
> : I'm not fond of the -1. =A0I'd prefer the explicit phy-probe-addres=
s
> : property, though I don't mind too much using the absence of reg.
>
> There are times that you'd want a list of PHY addresses to use. =A0Th=
is
> suggests a bitmask, but I don't know if they are common enough to
> warrant the extra burden on the usual case...

Are you talking a single MAC attached to multiple PHYs?  If so, then
the current device tree binding doesn't support this, but it would be
easy to extend the current binding by making the phy-handle property a
list of phy nodes phandes.

If you're talking about a phy being able to appear at a number of
addresses, then perhaps this could be handled by simple listing the
full range of base addresses in the phy's reg property.  So for a phy
that could appear at address 2, 3, 6, or 7:

reg =3D <2 3 6 7>;

g.

--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
