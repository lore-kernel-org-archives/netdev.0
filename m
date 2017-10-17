From: Henrik Austad <henrik@austad.us>
Subject: Re: [next-queue PATCH v9 0/6] TSN: Add qdisc based config interface
 for CBS
Date: Tue, 17 Oct 2017 13:35:50 +0200
Message-ID: <20171017113550.GA17834@sisyphus.home.austad.us>
References: <20171017010128.22141-1-vinicius.gomes@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="sm4nu43k4a2Rpi4c"
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
        jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        andre.guedes@intel.com, ivan.briano@intel.com,
        jesus.sanchez-palencia@intel.com, boon.leong.ong@intel.com,
        richardcochran@gmail.com, levipearson@gmail.com,
        rodney.cummings@ni.com
To: Vinicius Costa Gomes <vinicius.gomes@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f54.google.com ([209.85.215.54]:52080 "EHLO
        mail-lf0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933585AbdJQLfo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 07:35:44 -0400
Received: by mail-lf0-f54.google.com with SMTP id r129so1610017lff.8
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 04:35:44 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20171017010128.22141-1-vinicius.gomes@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--sm4nu43k4a2Rpi4c
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Oct 16, 2017 at 06:01:22PM -0700, Vinicius Costa Gomes wrote:
> Hi,

Vinicius; this looks really good to me, testing shows no errors and=20
behavior is as expected. I see some differences in received bw for=20
offload=3D1 and 0 though

Just using tsn_talker and tsn_listener:
tc qdisc add dev eth2 parent 8001:1 cbs idleslope 20000 sendslope -980000 \
hicredit 30 locredit -1470 offload 1

with offload=3D1 (20Mbps BW)
Receiving data rate: 19420 kbps
Receiving data rate: 19410 kbps

Similarly, but with offload=3D0 (SW, 20Mbps BW)
Receiving data rate: 19980 kbps
Receiving data rate: 20170 kbps

So slightly higer variance in rate when doing SW, which is as expected.

I plan to run this through some more tests tomorrow and measure variance on=
 the=20
receiver etc, I'll keep you posted on my findings.

Feel free to add a tested-by though

Tested-by: Henrik Austad <henrik@austad.us>

and a Vehemently-supported-by: Henrik .. :)

-Henrik

--sm4nu43k4a2Rpi4c
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlnl6xYACgkQ6k5VT6v45ll84wCdEJ1nikRrr+s0fkhUc+CukWvn
nKEAnjhrFJl9H+l6/kqv1ta4ZaKuX+uC
=PI0l
-----END PGP SIGNATURE-----

--sm4nu43k4a2Rpi4c--
