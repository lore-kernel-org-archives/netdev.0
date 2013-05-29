From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the staging tree with the net-next tree
Date: Wed, 29 May 2013 14:14:22 +1000
Message-ID: <20130529141422.f0ce7703d21d02b9d2543930@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__29_May_2013_14_14_22_+1000_cGEhQs7vuwNb7q5X"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jiri Pirko <jiri@resnulli.us>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	=?UTF-8?B?IlTDvGxpbiDEsHplciI=?= <tulinizer@gmail.com>
To: Greg KH <greg@kroah.com>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__29_May_2013_14_14_22_+1000_cGEhQs7vuwNb7q5X
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Greg,

Today's linux-next merge of the staging tree got a conflict in
drivers/staging/silicom/bpctl_mod.c between commit 351638e7deee ("net:
pass info struct via netdevice notifier") from the net-next tree and
commit f84b075178b4 ("Staging: silicom: Fixed error 'do not initialise
statics to 0 or NULL'") from the staging tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/staging/silicom/bpctl_mod.c
index c8ddb99,3082ba9..0000000
--- a/drivers/staging/silicom/bpctl_mod.c
+++ b/drivers/staging/silicom/bpctl_mod.c
@@@ -133,8 -133,8 +133,8 @@@ static unsigned long str_to_hex(char *p
  static int bp_device_event(struct notifier_block *unused,
  			   unsigned long event, void *ptr)
  {
 -	struct net_device *dev =3D ptr;
 +	struct net_device *dev =3D netdev_notifier_info_to_dev(ptr);
- 	static bpctl_dev_t *pbpctl_dev =3D NULL, *pbpctl_dev_m =3D NULL;
+ 	static bpctl_dev_t *pbpctl_dev, *pbpctl_dev_m;
  	int dev_num =3D 0, ret =3D 0, ret_d =3D 0, time_left =3D 0;
  	/* printk("BP_PROC_SUPPORT event =3D%d %s %d\n", event,dev->name, dev->i=
findex ); */
  	/* return NOTIFY_DONE; */

--Signature=_Wed__29_May_2013_14_14_22_+1000_cGEhQs7vuwNb7q5X
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBCAAGBQJRpYCiAAoJEECxmPOUX5FEM3sP/2rJTONSd5NFMmOGPqMPiUo7
b6KWuTUUEX9d3HBU//Ms7zsvYBXyP/BmnB82JqiwZ62SYMmuBlhgeiXTEmod/4Sc
rS2b3V3LPVn4VT3Drj65Cxgd0VXiYe0PHDEBXWkb3UXZbN8VbWHpWMNKDR0seTqk
yiFNgd0/7mOdeAU+s6WeZ4LC+WiXyuLLo1l7mDCfGlODq4LHnbUjU8CwVsDukwIs
oFDgaVpi+L45z4WwrSgPMnVh0JabcEX7cw0cCnAjDTvRpCMAHvFlz9tRUX6txEx4
EnYMAy/hQjMyxfVkJd8VXAMdBBGXZp8gckvICkZcL5yFJyUo4h3QqHdVu5VBCUJ2
tNZsaWb0awyE7s8Kk7rw5p/f01l9WZjUn4nmPnXt51KDd5yR0zv0et6tpd+y3Bot
ECuEeAv1cACbXNTSZydvwrdI/JFSfr6uf9BUOk0L8M7JUj5ceym3DhktMjp1ubfr
pMYpc/8wc/b+CAvWBD32oKLiVljuljxLJyjsYU1TosuhZh7DiLDvJbSgQPNbO4di
qPym3ntBrO7RdwVjE44TtWybAHQPf7Kfm+i+SvqfTdgChmKXYbGEXAS08uVeRg6a
maDB99MI1MbbIrNu1ZtGHdvOAdGslVH/DyqfCGewOjxgrlT0Vzkv7+LvnDz+WygT
6egXAH/EI0KIU0frI7ul
=0TuX
-----END PGP SIGNATURE-----

--Signature=_Wed__29_May_2013_14_14_22_+1000_cGEhQs7vuwNb7q5X--
