From: Corinna Vinschen <vinschen@redhat.com>
Subject: Re: [Intel-wired-lan] [PATCH] igb: Allow to remove administratively
 set MAC on VFs
Date: Wed, 5 Apr 2017 11:13:27 +0200
Message-ID: <20170405091327.GA4988@calimero.vinschen.de>
References: <20170404151055.21447-1-vinschen@redhat.com>
 <B1C1DF2ACD01FD4881736AA51731BAB2B1E1A2@ORSMSX107.amr.corp.intel.com>
 <CAKgT0UdYjzk4worxwfpuCEY7c6+n8x1Uqz5_=Az_y1zeK6gCSg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="u3/rZRmxL6MmkK24"
Cc: "Duyck, Alexander H" <alexander.h.duyck@intel.com>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41266 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933027AbdDEJNe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 5 Apr 2017 05:13:34 -0400
Content-Disposition: inline
In-Reply-To: <CAKgT0UdYjzk4worxwfpuCEY7c6+n8x1Uqz5_=Az_y1zeK6gCSg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--u3/rZRmxL6MmkK24
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Alex,

On Apr  4 10:33, Alexander Duyck wrote:
> On Tue, Apr 4, 2017 at 10:16 AM, Duyck, Alexander H
> <alexander.h.duyck@intel.com> wrote:
> >> -----Original Message-----
> >> From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org=
] On
> >> Behalf Of Corinna Vinschen
> >> Sent: Tuesday, April 4, 2017 8:11 AM
> >> To: intel-wired-lan@lists.osuosl.org
> >> Cc: netdev@vger.kernel.org
> >> Subject: [Intel-wired-lan] [PATCH] igb: Allow to remove administrative=
ly set MAC
> >> on VFs
> >> [...]
>=20
> So I just realized there is one other minor issue I just found. In
> igb_rar_set_qsel you should probably add a check for
> "is_valid_ether_addr(addr)" before you set the E1000_RAH_AV bit. For
> the zeroed MAC address it should be cleared so that we aren't
> filtering on a MAC address of all 0's for the VF.
>=20
> - Alex

I see your point, but I'm a bit reluctant to do that because
igb_vf_configure() calls igb_set_vf_mac() with addr set to the
zeroed MAC explicitely:


  eth_zero_addr(mac_addr);
  igb_set_vf_mac(adapter, vf, mac_addr);

So in this case the zero MAC is already treated as valid address
and the E1000_RAH_AV bit is set.  Is that just a bug?


Corinna

--u3/rZRmxL6MmkK24
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJY5LU3AAoJEPU2Bp2uRE+gQzgQAIrj0in5reHUJ+F3+fmvnvps
84woWChGQvHDVaSYjyBOjiyUG5nvnCCp7AsJIiFiH9rnPN5MjhA3wdyQ779QLqNL
wGAZyLRdpsVrOsd6s1YDsjEDvKt1XyHrduscbvrPybs1dVeLr8dxtpBvECFJOlZ3
015Vd7h6GP5wJ9gif6g+k5oiKUMvAeN1synF5tfcKyF+1uo4w0aT48j0IOrtcc+d
erKHowfKOQl+D2iCyaZd0LLrjd1RlcTh9kI8LNb9hTdERNbsPb4ktX2eAf+MZOzk
sELYXxbodc0u9bAAuVJC6VeR6ql2Jb2vm2m5Se82wJ+zMn1AYaJSOnzb3Y5gkmm1
cUDd3T6T7HYiW7XsJqqj6gvaEvELSlEj5wGdKCxoB/22gNzYjlDco460EFOl/nr9
CSo5XdVUSM0H93KLiw/sNTKOk4abgEE8J6PmmAJFmAwLtt54SPF5w92DxikQwvsF
CYSvzCOYyZzGVg4CcxQWbmm22zHVxr13H4DEUxsjXMAVLszyoQSXK1xh5wg8oIpK
KMQYjAVxm7+bWS2z+46XuealtXKYYg6ZDOH+bWumsvU6Sax5r7quYpMspbEQzqj1
TqYmCMscZwvXXP/nXcg1uk6FoOcQoj+1uJYM/YEeBMrQKgL/+a9vRbDkujVbs5MT
l6/dduRPlwkwFEna9e6H
=hqrM
-----END PGP SIGNATURE-----

--u3/rZRmxL6MmkK24--
