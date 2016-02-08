From: Jakub =?UTF-8?B?S2ljacWEc2tp?= <moorray3@wp.pl>
Subject: Re: [PATCH 2/2] fm10k: correctly report error when changing number
 of channels
Date: Mon, 8 Feb 2016 19:23:38 +0000
Message-ID: <20160208192338.7379064f@jkicinski-Precision-T1700>
References: <1454704221-14238-1-git-send-email-jacob.e.keller@intel.com>
	<1454704221-14238-3-git-send-email-jacob.e.keller@intel.com>
	<20160208132632.3010dee3@jkicinski-Precision-T1700>
	<1454951595.25441.4.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Keller, Jacob E" <jacob.e.keller@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.11]:48099 "EHLO mx4.wp.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750982AbcBHTXz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2016 14:23:55 -0500
In-Reply-To: <1454951595.25441.4.camel@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 8 Feb 2016 17:13:15 +0000, Keller, Jacob E wrote:
> On Mon, 2016-02-08 at 13:26 +0000, Jakub Kicinski wrote:
> > On Fri,=C2=A0=C2=A05 Feb 2016 12:30:21 -0800, Jacob Keller wrote:
> > > +#define FM10K_FLAG_RETA_TABLE_CONFIGURED	(u32)(BIT(6))
> >=20
> > If we go with your proposal every driver will have to keep track of=
=C2=A0
> > how the RSS table was set and find max value on queue reconfig -
> > replicating effort and leaving space for diverging behaviour...
> >=20
>=20
> in which behavior has already diverged quite significantly, so shorin=
g
> that up would be good as well.
>=20
> > Would it be worth considering to place more of this code in the cor=
e?
>=20
> Yes. I was unsure of how to do this, but I think I have a possible
> solution. Since basically all drivers are going to have the same issu=
e,
> I think we can just do the check inside net/core/ethtool.c
>=20
> At least some of the check can be done inside core ethtool, but I thi=
nk
> we still need a way for driver to know it is in "default" mode, as th=
e
> driver does behave differently in its reset flow depending on whether
> the RSS table has been set.
>=20
> Maybe we can store it as a flag in the netdev structure instead?

Either flag in the netdev or keep your reset callback.  Neither seems
spectacularly clean.  Maybe someone with a better idea will speak up ;)
