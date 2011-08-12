From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [net-next] spider_net: fix compile issue introduced by driver
 move
Date: Fri, 12 Aug 2011 15:00:03 +1000
Message-ID: <20110812150003.1e2ba71018bea040fc7649d7@canb.auug.org.au>
References: <1313120000-12085-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1313120415.2029.3.camel@jtkirshe-mobl>
	<20110812144131.59de312ee6e1a9e8865c1a85@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Fri__12_Aug_2011_15_00_03_+1000__tNTQY5ekq0xKFrd"
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: jeffrey.t.kirsher@intel.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110812144131.59de312ee6e1a9e8865c1a85@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__12_Aug_2011_15_00_03_+1000__tNTQY5ekq0xKFrd
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Jeff,

On Fri, 12 Aug 2011 14:41:31 +1000 Stephen Rothwell <sfr@canb.auug.org.au> =
wrote:
>
> On Thu, 11 Aug 2011 20:40:14 -0700 Jeff Kirsher <jeffrey.t.kirsher@intel.=
com> wrote:
> >
> > On Thu, 2011-08-11 at 20:33 -0700, Kirsher, Jeffrey T wrote:
> > > Both Spider net driver and Sun GEM driver use the sungem_phy.o object.
> > > This fix creates a Kconfig object for sungem_phy (like MDIO) so that
> > > both drivers require the SUNGEM_PHY object.
> > >=20
> > > This has been compile tested for the Sun GEM driver.
> > >=20
> > > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > > ---
> > >  drivers/net/Kconfig               |    4 ++++
> > >  drivers/net/Makefile              |    2 +-
> > >  drivers/net/ethernet/sun/Kconfig  |    1 +
> > >  drivers/net/ethernet/sun/Makefile |    3 ++-
> > >  4 files changed, 8 insertions(+), 2 deletions(-)=20
> >=20
> > Stephen, is it possible for you to try this patch to ensure it resolves
> > the compile issue you saw for the Spider Net driver when merging with
> > David's net-next tree?
>=20
> That patch doesn't come close to applying to the copy of Dave's tree I
> have from this morning (head e7c379d2a0dc).  I'll see if I can figure it
> out ...

OK, I applied it by hand and it seems to fix that failure, thanks.

However, Dave, I now get these (powerpc ppc64defconfig build of just the
net tree):

