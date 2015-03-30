From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC PATCH 06/11] IB/Verbs: Use management helper has_sa() and
 cap_sa(), for sa-check
Date: Mon, 30 Mar 2015 12:16:31 -0400
Message-ID: <1427732191.21101.201.camel@redhat.com>
References: <551579CA.4030901@profitbricks.com>
	 <55157B43.6060507@profitbricks.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-5ADd0vGoGV4ieV93aC5H"
Cc: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Ira Weiny <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Moni Shoua <monis-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	PJ Waskiewicz <pj.waskiewicz-PrFOU5CTvK1l57MIdRCFDg@public.gmane.org>,
	Tatyana Nikolova <Tatyana.E.Nikolova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Yan Burman <yanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Jack Morgenstein <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>,
	Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org>,
	Yann Droneaud <ydroneaud-RlY5vtjFyJ3QT0dZR+AlfA@public.gmane.org>,
	Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	Majd Dibbiny <majd-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>,
	Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Alex Estrin <alex.estrin@int
To: Michael Wang <yun.wang-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <55157B43.6060507-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-5ADd0vGoGV4ieV93aC5H
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2015-03-27 at 16:46 +0100, Michael Wang wrote:
> Introduce helper has_sa() and cap_sa() to help us check if an IB device
> or it's port support Subnet Administrator.

There's no functional reason to have both rdma_transport_is_ib and
rdma_port_ll_is_ib, just use one.  Then there is also no reason for both
has_sa and cap_sa.  Just use one.

