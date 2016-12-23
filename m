From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] ethtool: add one ethtool option to set relax ordering
 mode
Date: Thu, 22 Dec 2016 17:06:43 -0800
Message-ID: <1482455203.2481.31.camel@intel.com>
References: <1481179898-10668-1-git-send-email-maowenan@huawei.com>
         <1481179898-10668-2-git-send-email-maowenan@huawei.com>
         <20161221172759.1bc0d0dd@xeon-e3>
         <F95AC9340317A84688A5F0DF0246F3F20151F189@szxeml504-mbs.china.huawei.com>
         <CAKgT0Uc2ztu_iDn79zdNtsAdb-Ftu65V6YHV-sqXb6vTCTiGCQ@mail.gmail.com>
         <F95AC9340317A84688A5F0DF0246F3F20151FD1C@szxeml504-mbs.china.huawei.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
        protocol="application/pgp-signature"; boundary="=-TY5wrsu/z1vdfhqBHY4g"
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "weiyongjun (A)" <weiyongjun1@huawei.com>,
        Dingtianhong <dingtianhong@huawei.com>
To: maowenan <maowenan@huawei.com>,
        Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:47874 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933659AbcLWBGp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 22 Dec 2016 20:06:45 -0500
In-Reply-To: <F95AC9340317A84688A5F0DF0246F3F20151FD1C@szxeml504-mbs.china.huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-TY5wrsu/z1vdfhqBHY4g
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2016-12-23 at 00:40 +0000, maowenan wrote:
> > -----Original Message-----
> > From: Alexander Duyck [mailto:alexander.duyck@gmail.com]
> > Sent: Thursday, December 22, 2016 11:54 PM
> > To: maowenan
> > Cc: Stephen Hemminger; netdev@vger.kernel.org; jeffrey.t.kirsher@intel.
> > com;
> > weiyongjun (A); Dingtianhong
> > Subject: Re: [PATCH] ethtool: add one ethtool option to set relax
> > ordering mode
> >=20
> > On Wed, Dec 21, 2016 at 5:39 PM, maowenan <maowenan@huawei.com>
> > wrote:
> > >=20
> > >=20
> > > > -----Original Message-----
> > > > From: Stephen Hemminger [mailto:stephen@networkplumber.org]
> > > > Sent: Thursday, December 22, 2016 9:28 AM
> > > > To: maowenan
> > > > Cc: netdev@vger.kernel.org; jeffrey.t.kirsher@intel.com
> > > > Subject: Re: [PATCH] ethtool: add one ethtool option to set relax
> > > > ordering mode
> > > >=20
> > > > On Thu, 8 Dec 2016 14:51:38 +0800
> > > > Mao Wenan <maowenan@huawei.com> wrote:
> > > >=20
> > > > > This patch provides one way to set/unset IXGBE NIC TX and RX
> > > > > relax
> > > > > ordering mode, which can be set by ethtool.
> > > > > Relax ordering is one mode of 82599 NIC, to enable this mode can
> > > > > enhance the performance for some cpu architecure.
> > > >=20
> > > > Then it should be done by CPU architecture specific quirks
> > > > (preferably in PCI
> > > > layer) so that all users get the option without having to do manual
> >=20
> > intervention.
> > > >=20
> > > > > example:
> > > > > ethtool -s enp1s0f0 relaxorder off
> > > > > ethtool -s enp1s0f0 relaxorder on
> > > >=20
> > > > Doing it via ethtool is a developer API (for testing) not something
> > > > that makes sense in production.
> > >=20
> > >=20
> > > This feature is not mandatory for all users, acturally relax ordering
> > > default configuration of 82599 is 'disable', So this patch gives one
> > > way to
> >=20
> > enable relax ordering to be selected in some performance condition.
> >=20
> > That isn't quite true.=C2=A0=C2=A0The default for Sparc systems is to h=
ave it
> > enabled.
> >=20
> > Really this is something that is platform specific.=C2=A0=C2=A0I agree =
with
> > Stephen that it
> > would work better if this was handled as a series of platform specific
> > quirks
> > handled at something like the PCI layer rather than be a switch the
> > user can
> > toggle on and off.
> >=20
> > With that being said there are changes being made that should help to
> > improve
> > the situation.=C2=A0=C2=A0Specifically I am looking at adding support f=
or the
> > DMA_ATTR_WEAK_ORDERING which may also allow us to identify cases where
> > you might be able to specify the DMA behavior via the DMA mapping
> > instead of
> > having to make the final decision in the device itself.
> >=20
> > - Alex
>=20
> Yes, Sparc is a special case. From the NIC driver point of view, It is no
> need for=C2=A0
> some ARCHs to do particular operation and compiling branch, ethtool is a
> flexible=C2=A0
> method for user to make decision whether on|off this feature.
> I think Jeff as maintainer of 82599 has some comments about this.

My original comment/objection was that you attempted to do this change as a
module parameter to the ixgbe driver, where I directed you to use ethtool=
=20
so that other drivers could benefit from the ability to enable/disable
relaxed ordering.  As far as how it gets implemented in ethtool or PCI
layer, makes little difference to me, I only had issues with the driver
specific module parameter implementation, which is not acceptable.
--=-TY5wrsu/z1vdfhqBHY4g
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJYXHijAAoJEOVv75VaS+3OLukP/Apv7DOQI/EsxIuy9702wYcs
eVZXmYGg6swg5y8qQKS/+pNcVWWjBgG2bzdhBn34LfH30pled2RPqQfaF5lKSA+T
GxVbyNx68998tXsdRxd1+mRQZ8m2pnFgtQZc8UuQlZPilOMJSPwZaxw5tTrSpN21
heRG29zx4CDvXOLP4wKd7jrqpMFWJbYdRh3cUpeWCzLvKlDq3Ww3BWRWVjpNMx8m
axhPdso2wlClps/3P+qCaYEWOpAgfxGf678dknsykDL6Gy+/KuDYZlkPMwFv2LFO
XXxN6mREP4SvF0wBX4j+grUhNzzbJnSPlTPUQYJxcFBa21aRRafODKwNj6T+peiS
X9ozPxlXkgZF3RAe/XVmg6vO2/3nyAB+XcOy/rmPg0P4EvMIJ3keDJ6y582UWbGm
VCdzpAxLbOx4ZTxvq/f9wQ+LayGTTiDAaM/PAp9pWgSIoHHt03NvD+xZvOta3ZCu
RlbysdzLxZgd6UnauV7pYqRyHbA3kwzU7WMw8h4xqW3wZ3FqjiQlABq5GtbCrTHZ
e4KUu8u9cLmviE8BgchYESVAlhAfnEEigxZvYP1UuobTx7z7FhaM5iBIXO8Ago3P
AwF/FkAJWp48e5xNXUsMhElTUPSLnngk22ASskjQVnED2uw5VBSFOp5cXYXyqqsM
E+aS7WFRCJ1l+ZlQLTrf
=D2Kg
-----END PGP SIGNATURE-----

--=-TY5wrsu/z1vdfhqBHY4g--