ERROR: ".cxgb4_unregister_uld" [drivers/scsi/cxgbi/cxgb4i/cxgb4i.ko] undefi=
ned!
ERROR: ".cxgb4_register_uld" [drivers/scsi/cxgbi/cxgb4i/cxgb4i.ko] undefine=
d!
ERROR: ".cxgb4_iscsi_init" [drivers/scsi/cxgbi/cxgb4i/cxgb4i.ko] undefined!
ERROR: ".cxgb4_port_idx" [drivers/scsi/cxgbi/cxgb4i/cxgb4i.ko] undefined!
ERROR: ".cxgb4_port_viid" [drivers/scsi/cxgbi/cxgb4i/cxgb4i.ko] undefined!
ERROR: ".cxgb4_port_chan" [drivers/scsi/cxgbi/cxgb4i/cxgb4i.ko] undefined!
ERROR: ".cxgb4_best_mtu" [drivers/scsi/cxgbi/cxgb4i/cxgb4i.ko] undefined!
ERROR: ".cxgb4_l2t_get" [drivers/scsi/cxgbi/cxgb4i/cxgb4i.ko] undefined!
ERROR: ".cxgb4_alloc_atid" [drivers/scsi/cxgbi/cxgb4i/cxgb4i.ko] undefined!
ERROR: ".cxgb4_l2t_release" [drivers/scsi/cxgbi/cxgb4i/cxgb4i.ko] undefined!
ERROR: ".cxgb4_pktgl_to_skb" [drivers/scsi/cxgbi/cxgb4i/cxgb4i.ko] undefine=
d!
ERROR: ".cxgb4_remove_tid" [drivers/scsi/cxgbi/cxgb4i/cxgb4i.ko] undefined!
ERROR: ".cxgb4_free_atid" [drivers/scsi/cxgbi/cxgb4i/cxgb4i.ko] undefined!
ERROR: ".cxgb4_ofld_send" [drivers/scsi/cxgbi/cxgb4i/cxgb4i.ko] undefined!
ERROR: ".cxgb4_l2t_send" [drivers/scsi/cxgbi/cxgb4i/cxgb4i.ko] undefined!
ERROR: ".cxgb3_unregister_client" [drivers/scsi/cxgbi/cxgb3i/cxgb3i.ko] und=
efined!
ERROR: ".cxgb3_register_client" [drivers/scsi/cxgbi/cxgb3i/cxgb3i.ko] undef=
ined!
ERROR: ".t3_l2e_free" [drivers/scsi/cxgbi/cxgb3i/cxgb3i.ko] undefined!
ERROR: ".cxgb3_remove_tid" [drivers/scsi/cxgbi/cxgb3i/cxgb3i.ko] undefined!
ERROR: ".cxgb3_alloc_atid" [drivers/scsi/cxgbi/cxgb3i/cxgb3i.ko] undefined!
ERROR: ".t3_l2t_get" [drivers/scsi/cxgbi/cxgb3i/cxgb3i.ko] undefined!
ERROR: ".cxgb3_queue_tid_release" [drivers/scsi/cxgbi/cxgb3i/cxgb3i.ko] und=
efined!
ERROR: ".cxgb3_free_atid" [drivers/scsi/cxgbi/cxgb3i/cxgb3i.ko] undefined!
ERROR: ".cxgb3_insert_tid" [drivers/scsi/cxgbi/cxgb3i/cxgb3i.ko] undefined!
ERROR: ".t3_l2t_send_slow" [drivers/scsi/cxgbi/cxgb3i/cxgb3i.ko] undefined!
ERROR: ".cxgb3_ofld_send" [drivers/scsi/cxgbi/cxgb3i/cxgb3i.ko] undefined!
ERROR: ".cnic_unregister_driver" [drivers/scsi/bnx2i/bnx2i.ko] undefined!
ERROR: ".cnic_register_driver" [drivers/scsi/bnx2i/bnx2i.ko] undefined!
ERROR: ".mii_phy_probe" [drivers/net/spidernet.ko] undefined!
ERROR: ".mlx4_cq_free" [drivers/infiniband/hw/mlx4/mlx4_ib.ko] undefined!
ERROR: ".mlx4_qp_release_range" [drivers/infiniband/hw/mlx4/mlx4_ib.ko] und=
efined!
ERROR: ".mlx4_counter_alloc" [drivers/infiniband/hw/mlx4/mlx4_ib.ko] undefi=
ned!
ERROR: ".mlx4_write_mtt" [drivers/infiniband/hw/mlx4/mlx4_ib.ko] undefined!
ERROR: ".mlx4_get_protocol_dev" [drivers/infiniband/hw/mlx4/mlx4_ib.ko] und=
efined!
ERROR: ".mlx4_srq_free" [drivers/infiniband/hw/mlx4/mlx4_ib.ko] undefined!
ERROR: ".mlx4_srq_query" [drivers/infiniband/hw/mlx4/mlx4_ib.ko] undefined!
ERROR: ".mlx4_fmr_free" [drivers/infiniband/hw/mlx4/mlx4_ib.ko] undefined!
ERROR: ".mlx4_multicast_detach" [drivers/infiniband/hw/mlx4/mlx4_ib.ko] und=
efined!
ERROR: ".mlx4_db_free" [drivers/infiniband/hw/mlx4/mlx4_ib.ko] undefined!
ERROR: ".mlx4_unregister_interface" [drivers/infiniband/hw/mlx4/mlx4_ib.ko]=
 undefined!
