From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Netlink messages without NLM_F_REQUEST flag
Date: Wed, 7 Jun 2017 19:19:01 +0300
Message-ID: <20170607161901.GD1127@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="F8dlzb82+Fcn6AgP"
Cc: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Jiri Pirko <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        RDMA mailing list <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
To: Kaike Wan <kaike.wan-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, John Fleck <john.fleck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Ira Weiny <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--F8dlzb82+Fcn6AgP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Kaike,

In the commit bc10ed7d3d19 ("IB/core: Add rdma netlink helper functions"),
part of larger series [1], you introduced ibnl_rcv_reply_skb(), which is very
similar to netlink_rcv_skb() with one major change.

The netlink messages without NLM_F_REQUEST flag are handled by ibnl_rcv_reply_skb(),
while netlink_rcv_skb() doesn't. The comment introduced in commit d35b685640ae
"[NETLINK]: Ignore !NLM_F_REQUEST messages directly in netlink_run_queue()")
says that "Only requests are handled by the kernel".

It makes me wonder if it is expected behavior for ibnl_rcv_reply_skb()
to handle !NLM_F_REQUEST messages and do we really need it? What are the scenarios?
In my use case, which is for sure different from yours, I'm always setting NLM_F_REQUEST
while communicating with kernel.

Thanks

[1] http://www.spinics.net/lists/linux-rdma/msg28153.html

--F8dlzb82+Fcn6AgP
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlk4J3UACgkQ5GN7iDZy
WKcGvA//ayiQkgvCeP4/ySiCg/GBNQxgXyZqJ0rKvW13VcHTfgbF+zrf7DGqE0DO
n17E3fGQwLzxNqv9QJDl4+nVvBZBBCSifw94TFBOeenQMqrX5O9BATpHIaEDD0oU
/d6NeZ5ZoyHCabWvb7EZobitY2EsUgV6iG6iU8RciRkwCv8+2VJM+epnAcFH50ui
COC/tEH7JtmXa+XLA/6G6l5bqd20vxiobZV6WDpudNKnmigVzuV5/HMJshvxD59t
whVrCLaH5zmuhO3WVB6wt2RVbW44TTNsFpMwV9at4OR7iPO3cbvmckKjbOpJ8VO4
zKyV80fbhawh02m0EW0RGfl6CNWpW9uEmPbtlAcgSBvk4CcAxmys0VtohzLF4VTS
0OBrfbt8imWlNcF3Wb4YKGVO/tvmTJuvPAVruZ3AbafMVY1DYBzNhOqMb+5R55EN
SoJBsUFZNYPSBTPh5K7Atry+SsrYB2AM5KpIaJh56B6/0Eb3fn99DJkfqtRsxVKt
oM3w7TxxcCz1O/DtGuDbisclXE7rgmvZnv1GO+Of646UVWInMv3pYzLw/jH4M53/
ZB8MY5anmOUENHBJtf0lKFQOSSYkR1sRw0RHGg8G7zb4wfFxIt+WeVzb1U53qAJb
1yf3LqPvsTc5Av9z88p+tf2TX//FdGxKrP7EbegFTgHf3VVXPlM=
=LDcQ
-----END PGP SIGNATURE-----

--F8dlzb82+Fcn6AgP--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
