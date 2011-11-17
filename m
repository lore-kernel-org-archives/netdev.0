From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] Add ethtool to mii advertisment conversion helpers
Date: Thu, 17 Nov 2011 02:45:50 +0000
Message-ID: <1321497950.2885.72.camel@deadeye>
References: <1321394453-21076-1-git-send-email-mcarlson@broadcom.com>
	 <1321490078.2709.86.camel@bwh-desktop>
	 <20111117011604.GA8683@mcarlson.broadcom.com>
	 <1321493382.2709.94.camel@bwh-desktop>
	 <20111117020613.GA18232@mcarlson.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:52699 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755449Ab1KQCp7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 21:45:59 -0500
In-Reply-To: <20111117020613.GA18232@mcarlson.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-11-16 at 18:06 -0800, Matt Carlson wrote:
> On Wed, Nov 16, 2011 at 05:29:42PM -0800, Ben Hutchings wrote:
> > On Wed, 2011-11-16 at 17:16 -0800, Matt Carlson wrote:
> > > On Wed, Nov 16, 2011 at 04:34:37PM -0800, Ben Hutchings wrote:
> > [...]
> > > > > +#define mii_lpa_to_ethtool_100bt(lpa)	mii_adv_to_ethtool_100=
bt(lpa)
> > > >=20
> > > > Shouldn't this additionally translate LPA_LPACK into ADVERTISED=
_Autoneg?
> > >=20
> > > You mean, like this?
> > >=20
> > > static inline u32 mii_lpa_to_ethtool_100bt(u32 lpa)
> > > {
> > > 	u32 result =3D 0;
> > >=20
> > > 	if (lpa & LPA_LPACK)
> > > 		result |=3D ADVERTISED_Autoneg;
> > >=20
> > > 	return result | mii_adv_to_ethtool_100bt(lpa);
> > > }
> > >=20
> > > Yes, that looks like a better implementation.
> >=20
> > Think so.
> >=20
> > And I think the mii_adv_to_ethtool_* functions should add
> > ADVERTISED_Autoneg unconditionally.  But I'm not entirely sure that=
's
> > right.
>=20
> The primary purpose of these functions is to translate the informatio=
n
> between two representations.  It seems wise to be careful not to add
> from it or take anything away from it.  It is certainly possible to
> have a valid AN advertisement register configuration, but not have
> autoneg enabled.  Keeping the ADVERTISED_Autoneg out could prevent
> misuse.  Do you agree?

I'm not sure what you mean about misuse.  If autoneg is not enabled the=
n
the register contents are not used and I don't think the
mii_adv_to_ethtool functions should be called at all.  But I'm not that
bothered either way.

> > > > Shouldn't there be mii_lpa_to_ethtool_1000X (or
> > > > mii_lpa_to_ethtool_lpa_x)?
> > >=20
> > > Yes.  You're right.  Should it just be a preprocessor definition =
that
> > > points to mii_adv_to_ethtool_1000X()?
> >=20
> > I think that would need to handle LPA_LPACK as well.
>=20
> I was wondering if that was present in 1000Base-X mode.  I didn't see=
 it
> in my passing glance at a spec.

IEEE 802.3-2005 =C2=A737.2.1.6 seems to define it similarly to the TP c=
ase.

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