ERROR: ".mlx4_buf_alloc" [drivers/infiniband/hw/mlx4/mlx4_ib.ko] undefined!
ERROR: ".mlx4_mr_alloc" [drivers/infiniband/hw/mlx4/mlx4_ib.ko] undefined!
ERROR: ".mlx4_mtt_init" [drivers/infiniband/hw/mlx4/mlx4_ib.ko] undefined!
ERROR: ".mlx4_fmr_alloc" [drivers/infiniband/hw/mlx4/mlx4_ib.ko] undefined!
ERROR: ".mlx4_cq_alloc" [drivers/infiniband/hw/mlx4/mlx4_ib.ko] undefined!
ERROR: ".mlx4_pd_free" [drivers/infiniband/hw/mlx4/mlx4_ib.ko] undefined!
ERROR: ".mlx4_SYNC_TPT" [drivers/infiniband/hw/mlx4/mlx4_ib.ko] undefined!
ERROR: ".mlx4_qp_free" [drivers/infiniband/hw/mlx4/mlx4_ib.ko] undefined!
ERROR: ".mlx4_buf_write_mtt" [drivers/infiniband/hw/mlx4/mlx4_ib.ko] undefi=
ned!
ERROR: ".mlx4_cq_resize" [drivers/infiniband/hw/mlx4/mlx4_ib.ko] undefined!
ERROR: ".mlx4_fmr_unmap" [drivers/infiniband/hw/mlx4/mlx4_ib.ko] undefined!
ERROR: ".mlx4_qp_modify" [drivers/infiniband/hw/mlx4/mlx4_ib.ko] undefined!
ERROR: ".mlx4_mtt_cleanup" [drivers/infiniband/hw/mlx4/mlx4_ib.ko] undefine=
d!
ERROR: ".mlx4_counter_free" [drivers/infiniband/hw/mlx4/mlx4_ib.ko] undefin=
ed!
ERROR: ".mlx4_mr_free" [drivers/infiniband/hw/mlx4/mlx4_ib.ko] undefined!
ERROR: ".mlx4_qp_reserve_range" [drivers/infiniband/hw/mlx4/mlx4_ib.ko] und=
efined!
ERROR: ".mlx4_alloc_cmd_mailbox" [drivers/infiniband/hw/mlx4/mlx4_ib.ko] un=
defined!
ERROR: ".mlx4_fmr_enable" [drivers/infiniband/hw/mlx4/mlx4_ib.ko] undefined!
ERROR: ".mlx4_mr_enable" [drivers/infiniband/hw/mlx4/mlx4_ib.ko] undefined!
ERROR: ".mlx4_uar_free" [drivers/infiniband/hw/mlx4/mlx4_ib.ko] undefined!
ERROR: ".mlx4_db_alloc" [drivers/infiniband/hw/mlx4/mlx4_ib.ko] undefined!
ERROR: ".mlx4_pd_alloc" [drivers/infiniband/hw/mlx4/mlx4_ib.ko] undefined!
ERROR: ".mlx4_free_cmd_mailbox" [drivers/infiniband/hw/mlx4/mlx4_ib.ko] und=
efined!
ERROR: ".mlx4_srq_alloc" [drivers/infiniband/hw/mlx4/mlx4_ib.ko] undefined!
ERROR: ".mlx4_uar_alloc" [drivers/infiniband/hw/mlx4/mlx4_ib.ko] undefined!
ERROR: ".mlx4_CLOSE_PORT" [drivers/infiniband/hw/mlx4/mlx4_ib.ko] undefined!
ERROR: ".mlx4_qp_query" [drivers/infiniband/hw/mlx4/mlx4_ib.ko] undefined!
ERROR: ".mlx4_qp_alloc" [drivers/infiniband/hw/mlx4/mlx4_ib.ko] undefined!
ERROR: ".mlx4_map_phys_fmr" [drivers/infiniband/hw/mlx4/mlx4_ib.ko] undefin=
ed!
ERROR: ".mlx4_qp_remove" [drivers/infiniband/hw/mlx4/mlx4_ib.ko] undefined!
ERROR: ".mlx4_multicast_attach" [drivers/infiniband/hw/mlx4/mlx4_ib.ko] und=
efined!
ERROR: ".mlx4_INIT_PORT" [drivers/infiniband/hw/mlx4/mlx4_ib.ko] undefined!
ERROR: ".mlx4_cq_modify" [drivers/infiniband/hw/mlx4/mlx4_ib.ko] undefined!
ERROR: ".mlx4_srq_arm" [drivers/infiniband/hw/mlx4/mlx4_ib.ko] undefined!
ERROR: ".mlx4_find_cached_vlan" [drivers/infiniband/hw/mlx4/mlx4_ib.ko] und=
efined!
ERROR: ".mlx4_buf_free" [drivers/infiniband/hw/mlx4/mlx4_ib.ko] undefined!
ERROR: ".__mlx4_cmd" [drivers/infiniband/hw/mlx4/mlx4_ib.ko] undefined!
ERROR: ".mlx4_register_interface" [drivers/infiniband/hw/mlx4/mlx4_ib.ko] u=
ndefined!
ERROR: ".cxgb4_free_atid" [drivers/infiniband/hw/cxgb4/iw_cxgb4.ko] undefin=
ed!
ERROR: ".cxgb4_ofld_send" [drivers/infiniband/hw/cxgb4/iw_cxgb4.ko] undefin=
ed!
ERROR: ".cxgb4_alloc_stid" [drivers/infiniband/hw/cxgb4/iw_cxgb4.ko] undefi=
ned!
ERROR: ".cxgb4_get_tcp_stats" [drivers/infiniband/hw/cxgb4/iw_cxgb4.ko] und=
efined!
ERROR: ".cxgb4_l2t_release" [drivers/infiniband/hw/cxgb4/iw_cxgb4.ko] undef=
ined!
ERROR: ".cxgb4_l2t_get" [drivers/infiniband/hw/cxgb4/iw_cxgb4.ko] undefined!
ERROR: ".cxgb4_best_mtu" [drivers/infiniband/hw/cxgb4/iw_cxgb4.ko] undefine=
d!
ERROR: ".cxgb4_port_idx" [drivers/infiniband/hw/cxgb4/iw_cxgb4.ko] undefine=
d!
ERROR: ".cxgb4_unregister_uld" [drivers/infiniband/hw/cxgb4/iw_cxgb4.ko] un=
defined!
ERROR: ".cxgb4_alloc_atid" [drivers/infiniband/hw/cxgb4/iw_cxgb4.ko] undefi=
ned!
ERROR: ".cxgb4_l2t_send" [drivers/infiniband/hw/cxgb4/iw_cxgb4.ko] undefine=
d!
ERROR: ".cxgb4_free_stid" [drivers/infiniband/hw/cxgb4/iw_cxgb4.ko] undefin=
ed!
ERROR: ".cxgb4_pktgl_to_skb" [drivers/infiniband/hw/cxgb4/iw_cxgb4.ko] unde=
fined!
ERROR: ".cxgb4_create_server" [drivers/infiniband/hw/cxgb4/iw_cxgb4.ko] und=
efined!
ERROR: ".cxgb4_register_uld" [drivers/infiniband/hw/cxgb4/iw_cxgb4.ko] unde=
fined!
ERROR: ".cxgb4_port_chan" [drivers/infiniband/hw/cxgb4/iw_cxgb4.ko] undefin=
ed!
ERROR: ".cxgb4_port_viid" [drivers/infiniband/hw/cxgb4/iw_cxgb4.ko] undefin=
ed!
ERROR: ".cxgb4_remove_tid" [drivers/infiniband/hw/cxgb4/iw_cxgb4.ko] undefi=
ned!
ERROR: ".dev2t3cdev" [drivers/infiniband/hw/cxgb3/iw_cxgb3.ko] undefined!
ERROR: ".cxgb3_insert_tid" [drivers/infiniband/hw/cxgb3/iw_cxgb3.ko] undefi=
ned!
ERROR: ".t3_l2t_get" [drivers/infiniband/hw/cxgb3/iw_cxgb3.ko] undefined!
ERROR: ".cxgb3_register_client" [drivers/infiniband/hw/cxgb3/iw_cxgb3.ko] u=
ndefined!
ERROR: ".t3_l2t_send_slow" [drivers/infiniband/hw/cxgb3/iw_cxgb3.ko] undefi=
ned!
ERROR: ".cxgb3_unregister_client" [drivers/infiniband/hw/cxgb3/iw_cxgb3.ko]=
 undefined!
