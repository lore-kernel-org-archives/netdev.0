From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next 1/4 (V3)] net: ethtool: add the EEE support
Date: Thu, 26 Apr 2012 18:17:40 +0100
Message-ID: <1335460660.2712.15.camel@bwh-desktop.uk.solarflarecom.com>
References: <1333704559-11251-1-git-send-email-peppe.cavallaro@st.com>
	   <1333704559-11251-2-git-send-email-peppe.cavallaro@st.com>
	  <1334269598.2497.50.camel@bwh-desktop.uk.solarflarecom.com>
	  <4F8BB103.7020107@st.com> <4F900C08.5000906@st.com>
	 <1334849401.2426.73.camel@bwh-desktop.uk.solarflarecom.com>
	 <4F98FDCC.3040807@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <rayagond@vayavyalabs.com>,
	<davem@davemloft.net>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:53167 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753033Ab2DZRRu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 13:17:50 -0400
In-Reply-To: <4F98FDCC.3040807@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-04-26 at 09:48 +0200, Giuseppe CAVALLARO wrote:
> Hello Ben
>=20
> On 4/19/2012 5:30 PM, Ben Hutchings wrote:
> [snip]
> >> I'm changing the code for getting/setting the EEE capability and t=
rying
> >> to follow your suggestions.
> >>
> >> The "get" will show the following things; this is a bit different =
of the
> >> points "a" "b" and "c" we had discussed. Maybe, this could also be=
 a
> >> more complete (*) .
> >> The ethtool (see output below as example) could report the phy
> >> (supported/advertised/lp_advertised) and mac eee capabilities sepa=
rately.
> >=20
> > Sounds reasonable.
> >=20
> >> The "set" will be useful for some eth devices (like the stmmac) th=
at can
> >> stop/enable internally the eee capability (at mac level).
> >=20
> > I don't know much about EEE, but shouldn't the driver take care of
> > configuring the MAC for this whenever the PHY is set to advertise E=
EE
> > capability?
>=20
> Yes indeed this can be done at driver level. So could I definitely
> remove it from ethtool? What do you suggest?
>=20
> In case of the stmmac I could add a specific driver option via sys to
> enable/disable the eee and set timer.

Generally, ethtool doesn't distinguish MAC and PHY settings because the=
y
have to be configured consistently for the device to do anything useful=
=2E
If there is some good use for enabling EEE in the MAC and not the PHY,
or vice versa, then this should be exposed in the ethtool interface.
But if not then I don't believe it needs to be in either an ethtool or =
a
driver-specific interface. =20

> >> [snip]
> >>
> >> 	Current message level: 0x0000003f (63)
> >> 			       drv probe link timer ifdown ifup
> >> 	Link detected: yes
> >> 	Energy-Efficient Ethernet:           -------------------------
> >> 		MAC supports: yes            |-> related to MAC side  |
> >> 		phy supports modes: ...      |-> from MMD 3.20        |
> >> 		phy advertising modes: ...   |-> from MMD 7.60        |
> >> 		LP advertising modes: ...    |-> from MMD 7.61        |
> >> 					     --------------------------
> >>                                                     (*)
> >> PS. The "..." above means that we can actually dump: 100BASE-TX EE=
E etc
> >> for each advertising modes and also for phy support (reg 3.20).
> >=20
> > Yes, that's the sort of information I would expect to see (but try =
to be
> > consistent with the wording used for AN).:
>=20
> e.g. SUPPORTED_100baseT_EEE ... ADVERTISED_<...>

I meant the wording used in the ethtool output: 'supported',
'advertised', 'link partner advertised' rather than 'phy supports',
'phy advertising', 'LP advertising'.

> > The EEE advertising mask presumably should be changeable similarly =
to
> > the AN advertising mask ('ethtool -s <devname> eeeadv <mask>').  Bu=
t I
> > don't know how the two advertising masks interact.  Is one supposed=
 to
> > be a subset of the other?  Currently ethtool automatically changes =
the
> > AN advertising mask in response to a speed/duplex change; should it=
 also
> > try to change the EEE advertising mask?
>=20
> I've just verified the IEEE (Table 45=E2=80=93150a=E2=80=94EEE advert=
isement register
> (Register 7.60) bit definitions) and sorry for my delay in reply but =
I
> was in trouble because looking at the registers for the phy (I am usi=
ng)
> the reg 7.60 was in RO and I couldn't understand how to set the mask.
> I confirm that the Adv reg from the std is R/W and the mask as you
> suggest could be set according to the speed.
> The EEE should work on duplex mode only.
>=20
> I wonder so if if the final patch I should have no new option for the
> ethtool command and EEE info are directly passed from the kernel like
> speed and duplex when call get_settings.

Are you suggesting to define EEE mode flags in the existing supported,
advertising and lp_advertising masks?

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
