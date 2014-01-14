From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next v3 2/2] stmmac: Fix kernel crashes for jumbo
 frames
Date: Tue, 14 Jan 2014 23:20:46 +0000
Message-ID: <1389741646.2025.218.camel@bwh-desktop.uk.level5networks.com>
References: <1389719859-29071-1-git-send-email-vbridgers2013@gmail.com>
	 <1389719859-29071-3-git-send-email-vbridgers2013@gmail.com>
	 <1389729216.2025.197.camel@bwh-desktop.uk.level5networks.com>
	 <CAOwfj2Ne1oRU1z6BaH4g2_EJJFtJOWbgs2oMzSq5nNpz9G6LsA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <devicetree@vger.kernel.org>, <netdev@vger.kernel.org>,
	Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
	<robh+dt@kernel.org>, <pawel.moll@arm.com>, <mark.rutland@arm.com>,
	<ijc+devicetree@hellion.org.uk>, Kumar Gala <galak@codeaurora.org>,
	Dinh Nguyen <dinguyen@altera.com>,
	"Rayagond Kokatanur" <rayagond@vayavyalabs.com>
To: Vince Bridgers <vbridgers2013@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:49132 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751904AbaANXUv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 18:20:51 -0500
In-Reply-To: <CAOwfj2Ne1oRU1z6BaH4g2_EJJFtJOWbgs2oMzSq5nNpz9G6LsA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-01-14 at 14:44 -0600, Vince Bridgers wrote:
> On Tue, Jan 14, 2014 at 1:53 PM, Ben Hutchings
[...]
> >>
> >>       /*
> >>        * Currently only the properties needed on SPEAr600
> >> @@ -60,6 +64,7 @@ static int stmmac_probe_config_dt(struct platfor=
m_device *pdev,
> >>       if (of_device_is_compatible(np, "st,spear600-gmac") ||
> >>               of_device_is_compatible(np, "snps,dwmac-3.70a") ||
> >>               of_device_is_compatible(np, "snps,dwmac")) {
> >> +             of_property_read_u32(np, "max-frame-size", &plat->ma=
xmtu);
> > [...]
> >
> > Is it the maximum frame size, including Ethernet header?  (And then=
, is
> > the CRC or any VLAN header included in the frame size?)
> > Or is it the MTU, excluding all of those?
> > You really need to be very clear about what this number represents.
>=20
> max-frame-size as read from the device tree is defined in the ePAPR
> v1.1 specification. I originally used a name of "max-mtu", but was
> asked to change that since this attribute was already defined in the
> ePAPR v1.1 specification.
[...]

Oh dear, this specification is just as confused as I am.  The example
value in =C2=A76.3.1.4 is 1518, implying that it is really the frame si=
ze,
including the Ethernet header, any VLAN tag, and maybe the CRC.  Howeve=
r
the full example in Appendix B1 has 0x5dc (=3D=3D 1500) implying that i=
t is
the MTU.

I suppose you should follow whatever interpretation is already used by
other drivers. :-/

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