ERROR: ".cxgb3_free_stid" [drivers/infiniband/hw/cxgb3/iw_cxgb3.ko] undefin=
ed!
ERROR: ".cxgb3_free_atid" [drivers/infiniband/hw/cxgb3/iw_cxgb3.ko] undefin=
ed!
ERROR: ".cxgb3_alloc_stid" [drivers/infiniband/hw/cxgb3/iw_cxgb3.ko] undefi=
ned!
ERROR: ".cxgb3_remove_tid" [drivers/infiniband/hw/cxgb3/iw_cxgb3.ko] undefi=
ned!
ERROR: ".cxgb3_ofld_send" [drivers/infiniband/hw/cxgb3/iw_cxgb3.ko] undefin=
ed!
ERROR: ".cxgb3_alloc_atid" [drivers/infiniband/hw/cxgb3/iw_cxgb3.ko] undefi=
ned!
ERROR: ".t3_l2t_send_event" [drivers/infiniband/hw/cxgb3/iw_cxgb3.ko] undef=
ined!
ERROR: ".t3_l2e_free" [drivers/infiniband/hw/cxgb3/iw_cxgb3.ko] undefined!
ERROR: ".t3_register_cpl_handler" [drivers/infiniband/hw/cxgb3/iw_cxgb3.ko]=
 undefined!

and I don't get this if I go back to your commit 19fd61785a58.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Fri__12_Aug_2011_15_00_03_+1000__tNTQY5ekq0xKFrd
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJORLNTAAoJEDMEi1NhKgbsaXEH/00jp5C82sIxiWvpnNF1nWvR
Ltzv3iA41LZxctKyYTZV4VnAjarqRtQa7bB+cd12wl8Rn3h27XWuQGdCeot9VVwL
ljHtH1ATzjiOSexr26nT11IKiV1JbMzIaiOQTwaca8jj5+POy2iXgMHz88ppkXYZ
EZiV9XKMMT27JYkJaSJ5M+4GzWg1RxBpqPFMwMHSneU4nziSLfhISiu1Fsiw6uAJ
G1owSAS2yY4oQLS6RPCIEXE3c8DOrjKj7GPZf0e/LA248mhGUZIF8zJiO2FR8DCq
l19zlfMDJ+VHatbNtc6+kJbeY9dKDPeQ+H+6oyd4tqbmuayJ6ZaFluS2W+TKu3s=
=KjgZ
-----END PGP SIGNATURE-----

--Signature=_Fri__12_Aug_2011_15_00_03_+1000__tNTQY5ekq0xKFrd--
