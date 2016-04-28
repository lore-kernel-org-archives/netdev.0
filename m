From: Josh Cartwright <joshc@ni.com>
Subject: Re: [PATCH] net: macb: do not scan PHYs manually
Date: Thu, 28 Apr 2016 10:07:05 -0500
Message-ID: <20160428150705.GA30217@jcartwri.amer.corp.natinst.com>
References: <1461853187-31715-1-git-send-email-nathan.sullivan@ni.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="2oS5YaxWCcQjTEyO"
Cc: nicolas.ferre@atmel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Nathan Sullivan <nathan.sullivan@ni.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461853187-31715-1-git-send-email-nathan.sullivan@ni.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--2oS5YaxWCcQjTEyO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Apr 28, 2016 at 09:19:47AM -0500, Nathan Sullivan wrote:
> Since of_mdiobus_register and mdiobus_register will scan automatically,

This is only partially true.  of_mdiobus_register() only scans for PHYs
with device tree presence (starting with nodes which specify an address,
then continuing for nodes without an address specifier).

So, this patch will regress any platform currently relying on a PHY
being found/probed even though it has no representation as a device tree
node.  I don't have enough history with this driver to make a judgement
as to whether or not there are any users of this functionality.

> do not manually scan for PHY devices in the macb ethernet driver. Doing
> so will result in many nonexistent PHYs on the MDIO bus if the MDIO
> lines are floating or grounded, such as when they are not used.

Just a restatement/elaboration of the problem in an attempt to provide
more context:

The assumption being made is that the phy associated with a given macb
instance exists on that instance's controlled mdio bus.  This assumption
doesn't hold true on some dual-ethernet Zynq 7000-series based designs
where both phys exist on the same MDIO bus (for pinning reasons, or
whatever).

             MDIO
    macb0 ----+----- phy0, addrX
              |
              +----- phy1, addrY

    macb1 ----- {MDIO lines NC, not pinmuxed}

(In this case, the phy associated with macb1 is phy1, which exists on
the MDIO bus controlled by the macb0 instance).

HTH,

  Josh

--2oS5YaxWCcQjTEyO
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJXIicVAAoJEKp7ZBKwQFAro4MIAIcyS936SG1oqmG5wOxrbjFs
SOG5n1b+nFpCT5Kp/QYUOz2T+K5PwOOZu+lP9LoZdaiEF/ZcxNfIOw56j8fbZfJC
Twswy/pZJN2euhSuaqHWVH6GxVjj6OFN62tfs028BTSbNKSjuKobnvVr3sTtI8BN
BxebfC/03zNv//T8CX9czIyZZHnE4Osr8XRX+FZmGYa4EvcfpAX3f6SWn1OrG6GA
gPr6w86XAW2VmvtOqUf6PFnFfh+sTJnTIa6N7G4RCTogZyC/qSHRRlr0yoAERmj6
avi6AbU04T1wYB11iUCjxyBFNDMsrto23Ut8pTr9wNDAphHrdbBQgBBnTJsN6Bs=
=DQzV
-----END PGP SIGNATURE-----

--2oS5YaxWCcQjTEyO--
