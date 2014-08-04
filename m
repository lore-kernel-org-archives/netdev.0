From: Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>
Subject: linux-next: manual merge of the infiniband tree with the net-next
 tree
Date: Mon, 4 Aug 2014 14:03:29 +1000
Message-ID: <20140804140329.180c862c@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/OIAGg8M_jB+cDAnBWQgiEVC"; protocol="application/pgp-signature"
Cc: linux-next-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Jack Morgenstein <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Amir Vadai <amirv-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--Sig_/OIAGg8M_jB+cDAnBWQgiEVC
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the infiniband tree got a conflict in
include/linux/mlx4/device.h between commit 2599d8580f93
("net/mlx4_core: Use low memory profile on kdump kernel") from the
net-next tree and commit e630664c8383 ("mlx4_core: Add helper functions
to support MR re-registration") from the infiniband tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org

diff --cc include/linux/mlx4/device.h
index e15b1544ea83,bac002167ace..000000000000
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@@ -1254,11 -1244,19 +1255,26 @@@ int mlx4_vf_smi_enabled(struct mlx4_de
  int mlx4_vf_get_enable_smi_admin(struct mlx4_dev *dev, int slave, int por=
t);
  int mlx4_vf_set_enable_smi_admin(struct mlx4_dev *dev, int slave, int por=
t,
  				 int enable);
+ int mlx4_mr_hw_get_mpt(struct mlx4_dev *dev, struct mlx4_mr *mmr,
+ 		       struct mlx4_mpt_entry ***mpt_entry);
+ int mlx4_mr_hw_write_mpt(struct mlx4_dev *dev, struct mlx4_mr *mmr,
+ 			 struct mlx4_mpt_entry **mpt_entry);
+ int mlx4_mr_hw_change_pd(struct mlx4_dev *dev, struct mlx4_mpt_entry *mpt=
_entry,
+ 			 u32 pdn);
+ int mlx4_mr_hw_change_access(struct mlx4_dev *dev,
+ 			     struct mlx4_mpt_entry *mpt_entry,
+ 			     u32 access);
+ void mlx4_mr_hw_put_mpt(struct mlx4_dev *dev,
+ 			struct mlx4_mpt_entry **mpt_entry);
+ void mlx4_mr_rereg_mem_cleanup(struct mlx4_dev *dev, struct mlx4_mr *mr);
+ int mlx4_mr_rereg_mem_write(struct mlx4_dev *dev, struct mlx4_mr *mr,
+ 			    u64 iova, u64 size, int npages,
+ 			    int page_shift, struct mlx4_mpt_entry *mpt_entry);
 +
 +/* Returns true if running in low memory profile (kdump kernel) */
 +static inline bool mlx4_low_memory_profile(void)
 +{
 +	return reset_devices;
 +}
 +
  #endif /* MLX4_DEVICE_H */

--Sig_/OIAGg8M_jB+cDAnBWQgiEVC
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJT3wYWAAoJEMDTa8Ir7ZwVR7sP/00gnPVaymNcSgBH2QCSadsx
HO4H9WnGBB1ytDXow4OI6LmxAge+C0i+AGDFP2D8iiPBO9mTgXX8vZPDZpWq/Sl3
Ilms2EkUM1HeE21rok7w11EsTem1MnXq1uKZoEOal8mxK6lxYkHENXyqEiBf5fwH
mKQL29JLKBoyDuKI15oy2pn2vkVup1caoIPCSDP2je+L7TE6aeYfBr6Wl6NTn7IX
OvdG+xfd2I0gM6EBYYS40UjmrQoGuUCoejdKvGbK3QXVVE+zFqDvPaRZmR/lg0l8
s7GwO6cv9nUAOtMJP33StFNSGaocNwhCm2mD6dsFAc78W0W0XHKx5Xf/GRtFPzUS
WOTBWIVsMR0r9OSNT30NOg2MU7ISHgfHpqefOopz6VZQi2eS2oNEJHaRlkW6pVC5
b4iKLrADtN6Zzgy4EF+87Gz15w3fBRDuY1je+EFS/Yg0flZiKg9fhVaHFQHDuFzl
cMHSv4DEK9c2sBXxzh8k1DDXUDlLAO2xZZe8sBcbAZnCN8Fj8sKeKMgHsJnXKj1d
SYq+JojKaRTXfPz8zfGxVw+iZzSPEDCrGlL8ZlWpLqtA6mNpNBMLxVjD6FtvXrtH
6zrFQN/cLlJEIle74eTYjWWbMQzG0fJaI0GguT7Mmii3+WwldjHhOIAYNPOSraCz
FF6HdNic19wEgOH2RvW0
=mC2m
-----END PGP SIGNATURE-----

--Sig_/OIAGg8M_jB+cDAnBWQgiEVC--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
