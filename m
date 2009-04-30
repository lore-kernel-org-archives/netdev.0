From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [RFC] Add clause 45 ioctl
Date: Thu, 30 Apr 2009 19:21:03 +0300
Message-ID: <1241108463.10391.5.camel@lb-tlvb-eliezer>
References: <1240913334.8347.6.camel@lb-tlvb-eliezer>
 <1240924931.3200.3.camel@achroite>
 <1241103959.10391.3.camel@lb-tlvb-eliezer>
 <1241106541.3185.27.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David Miller" <davem@davemloft.net>,
	"Yaniv Rosner" <yaniv.rosner@broadcom.com>
To: "Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4741 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754423AbZD3QYM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2009 12:24:12 -0400
In-Reply-To: <1241106541.3185.27.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-04-30 at 08:49 -0700, Ben Hutchings wrote:
> On Thu, 2009-04-30 at 18:05 +0300, Eilon Greenstein wrote:
> > On Tue, 2009-04-28 at 06:22 -0700, Ben Hutchings wrote:
> > > > I'm sending this as RFC - if anyone has alternative suggestions=
 on how
> > > > user space application can access the PHY, I would appreciate i=
t.
> > > [...]
> > >=20
> > > I was working on an alternate interface that would use the existi=
ng
> > > structure and ioctls.  There are at least two drivers (cxgb3 and =
sfc)
> > > that already do this, though they currently pack PRTAD and DEVAD
> > > differently in the phy_id field.
> >=20
> > I can use the same approach and overload the CL22 definitions, but =
don't
> > you think it is cleaner to add the CL45 definition?
>=20
> I don't know that it's cleaner, but it's certainly more compatible.
> This interface can also be implemented in out-of-tree drivers for old=
er
> kernels whereas new generic ioctls cannot.
>=20
> > I think that the
> > fact that two drivers are already overloading the CL22 for CL45 usa=
ge is
> > showing that CL45 is needed, and the fact that they are doing that
> > differently shows that there is a need for a clean definition. I'm =
just
> > thinking about someone trying to write an application for all CL45
> > supporting drivers - it is easier if there is a clean interface.
> >=20
> > What do you say?
>=20
> I defined a generic format:
>=20
> =EF=BB=BFclause 45 generic: 100000pppppddddd
>=20
> which is distinguishable from the existing:
>=20
> clause 22:         00000000000ppppp
> clause 45 sfc:     000001pppppddddd
> clause 45 cxgb3:   000ppppp000ddddd (prtad !=3D 0)
>=20
> The drivers that already had their own formats will convert them to t=
he
> generic format before calling the generic handler.

OK - I will implement it as according to your new definition:
clause 45 generic: 100000pppppddddd

Thanks!
Eilon


