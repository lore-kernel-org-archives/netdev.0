From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [RFC PATCH net-next 1/5] ixgbe: Add a RETA query command to
 VF-PF channel API
Date: Tue, 30 Dec 2014 11:30:55 -0800
Message-ID: <1419967855.31582.24.camel@jtkirshe-mobl>
References: <1419957035-1078-1-git-send-email-vladz@cloudius-systems.com>
		<1419957035-1078-2-git-send-email-vladz@cloudius-systems.com>
	 <CAL3LdT4mfE72fmA3b3iG=-b9iP9MXHfAJMBwqFzfYyC1pebc8A@mail.gmail.com>
	 <54A2FCE1.3000000@cloudius-systems.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-XAHY9w3XLrbE210chnqG"
Cc: netdev <netdev@vger.kernel.org>, gleb@cloudius-systems.com,
	avi@cloudius-systems.com
To: Vlad Zolotarov <vladz@cloudius-systems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:47186 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751362AbaL3Ta5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Dec 2014 14:30:57 -0500
In-Reply-To: <54A2FCE1.3000000@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-XAHY9w3XLrbE210chnqG
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-12-30 at 21:28 +0200, Vlad Zolotarov wrote:
> On 12/30/14 21:21, Jeff Kirsher wrote:
> > On Tue, Dec 30, 2014 at 8:30 AM, Vlad Zolotarov
> > <vladz@cloudius-systems.com> wrote:
> >> 82599 VFs and PF share the same RSS redirection table (RETA). Therefor=
e we
> >> just return it for all VFs.
> >>
> >> RETA table is an array of 32 registers and the maximum number of regis=
ters
> >> that may be delivered in a single VF-PF channel command is 15. Therefo=
re
> >> we will deliver the whole table in 3 steps: 12, 12 and 8 registers in =
each
> >> step correspondingly. Thus this patch does the following:
> >>
> >>    - Adds a new API version (to specify a new commands set).
> >>    - Adds the IXGBE_VF_GET_RETA_[0,1,2] commands to the VF-PF commands=
 set.
