From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC] Add clause 45 ioctl
Date: Thu, 30 Apr 2009 16:49:01 +0100
Message-ID: <1241106541.3185.27.camel@achroite>
References: <1240913334.8347.6.camel@lb-tlvb-eliezer>
	 <1240924931.3200.3.camel@achroite>
	 <1241103959.10391.3.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Yaniv Rosner <yaniv.rosner@broadcom.com>
To: Eilon Greenstein <eilong@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:46459 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933041AbZD3PtP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2009 11:49:15 -0400
In-Reply-To: <1241103959.10391.3.camel@lb-tlvb-eliezer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-04-30 at 18:05 +0300, Eilon Greenstein wrote:
> On Tue, 2009-04-28 at 06:22 -0700, Ben Hutchings wrote:
> > > I'm sending this as RFC - if anyone has alternative suggestions o=
n how
> > > user space application can access the PHY, I would appreciate it.
> > [...]
> >=20
> > I was working on an alternate interface that would use the existing
> > structure and ioctls.  There are at least two drivers (cxgb3 and sf=
c)
> > that already do this, though they currently pack PRTAD and DEVAD
> > differently in the phy_id field.
>=20
> I can use the same approach and overload the CL22 definitions, but do=
n't
> you think it is cleaner to add the CL45 definition?

I don't know that it's cleaner, but it's certainly more compatible.
This interface can also be implemented in out-of-tree drivers for older
kernels whereas new generic ioctls cannot.

> I think that the
> fact that two drivers are already overloading the CL22 for CL45 usage=
 is
> showing that CL45 is needed, and the fact that they are doing that
> differently shows that there is a need for a clean definition. I'm ju=
st
> thinking about someone trying to write an application for all CL45
> supporting drivers - it is easier if there is a clean interface.
>=20
> What do you say?

I defined a generic format:

=EF=BB=BFclause 45 generic: 100000pppppddddd

which is distinguishable from the existing:

clause 22:         00000000000ppppp
clause 45 sfc:     000001pppppddddd
clause 45 cxgb3:   000ppppp000ddddd (prtad !=3D 0)

The drivers that already had their own formats will convert them to the
generic format before calling the generic handler.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