> Cc: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
> Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Cc: Ira Weiny <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> Cc: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> Signed-off-by: Michael Wang <yun.wang-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>
> ---
>  drivers/infiniband/core/sa_query.c | 12 ++++++------
>  include/rdma/ib_verbs.h            | 28 ++++++++++++++++++++++++++++
>  2 files changed, 34 insertions(+), 6 deletions(-)
>=20
> diff --git a/drivers/infiniband/core/sa_query.c b/drivers/infiniband/core=
/sa_query.c
> index d95d25f..89c27da 100644
> --- a/drivers/infiniband/core/sa_query.c
> +++ b/drivers/infiniband/core/sa_query.c
> @@ -450,7 +450,7 @@ static void ib_sa_event(struct ib_event_handler *hand=
ler, struct ib_event *event
>          struct ib_sa_port *port =3D
>              &sa_dev->port[event->element.port_num - sa_dev->start_port];
> =20
> -        if (!rdma_port_ll_is_ib(handler->device, port->port_num))
> +        if (!cap_sa(handler->device, port->port_num))
>              return;
> =20
>          spin_lock_irqsave(&port->ah_lock, flags);
> @@ -1154,7 +1154,7 @@ static void ib_sa_add_one(struct ib_device *device)
>      struct ib_sa_device *sa_dev;
>      int s, e, i;
> =20
> -    if (!rdma_transport_is_ib(device))
> +    if (!has_sa(device))
>          return;
> =20
>      if (device->node_type =3D=3D RDMA_NODE_IB_SWITCH)
> @@ -1175,7 +1175,7 @@ static void ib_sa_add_one(struct ib_device *device)
> =20
>      for (i =3D 0; i <=3D e - s; ++i) {
>          spin_lock_init(&sa_dev->port[i].ah_lock);
> -        if (!rdma_port_ll_is_ib(device, i + 1))
> +        if (!cap_sa(device, i + 1))
>              continue;
> =20
>          sa_dev->port[i].sm_ah    =3D NULL;
> @@ -1205,14 +1205,14 @@ static void ib_sa_add_one(struct ib_device *devic=
e)
>          goto err;
> =20
>      for (i =3D 0; i <=3D e - s; ++i)
> -        if (rdma_port_ll_is_ib(device, i + 1))
> +        if (cap_sa(device, i + 1))
>              update_sm_ah(&sa_dev->port[i].update_task);
> =20
>      return;
> =20
>  err:
>      while (--i >=3D 0)
> -        if (rdma_port_ll_is_ib(device, i + 1))
> +        if (cap_sa(device, i + 1))
>              ib_unregister_mad_agent(sa_dev->port[i].agent);
> =20
>      kfree(sa_dev);
> @@ -1233,7 +1233,7 @@ static void ib_sa_remove_one(struct ib_device *devi=
ce)
>      flush_workqueue(ib_wq);
> =20
>      for (i =3D 0; i <=3D sa_dev->end_port - sa_dev->start_port; ++i) {
> -        if (rdma_port_ll_is_ib(device, i + 1)) {
> +        if (cap_sa(device, i + 1)) {
>              ib_unregister_mad_agent(sa_dev->port[i].agent);
>              if (sa_dev->port[i].sm_ah)
>                  kref_put(&sa_dev->port[i].sm_ah->ref, free_sm_ah);
> diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
> index c0a63f8..fa8ffa3 100644
> --- a/include/rdma/ib_verbs.h
> +++ b/include/rdma/ib_verbs.h
> @@ -1810,6 +1810,19 @@ static inline int has_cm(struct ib_device *device)
>  }
> =20
>  /**
> + * has_sa - Check if a device support Subnet Administrator.
> + *
> + * @device: Device to be checked
> + *
> + * Return 0 when a device has none port to support
> + * Subnet Administrator.
> + */
> +static inline int has_sa(struct ib_device *device)
> +{
> +    return rdma_transport_is_ib(device);
> +}
> +
> +/**
>   * cap_smi - Check if the port of device has the capability
>   * Subnet Management Interface.
>   *
> @@ -1824,6 +1837,21 @@ static inline int cap_smi(struct ib_device *device=
, u8 port_num)
>      return rdma_port_ll_is_ib(device, port_num);
>  }
> =20
> +/**
> + * cap_sa - Check if the port of device has the capability
> + * Subnet Administrator.
> + *
> + * @device: Device to be checked
> + * @port_num: Port number of the device
> + *
> + * Return 0 when port of the device don't support
> + * Subnet Administrator.
> + */
> +static inline int cap_sa(struct ib_device *device, u8 port_num)
> +{
> +    return rdma_port_ll_is_ib(device, port_num);
> +}
> +
>  int ib_query_gid(struct ib_device *device,
>           u8 port_num, int index, union ib_gid *gid);
> =20


--=20
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
              GPG KeyID: 0E572FDD



--=-5ADd0vGoGV4ieV93aC5H
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABAgAGBQJVGXbfAAoJELgmozMOVy/dAgAP/1iMoOpy0bgbs5+3lbDuZmdD
w78Ilt3a4lmtxBLeUiSol0+EeCYwMD7grc0ynQkeYZ4Yj8ll69vJwZ27RvaE8XLl
Ivgaq8IfgugYICH5VBpAks7aFuBIuCIO5RSKu58D5B3CjSxl+H1X3taSCHSJhl9Y
Jqdep8JZSCQVhcvirJz03zmAv0Zr4LvXH0py6evGKA/b5wEmtTQHr5Z+Rs1K21CQ
OdTpRa/YC1VBAJVz8H8Y6ufssvVgRKGjuGB0rBabWY17We3VuQMLol4UOIE4wnhi
j07II8zZtlRchlRbtGpXs3FMKomsncMcY2ecg6ZZO7PomgNIjmsnCVKiSVHshiXz
BY2XQt1AOVqTH0Sp5LgOjTrjVGMT3E0FQ/dN2DVq86InJARiGcSCInJPxgg8EgT5
3md3H/qnXU4yTBAZTOLQI05ztgYSHigyH7O4xRaHtOpDydoa/xu7Sm3wo0GopU4r
y9g3/wPPCrGO/S76Zd39nC0JyYYxaid0bkSOXzEXoE5gRVVD7Pv70QHZxJs5Zimm
pLRYaDO58rHw8itwm6CBeSBWxT5topNTOMO3n+JXxlWhyy9oo5zIzI1pyc57folp
OsKPSeOJHJ3TKw96hAd0RlK1Cju4mcUsEr7wKDmYYhtvRUvkmVbagyN211NsiqII
viCxFvKGS9XcZCrxWpjv
=1wC6
-----END PGP SIGNATURE-----

--=-5ADd0vGoGV4ieV93aC5H--

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
