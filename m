From: Mark Brown <broonie@kernel.org>
Subject: Re: [PATCH v2 1/4] devicetree: bindings: Properly document micrel
 ks8851 SPI chips
Date: Sat, 24 May 2014 13:48:58 +0100
Message-ID: <20140524124858.GR22111@sirena.org.uk>
References: <1400875040-13269-1-git-send-email-sboyd@codeaurora.org>
 <1400875040-13269-2-git-send-email-sboyd@codeaurora.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="0fu5tullpC+tJp0Y"
Cc: "David S . Miller" <davem@davemloft.net>,
	Nishanth Menon <nm@ti.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	linux-arm-msm@vger.kernel.org, Kumar Gala <galak@codeaurora.org>,
	linux-kernel@vger.kernel.org, devicetree@vger.kernel.org,
	Rob Herring <robh+dt@kernel.org>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Stephen Boyd <sboyd@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mezzanine.sirena.org.uk ([106.187.55.193]:41140 "EHLO
	mezzanine.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750751AbaEXMu1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 May 2014 08:50:27 -0400
Content-Disposition: inline
In-Reply-To: <1400875040-13269-2-git-send-email-sboyd@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--0fu5tullpC+tJp0Y
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, May 23, 2014 at 12:57:17PM -0700, Stephen Boyd wrote:

>  Optional properties:
> -- vdd-supply:	supply for Ethernet mac
> +- vdd-supply: analog 3.3V supply for Ethernet mac
> +- vdd-io-supply: digital 1.8V IO supply for Ethernet mac

So, according to the datasheet I managed to find this device has a
supply VDD_IO (so normally written vdd-io-supply here), some other
supplies which are tied to VDD_IO (so can probably be omitted) and a
supply VDD_A3.3 none of which are optional.  There is an internal
regulator which can be used to drop a higher voltage VDD_IO down for
some of the supplies tied to it but that's essentially a noop from
software as far as I can tell.  None of these supplies are obviously
optional, though I've not read the datasheet in detail so I may have
missed something here.

That said it looks like this is intended to be a supply for an external
PHY rather than the device itself, but even so my original question
about it being able to operate without power still applies.  Looking at
the code it's certainly not doing any of the handling of a missing
supply that I would associate with using _optional().

--0fu5tullpC+tJp0Y
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBAgAGBQJTgJU3AAoJELSic+t+oim9+tAP/ifbdcUD5cDbQ44onjRvB2p3
tk9sxYsW87abDW64X9KhzqTm6pUEG9ZBUC8qKN9T9l11RVU9I5PxzV9iEqovIJUV
nnU9OwnoMjIie5Juwkg3d1gCIGBCB5lCEmPoUWUgop4zZFAxl49e1mCZPUgCofGQ
qXA6FDoIVX06mWmVOYEZ1tfcTjcp0oZdaSl1sUlc27GJNMV0KCHulA+9PwakxpnS
aYGVYL6CfO9HLQbkaBn+KvDMO0epfVg0GQVnRYiQ8Fh7ksYIcnz/OqVoKnbWTaMT
gpcad3H4CmQk/sAUzBU7DPs2fgCWbTyERk864KtPt59rmFTlb9zq5JPxDy0Q+Gqi
4IUlWDGzZb1ZKrH3nZIR/7bwe5QPZU3hs8JEblkmGNqfpPysP6a+GYF7xhxuUq6y
IDlqkvEzvmYdiwAPe5UPo2hJ5Ie/UkKIE2MBiHoc09zXm63yj/wIFUb6JDf4In2X
/QlQYMga49lceFtsuFoIoG/BYYz1CjUjwBFczwVo0aHMJRjNWRhhAB9UD8oR6D9k
F67KhxClqMKl/MEf/pXVz5O+/CdMeE+m/0mhmHsRPmuIseswXPhD3G62BBG5DYID
Ew2FjouY0JWsYq3tqKc0Oafn/pmkaDVueBi3VrWFLMOqtFLAuKWetC6Z5e1q7tbl
t6egA/9IHlhl6LUQT1aq
=TPgS
-----END PGP SIGNATURE-----

--0fu5tullpC+tJp0Y--
