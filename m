From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] ixgbe: Use is_valid_ether_addr
Date: Mon, 03 Dec 2012 13:04:27 -0800
Message-ID: <1354568667.2030.9.camel@jtkirshe-mobl>
References: <1350750159.10791.3.camel@joe-AO722>
	 <1354556831.3524.0.camel@joe-AO722>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-GzXn3XQPzvz+EsF8hAPy"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:45065 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752641Ab2LCVE3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Dec 2012 16:04:29 -0500
In-Reply-To: <1354556831.3524.0.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-GzXn3XQPzvz+EsF8hAPy
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2012-12-03 at 09:47 -0800, Joe Perches wrote:
> On Sat, 2012-10-20 at 09:22 -0700, Joe Perches wrote:
> > Use the normal kernel test instead of a module specific one.
>=20
> ping?

Your timely is perfect, I just cleared out all the ixgbe patches in my
queue that were before yours, and your patch (along with several others)
are finishing up validation.  So I should be pushing your patch along
with other ixgbe patches this week sometime, as long as Dave's net-next
remains open long enough for me to push. :-)

>=20
> > Signed-off-by: Joe Perches <joe@perches.com>
> > ---
> > found when doing that larger style conversion,
> > might as well submit it.
> >=20
> >  drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c  |  2 +-
> >  drivers/net/ethernet/intel/ixgbe/ixgbe_common.c | 27 +----------------=
--------
> >  drivers/net/ethernet/intel/ixgbe/ixgbe_common.h |  1 -
> >  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   |  2 +-
> >  drivers/net/ethernet/intel/ixgbe/ixgbe_type.h   |  9 ---------
> >  drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c   |  2 +-
> >  6 files changed, 4 insertions(+), 39 deletions(-)
> >=20
> > diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c b/drivers/n=
et/ethernet/intel/ixgbe/ixgbe_82599.c
> > index 1077cb2..89fe00d 100644
> > --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
> > +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
> > @@ -1022,7 +1022,7 @@ mac_reset_top:
> >  	hw->mac.ops.get_san_mac_addr(hw, hw->mac.san_addr);
> > =20
> >  	/* Add the SAN MAC address to the RAR only if it's a valid address */
> > -	if (ixgbe_validate_mac_addr(hw->mac.san_addr) =3D=3D 0) {
> > +	if (is_valid_ether_addr(hw->mac.san_addr)) {
> >  		hw->mac.ops.set_rar(hw, hw->mac.num_rar_entries - 1,
> >  		                    hw->mac.san_addr, 0, IXGBE_RAH_AV);
> > =20
> > diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/=
net/ethernet/intel/ixgbe/ixgbe_common.c
> > index dbf37e4..2d8f76d 100644
> > --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
> > +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
> > @@ -1762,30 +1762,6 @@ s32 ixgbe_update_eeprom_checksum_generic(struct =
ixgbe_hw *hw)
> >  }
> > =20
> >  /**
> > - *  ixgbe_validate_mac_addr - Validate MAC address
> > - *  @mac_addr: pointer to MAC address.
> > - *
> > - *  Tests a MAC address to ensure it is a valid Individual Address
> > - **/
> > -s32 ixgbe_validate_mac_addr(u8 *mac_addr)
> > -{
> > -	s32 status =3D 0;
> > -
> > -	/* Make sure it is not a multicast address */
> > -	if (IXGBE_IS_MULTICAST(mac_addr))
> > -		status =3D IXGBE_ERR_INVALID_MAC_ADDR;
> > -	/* Not a broadcast address */
> > -	else if (IXGBE_IS_BROADCAST(mac_addr))
> > -		status =3D IXGBE_ERR_INVALID_MAC_ADDR;
> > -	/* Reject the zero address */
> > -	else if (mac_addr[0] =3D=3D 0 && mac_addr[1] =3D=3D 0 && mac_addr[2] =
=3D=3D 0 &&
> > -	         mac_addr[3] =3D=3D 0 && mac_addr[4] =3D=3D 0 && mac_addr[5] =
=3D=3D 0)
> > -		status =3D IXGBE_ERR_INVALID_MAC_ADDR;
> > -
> > -	return status;
> > -}
> > -
> > -/**
> >   *  ixgbe_set_rar_generic - Set Rx address register
> >   *  @hw: pointer to hardware structure
> >   *  @index: Receive address register to write
> > @@ -1889,8 +1865,7 @@ s32 ixgbe_init_rx_addrs_generic(struct ixgbe_hw *=
hw)
> >  	 * to the permanent address.
> >  	 * Otherwise, use the permanent address from the eeprom.
> >  	 */
> > -	if (ixgbe_validate_mac_addr(hw->mac.addr) =3D=3D
> > -	    IXGBE_ERR_INVALID_MAC_ADDR) {
> > +	if (!is_valid_ether_addr(hw->mac.addr)) {
> >  		/* Get the MAC address from the RAR0 for later reference */
> >  		hw->mac.ops.get_mac_addr(hw, hw->mac.addr);
> > =20
> > diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h b/drivers/=
net/ethernet/intel/ixgbe/ixgbe_common.h
> > index d813d11..f49ca84 100644
> > --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
> > +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
> > @@ -80,7 +80,6 @@ s32 ixgbe_enable_rx_dma_generic(struct ixgbe_hw *hw, =
u32 regval);
> >  s32 ixgbe_fc_enable_generic(struct ixgbe_hw *hw);
> >  void ixgbe_fc_autoneg(struct ixgbe_hw *hw);
> > =20
> > -s32 ixgbe_validate_mac_addr(u8 *mac_addr);
> >  s32 ixgbe_acquire_swfw_sync(struct ixgbe_hw *hw, u16 mask);
> >  void ixgbe_release_swfw_sync(struct ixgbe_hw *hw, u16 mask);
> >  s32 ixgbe_get_san_mac_addr_generic(struct ixgbe_hw *hw, u8 *san_mac_ad=
dr);
> > diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/ne=
t/ethernet/intel/ixgbe/ixgbe_main.c
> > index e2a6691..3bb3485 100644
> > --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> > +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> > @@ -7345,7 +7345,7 @@ static int __devinit ixgbe_probe(struct pci_dev *=
pdev,
> >  	memcpy(netdev->dev_addr, hw->mac.perm_addr, netdev->addr_len);
> >  	memcpy(netdev->perm_addr, hw->mac.perm_addr, netdev->addr_len);
> > =20
> > -	if (ixgbe_validate_mac_addr(netdev->perm_addr)) {
> > +	if (!is_valid_ether_addr(netdev->perm_addr)) {
> >  		e_dev_err("invalid MAC address\n");
> >  		err =3D -EIO;
> >  		goto err_sw_init;
> > diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/ne=
t/ethernet/intel/ixgbe/ixgbe_type.h
> > index 0722f33..9ddac64 100644
> > --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
> > +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
> > @@ -1833,15 +1833,6 @@ enum {
> >  /* Number of 100 microseconds we wait for PCI Express master disable *=
/
> >  #define IXGBE_PCI_MASTER_DISABLE_TIMEOUT 800
> > =20
> > -/* Check whether address is multicast.  This is little-endian specific=
 check.*/
> > -#define IXGBE_IS_MULTICAST(Address) \
> > -                (bool)(((u8 *)(Address))[0] & ((u8)0x01))
> > -
> > -/* Check whether an address is broadcast. */
> > -#define IXGBE_IS_BROADCAST(Address)                      \
> > -                ((((u8 *)(Address))[0] =3D=3D ((u8)0xff)) && \
> > -                (((u8 *)(Address))[1] =3D=3D ((u8)0xff)))
> > -
> >  /* RAH */
> >  #define IXGBE_RAH_VIND_MASK     0x003C0000
> >  #define IXGBE_RAH_VIND_SHIFT    18
> > diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c b/drivers/ne=
t/ethernet/intel/ixgbe/ixgbe_x540.c
> > index de4da52..c73b929 100644
> > --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
> > +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
> > @@ -152,7 +152,7 @@ mac_reset_top:
> >  	hw->mac.ops.get_san_mac_addr(hw, hw->mac.san_addr);
> > =20
> >  	/* Add the SAN MAC address to the RAR only if it's a valid address */
> > -	if (ixgbe_validate_mac_addr(hw->mac.san_addr) =3D=3D 0) {
> > +	if (is_valid_ether_addr(hw->mac.san_addr)) {
> >  		hw->mac.ops.set_rar(hw, hw->mac.num_rar_entries - 1,
> >  		                    hw->mac.san_addr, 0, IXGBE_RAH_AV);
> > =20
> >=20
>=20
>=20
>=20



--=-GzXn3XQPzvz+EsF8hAPy
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJQvRPcAAoJEOVv75VaS+3OVdwQAIllmsvkp/eAYAsrCSH/sQrj
l9JFYjtJDy2bdnk0KKzCLtdBCjfs8j0T5OwjaJzwR4TvTLFoRoISP1PikBxkT8VX
tvYaRqDMqsUFIem6eNjMFZdXQrqfWwEkNA+45E5sfZWYr9kM4Az56L7WxMBRkQV2
4E1WJd1VcJnoT252T1RW5LTMwcmaOduvF8HN0mLWeFgpTwkmeDkGykbZgzvQjJG5
6WWhy89qx6abjJfXaheUCew8XAgLsQE8meRj/eW39YeipQ4trhZFGgs+V9JYP/+4
Xm4XGCHrCxcBjsMD38D4+9BpZi97Pb//e0a7TWfdlAO0lrXXiNtFXC9jNiBW8nSb
YnMLUHbmCz+GuVNryDdJXzM0pZ1qwrLB5YAYxhlS1SSEa4HNksIc9CLMZHe8NKux
5/Sl2VwExArssf6hUDfrPuZUYrvbET978xgUkJjOUaHqG4z6SHPrSAVQNa37CU4S
qRRyvkjKyMrb7B6mh/9zexJPBcJFuILjhNmjKQorwyqFu8+/wb2aOvUnvHhMuvzt
zorUTKgHrJaUcAcMSrgXtvi/dcJVnqZVTnv+mV2fYdW9XfwYYQjtN+cNLgzdTKA2
i4utjxbsVmIigp9hXQCXQExJyU0KHXBcHEqgcPbOHDFwB32h/iWRruD/X2PFGAPW
3YPo6vlEzmyvZE7omn+h
=HM2l
-----END PGP SIGNATURE-----

--=-GzXn3XQPzvz+EsF8hAPy--