> >>
> >> Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
> >> ---
> >>   drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h   |  6 +++++
> >>   drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 35 ++++++++++++++++=
++++++++++
> >>   2 files changed, 41 insertions(+)
> >>
> >> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h b/drivers/ne=
t/ethernet/intel/ixgbe/ixgbe_mbx.h
> >> index a5cb755..c1123d9 100644
> >> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h
> >> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h
> >> @@ -73,6 +73,7 @@ enum ixgbe_pfvf_api_rev {
> >>          ixgbe_mbox_api_10,      /* API version 1.0, linux/freebsd VF =
driver */
> >>          ixgbe_mbox_api_20,      /* API version 2.0, solaris Phase1 VF=
 driver */
> >>          ixgbe_mbox_api_11,      /* API version 1.1, linux/freebsd VF =
driver */
> >> +       ixgbe_mbox_api_12,      /* API version 1.2, linux/freebsd VF d=
river */
> >>          /* This value should always be last */
> >>          ixgbe_mbox_api_unknown, /* indicates that API version is not =
known */
> >>   };
> >> @@ -91,6 +92,11 @@ enum ixgbe_pfvf_api_rev {
> >>   /* mailbox API, version 1.1 VF requests */
> >>   #define IXGBE_VF_GET_QUEUES    0x09 /* get queue configuration */
> >>
> >> +/* mailbox API, version 1.2 VF requests */
> >> +#define IXGBE_VF_GET_RETA_0    0x0a /* get RETA[0..11]  */
> >> +#define IXGBE_VF_GET_RETA_1    0x0b /* get RETA[12..23] */
> >> +#define IXGBE_VF_GET_RETA_2    0x0c /* get RETA[24..31] */
> >> +
> >>   /* GET_QUEUES return data indices within the mailbox */
> >>   #define IXGBE_VF_TX_QUEUES     1       /* number of Tx queues suppor=
ted */
> >>   #define IXGBE_VF_RX_QUEUES     2       /* number of Rx queues suppor=
ted */
> >> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/=
net/ethernet/intel/ixgbe/ixgbe_sriov.c
> >> index c76ba90..84db1a5 100644
> >> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
> >> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
> >> @@ -427,6 +427,7 @@ static s32 ixgbe_set_vf_lpe(struct ixgbe_adapter *=
adapter, u32 *msgbuf, u32 vf)
> >>   #endif /* CONFIG_FCOE */
> >>                  switch (adapter->vfinfo[vf].vf_api) {
> >>                  case ixgbe_mbox_api_11:
> >> +               case ixgbe_mbox_api_12:
> >>                          /*
> >>                           * Version 1.1 supports jumbo frames on VFs i=
f PF has
> >>                           * jumbo frames enabled which means legacy VF=
s are
> >> @@ -894,6 +895,7 @@ static int ixgbe_negotiate_vf_api(struct ixgbe_ada=
pter *adapter,
> >>          switch (api) {
> >>          case ixgbe_mbox_api_10:
> >>          case ixgbe_mbox_api_11:
> >> +       case ixgbe_mbox_api_12:
> >>                  adapter->vfinfo[vf].vf_api =3D api;
> >>                  return 0;
> >>          default:
> >> @@ -917,6 +919,7 @@ static int ixgbe_get_vf_queues(struct ixgbe_adapte=
r *adapter,
> >>          switch (adapter->vfinfo[vf].vf_api) {
> >>          case ixgbe_mbox_api_20:
> >>          case ixgbe_mbox_api_11:
> >> +       case ixgbe_mbox_api_12:
> >>                  break;
> >>          default:
> >>                  return -1;
> >> @@ -944,6 +947,29 @@ static int ixgbe_get_vf_queues(struct ixgbe_adapt=
er *adapter,
> >>          return 0;
> >>   }
> >>
> >> +static int ixgbe_get_vf_reta(struct ixgbe_adapter *adapter,
> >> +                            u32 *msgbuf, u32 vf, int reta_offset_dw,
> >> +                            size_t dwords)
> >> +{
> >> +       struct ixgbe_hw *hw =3D &adapter->hw;
> >> +       int i;
> >> +       u32 *reta =3D &msgbuf[1];
> >> +
> >> +       /* verify the PF is supporting the correct API */
> >> +       switch (adapter->vfinfo[vf].vf_api) {
> >> +       case ixgbe_mbox_api_12:
> >> +               break;
> >> +       default:
> >> +               return -EPERM;
> >> +       }
> > A switch statement is overkill for a single case.  It would be far
> > simpler to just have
> >
> > if (adapter->vfinfo[vf].vf_api !=3D ixgbe_mbox_api_12)
> >          return -EPERM;
> >
> > Later on, if there are multiple API's or future API's that also
> > support this, then we could move to a case statement.
>=20
> I thought about it to but decided to make it future-proof. NP. Will make=
=20
> it an "if" in a non-RFC series. Thanks.
>=20

Thanks fine, and if you CC me on the non-RFC series, I will pick them up
(and make sure that Greg Rose has a chance to review them).

--=-XAHY9w3XLrbE210chnqG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUov1vAAoJEOVv75VaS+3OQasP/1cyd7XSxhiOfw5MowjTXflS
PbWm6by8R7BlG7cLCsHSloORm2pD5Q+qmBeIzWdWtoP1gbNaU5KZi+8CteVladys
gTscJ7KRsK/n1gv7rGCo6aqNO64Lrsi8bQVoBbdvBOKArjrC2sVvoWLSFdwT82TD
2A/zkbAXnrYr8HHlh+C3knm4FqkoXBnpG6WajBboN8GWKhRgsdQfuArq5Iqa8zZV
s9nEQWYbr1c2O4zBVrcq6bWFEHPs5CkgDZ1GHZ6vYMLOSxC2Ofw+XUQHL69Nv2el
RtPoZx66peef2xxQYWEGdXzYXaeKhnOP35PnWNVfvxxDCc4SEKbqNu+JB2H7mw1x
SZqJpv/Jmh3ZOsWIaTdkx2MnCJGbhiwdFkf4tRO24emE2JzXefS3R1VGZaFe+DLV
3Z4EfT4oxR+lJqT2eXkuS3cwWPrJ35Ho8FNfzkL410oSL2+K7GaWSMkCaTQrtlA2
NGQ4qnWfeFSdB+Lrw8iXVw06x+9NAa1xPJiQBrBLi8UVafFZrM7MsrX36hJsWWHB
/MdiHR/sk9Y3R9SGPTZZGLcYXJPX0vn1sWGCB130jqFKAL8hJ2/szAv+OFCV3Ce/
Kvtq6lRk8YGZNzHi/XIqq9rv9QqngiA/O9dAg+fqZwaoe2K3uIRex64fdYNTPQo3
dC9cQH+/P+lvUB6ppSPr
=cNCl
-----END PGP SIGNATURE-----

--=-XAHY9w3XLrbE210chnqG--
