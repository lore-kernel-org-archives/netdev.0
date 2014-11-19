From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] ixgbe: Correctly disable vlan filter in promiscuous mode
Date: Wed, 19 Nov 2014 13:56:21 -0800
Message-ID: <1416434181.2281.0.camel@jtkirshe-mobl>
References: <1416338897-13007-1-git-send-email-vyasevic@redhat.com>
	 <87618083B2453E4A8714035B62D679925019F38A@FMSMSX105.amr.corp.intel.com>
	 <546CF258.9050205@gmail.com>
	 <87618083B2453E4A8714035B62D67992501A1011@FMSMSX105.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Ccs/RLSX+/KMucgDg5bY"
Cc: Vlad Yasevich <vyasevich@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Keller, Jacob E" <jacob.e.keller@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:24928 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932372AbaKSV4W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Nov 2014 16:56:22 -0500
In-Reply-To: <87618083B2453E4A8714035B62D67992501A1011@FMSMSX105.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Ccs/RLSX+/KMucgDg5bY
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-11-19 at 13:50 -0800, Tantilov, Emil S wrote:
> >-----Original Message-----
> >From: Vlad Yasevich [mailto:vyasevich@gmail.com]
> >Sent: Wednesday, November 19, 2014 11:41 AM
> >To: Tantilov, Emil S; netdev@vger.kernel.org
> >Cc: Kirsher, Jeffrey T; Keller, Jacob E; Skidmore, Donald C
> >Subject: Re: [PATCH] ixgbe: Correctly disable vlan filter in
> >promiscuous mode
> >
> >On 11/18/2014 03:24 PM, Tantilov, Emil S wrote:
> >>> -----Original Message-----
> >>> From: netdev-owner@vger.kernel.org [mailto:netdev-
> >>> owner@vger.kernel.org] On Behalf Of Vladislav Yasevich
> >>> Sent: Tuesday, November 18, 2014 11:28 AM
> >>> To: netdev@vger.kernel.org
> >>> Cc: Vladislav Yasevich; Kirsher, Jeffrey T; Keller, Jacob E
> >>> Subject: [PATCH] ixgbe: Correctly disable vlan filter in promiscuous =
mode
> >>>
> >>> IXGBE adapater seems to require that vlan filtering be enabled if VMD=
Q
> >>> or SRIOV are enabled.  When those functions are disabled,
> >>> vlan filtering may be disabled in promiscuous mode.
> >>>
> >>> Prior to commit a9b8943ee129e11045862d6d6e25c5b63c95403c
> >>>    ixgbe: remove vlan_filter_disable and enable functions
> >>>
> >>> the logic was correct.  However, after the commit the logic
> >>> got reversed and vlan filtered in now turned on when VMDQ/SRIOV
> >>> is disabled.
> >>>
> >>> This patch changes the condition to enable hw vlan filtered
> >>> when VMDQ or SRIOV is enabled.
> >>>
> >>> Fixes: a9b8943ee129e11045862d6d6e25c5b63c95403c (ixgbe:
> >>> remove
> >>> vlan_filter_disable and enable functions)
> >>> CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >>> CC: Jacob Keller <jacob.e.keller@intel.com>
> >>> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
> >>> ---
> >>> drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 4 ++--
> >>> 1 file changed, 2 insertions(+), 2 deletions(-)
> >>>
> >>> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> >>> b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> >>> index d2df4e3..3f81c7a 100644
> >>> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> >>> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> >>> @@ -3936,8 +3936,8 @@ void ixgbe_set_rx_mode(struct
> >>> net_device *netdev)
> >>> 		 * if SR-IOV and VMDQ are disabled - otherwise ensure
> >>> 		 * that hardware VLAN filters remain enabled.
> >>> 		 */
> >>> -		if (!(adapter->flags & (IXGBE_FLAG_VMDQ_ENABLED |
> >>> -					IXGBE_FLAG_SRIOV_ENABLED)))
> >>> +		if (adapter->flags & (IXGBE_FLAG_VMDQ_ENABLED |
> >>> +				      IXGBE_FLAG_SRIOV_ENABLED))
> >>> 			vlnctrl |=3D (IXGBE_VLNCTRL_VFE |
> >>> IXGBE_VLNCTRL_CFIEN);
> >>> 	} else {
> >>> 		if (netdev->flags & IFF_ALLMULTI) {
> >>
> >> The current logic is correct and it's like this on purpose
> >> as it should be obvious by the comment preceding this check.
> >
> >Actually the comment right now does not match what the code
> >is doing.
> >
> >The comment states:
> >                /* Only disable hardware filter vlans in promiscuous mod=
e
> >                 * if SR-IOV and VMDQ are disabled - otherwise ensure
> >                 * that hardware VLAN filters remain enabled.
> >                 */
> >
> >However, the code currently will _enable_ vlan filtering if VMDQ/SRIOV
> >is _disabled_ in promiscuous mode.
>=20
> Actually you're right. Sorry - I misread the patch initially.
> This is indeed a bug in the code.
>=20
> Acked-by: Emil Tantilov <emil.s.tantilov@intel.com>
>=20
> Jeff should pick it up.

Consider it done, I have added Vlad's patch to my queue.

--=-Ccs/RLSX+/KMucgDg5bY
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUbRIFAAoJEOVv75VaS+3OVDYP/0h5C2cWl3yx79OQqcHAl6Fb
ovCiCYDUeIvCTCbbahSlNaE8hkZ9f3Nv4J2lMQxV3nl/6QWF6kwk36iqWtVv0YQX
vzawnDGd0QzLkoNd0zcU1LkoZfkGgQHWkJyzTvHVwCrKpunHH635ibJCBKFfHi6+
NhuTVnwyHLoE44xFWVBQte2fGqRScsI8xcooV0R1bQfSnJfdO5aWteubbWwCbH4l
LWq7iHM4UC9D2OwKMFLDqj+YLpERoB0fk5gM1DjYJp07quXgXNxBSK8ibHsJwfbc
xI1QEP2lfcw5jdAgaIH4SRMubBrEuBAsQtfTBgG4NWH8joyqTkaiWRPDPRuTXdb3
bU1pFbDcigYwMj0wPsOP5FS1BeO7El+4VfSQuZb8GAF5XGlyaCx/rbIrcua6fZD2
APa3yk6++f+nc1Y7u+8pagOTP6GNzVSxps1yFPdBs5/48EbVaXQl1d+vDidMcIP0
8y4nA8OwiVMq2k7Lj2CrDZa8R6agT5fb4Cdk258bLqBo5qm3xU9ehgfs/Y9oEZt9
Y4s9Xud4RHcwM0F3v8salVojnSaqqoNisVI1clNHMQZxIf+j372PUb7ZKsnMZjjl
+tUYBSIGkw98JusNmd06yb9iVz7l1LdJ1w3pARHjK38B7/IVveQvH4+IZmdta9eo
7WHMJeRAcWecWOeYXyjQ
=SNgI
-----END PGP SIGNATURE-----

--=-Ccs/RLSX+/KMucgDg5bY--
