From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH v2] net: stmmac: bug fix to synchronize stmmac_open and
 stmmac_dvr_probe
Date: Tue, 27 Dec 2016 11:48:26 +0100
Message-ID: <20161227104826.GB15452@amd>
References: <1482849756-21817-1-git-send-email-hock.leong.kweh@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="V0207lvV8h4k8FAm"
Cc: "David S. Miller" <davem@davemloft.net>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        seraphin.bonnaffe@st.com, f.fainelli@gmail.com,
        Alexandre TORGUE <alexandre.torgue@gmail.com>,
        Joachim Eastwood <manabian@gmail.com>,
        Niklas Cassel <niklas.cassel@axis.com>,
        Johan Hovold <johan@kernel.org>,
        Ong Boon Leong <boon.leong.ong@intel.com>,
        weifeng.voon@intel.com, lars.persson@axis.com,
        Netdev list <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:41753 "EHLO
        atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751667AbcL0Ks2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2016 05:48:28 -0500
Content-Disposition: inline
In-Reply-To: <1482849756-21817-1-git-send-email-hock.leong.kweh@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--V0207lvV8h4k8FAm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue 2016-12-27 22:42:36, Kweh, Hock Leong wrote:
> From: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>
>=20
> If kernel module stmmac driver being loaded after OS booted, there is a
> race condition between stmmac_open() and stmmac_mdio_register(), which is
> invoked inside stmmac_dvr_probe(), and the error is showed in dmesg log as
> PHY not found and stmmac_open() failed:
> [  473.919358] stmmaceth 0000:01:00.0 (unnamed net_device) (uninitialized=
):
>                 stmmac_dvr_probe: warning: cannot get CSR clock
> [  473.919382] stmmaceth 0000:01:00.0: no reset control found
> [  473.919412] stmmac - user ID: 0x10, Synopsys ID: 0x42
> [  473.919429] stmmaceth 0000:01:00.0: DMA HW capability register support=
ed
> [  473.919436] stmmaceth 0000:01:00.0: RX Checksum Offload Engine support=
ed
> [  473.919443] stmmaceth 0000:01:00.0: TX Checksum insertion supported
> [  473.919451] stmmaceth 0000:01:00.0 (unnamed net_device) (uninitialized=
):
>                 Enable RX Mitigation via HW Watchdog Timer
> [  473.921395] libphy: PHY stmmac-1:00 not found
> [  473.921417] stmmaceth 0000:01:00.0 eth0: Could not attach to PHY
> [  473.921427] stmmaceth 0000:01:00.0 eth0: stmmac_open: Cannot attach to
>                 PHY (error: -19)
> [  473.959710] libphy: stmmac: probed
> [  473.959724] stmmaceth 0000:01:00.0 eth0: PHY ID 01410cc2 at 0 IRQ POLL
>                 (stmmac-1:00) active
> [  473.959728] stmmaceth 0000:01:00.0 eth0: PHY ID 01410cc2 at 1 IRQ POLL
>                 (stmmac-1:01)
> [  473.959731] stmmaceth 0000:01:00.0 eth0: PHY ID 01410cc2 at 2 IRQ POLL
>                 (stmmac-1:02)
> [  473.959734] stmmaceth 0000:01:00.0 eth0: PHY ID 01410cc2 at 3 IRQ POLL
>                 (stmmac-1:03)
>=20
> The resolution moved the register_netdev() function call to the end of
> stmmac_dvr_probe() after stmmac_mdio_register().
>=20
> Suggested-by: Florian Fainelli <f.fainelli@gmail.com>
> Signed-off-by: Kweh, Hock Leong <hock.leong.kweh@intel.com>

Acked-by: Pavel Machek <pavel@ucw.cz>

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--V0207lvV8h4k8FAm
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlhiRvoACgkQMOfwapXb+vJrhACfYa4JPvHghBSoUUX6h7DmC0st
eRQAn3qK1Wg0yv3rQZwQKMpREyRSHZGB
=fAN2
-----END PGP SIGNATURE-----

--V0207lvV8h4k8FAm--
