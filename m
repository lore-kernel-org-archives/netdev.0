From: Yann Droneaud <ydroneaud-RlY5vtjFyJ3QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH for-next 01/10] IB/addr: Pass network namespace as a
 parameter
Date: Sun, 01 Feb 2015 15:38:00 +0100
Message-ID: <1422801480.3030.53.camel@opteya.com>
References: <1422790133-28725-1-git-send-email-raindel@mellanox.com>
	 <1422790133-28725-2-git-send-email-raindel@mellanox.com>
	 <1422793376.3030.37.camel@opteya.com>
	 <AM3PR05MB0935B7B53439298A7429158BDC3F0@AM3PR05MB0935.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org" <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <AM3PR05MB0935B7B53439298A7429158BDC3F0-LOZWmgKjnYgQouBfZGh8ttqRiQSDpxhJvxpqHgZTriW3zl9H0oFU5g@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

Le dimanche 01 f=C3=A9vrier 2015 =C3=A0 13:46 +0000, Shachar Raindel a =
=C3=A9crit :

> > -----Original Message-----
> > From: Yann Droneaud [mailto:ydroneaud-RlY5vtjFyJ3QT0dZR+AlfA@public.gmane.org]
> > Sent: Sunday, February 01, 2015 2:23 PM
> > To: Shachar Raindel
> > Cc: roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org; sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org; linux-rdma-u79uwXL29TZUIDd8j+nm9g@public.gmane.org=
=2Eorg;
> > netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; Liran Liss; Guy Shapiro; Haggai Eran; Yotam
> > Kenneth
> > Subject: Re: [PATCH for-next 01/10] IB/addr: Pass network namespace=
 as a
> > parameter
> >=20
> > Hi,
> >=20
> > Le dimanche 01 f=C3=A9vrier 2015 =C3=A0 13:28 +0200, Shachar Rainde=
l a =C3=A9crit :
> > > From: Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> > >
> > > Add network namespace support to the ib_addr module. For that, al=
l the
> > address
> > > resolution and matching should be done using the appropriate name=
space
> > instead
> > > of init_net.
> > >
> > > This is achieved by:
> > >
> > > 1. Adding an explicit network namespace argument to exported func=
tion
> > that
> > >    require a namespace.
> > > 2. Saving the namespace in the rdma_addr_client structure.
> > > 3. Using it when calling networking functions.
> > >
> > > In order to preserve the behavior of calling modules, &init_net i=
s
> > > passed as the parameter in calls from other modules. This is modi=
fied
> > as
> > > namspace support is added on more levels.
> >=20
> > typo: "namespace"
> >=20
>=20
> Thanks. Will fix in next iteration.
>=20
> > >
> > > Signed-off-by: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> > > Signed-off-by: Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> > > Signed-off-by: Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> > > Signed-off-by: Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> > >
> > > ---
> > >  drivers/infiniband/core/addr.c           | 31 ++++++++++++------=
----
> > >  drivers/infiniband/core/cma.c            |  4 ++-
> > >  drivers/infiniband/core/verbs.c          | 14 +++++++---
> > >  drivers/infiniband/hw/ocrdma/ocrdma_ah.c |  3 ++-
> > >  include/rdma/ib_addr.h                   | 44
> > ++++++++++++++++++++++++++++----
> > >  5 files changed, 72 insertions(+), 24 deletions(-)
> > >
> > > diff --git a/drivers/infiniband/core/addr.c
> > b/drivers/infiniband/core/addr.c
> > > index f80da50d84a5..95beaef6b66d 100644
> > > --- a/drivers/infiniband/core/addr.c
> > > +++ b/drivers/infiniband/core/addr.c
> > > @@ -128,7 +128,7 @@ int rdma_translate_ip(struct sockaddr *addr,
> > struct rdma_dev_addr *dev_addr,
> > >  	int ret =3D -EADDRNOTAVAIL;
> > >
> > >  	if (dev_addr->bound_dev_if) {
> > > -		dev =3D dev_get_by_index(&init_net, dev_addr->bound_dev_if);
> > > +		dev =3D dev_get_by_index(dev_addr->net, dev_addr-
> > >bound_dev_if);
> > >  		if (!dev)
> > >  			return -ENODEV;
> > >  		ret =3D rdma_copy_addr(dev_addr, dev, NULL);
> > > @@ -137,9 +137,10 @@ int rdma_translate_ip(struct sockaddr *addr,
> > struct rdma_dev_addr *dev_addr,
> > >  	}
> > >
> > >  	switch (addr->sa_family) {
> > > -	case AF_INET:
> > > -		dev =3D ip_dev_find(&init_net,
> > > -			((struct sockaddr_in *) addr)->sin_addr.s_addr);
> > > +	case AF_INET: {
> > > +		struct sockaddr_in *addr_in =3D (struct sockaddr_in *)addr;
> > > +
> > > +		dev =3D ip_dev_find(dev_addr->net, addr_in->sin_addr.s_addr);
> >=20
> > I don't see the point of this change.
> >=20
>=20
> Note that we changed &init_net to be dev_addr->net .
> The rest of the change here was done to avoid issues with checkpatch,=
 as the line was getting really long.
>=20
> > >
> > >  		if (!dev)
> > >  			return ret;
> > > @@ -149,12 +150,12 @@ int rdma_translate_ip(struct sockaddr *addr=
,
> > struct rdma_dev_addr *dev_addr,
> > >  			*vlan_id =3D rdma_vlan_dev_vlan_id(dev);
> > >  		dev_put(dev);
> > >  		break;
> > > -
> > > +	}
> >=20
> > closing } here ?
>=20
> We opened a block in the beginning of this case ("case AF_INET: {"), =
we close it at the end of the case.
>=20
> >=20
> > >  #if IS_ENABLED(CONFIG_IPV6)
> > >  	case AF_INET6:
> > >  		rcu_read_lock();
> > > -		for_each_netdev_rcu(&init_net, dev) {
> > > -			if (ipv6_chk_addr(&init_net,
> > > +		for_each_netdev_rcu(dev_addr->net, dev) {
> > > +			if (ipv6_chk_addr(dev_addr->net,
> > >  					  &((struct sockaddr_in6 *) addr)->sin6_addr,
> > >  					  dev, 1)) {
> > >  				ret =3D rdma_copy_addr(dev_addr, dev, NULL);
> > > @@ -236,7 +237,7 @@ static int addr4_resolve(struct sockaddr_in
> > *src_in,
> > >  	fl4.daddr =3D dst_ip;
> > >  	fl4.saddr =3D src_ip;
> > >  	fl4.flowi4_oif =3D addr->bound_dev_if;
> > > -	rt =3D ip_route_output_key(&init_net, &fl4);
> > > +	rt =3D ip_route_output_key(addr->net, &fl4);
> > >  	if (IS_ERR(rt)) {
> > >  		ret =3D PTR_ERR(rt);
> > >  		goto out;
> > > @@ -278,12 +279,13 @@ static int addr6_resolve(struct sockaddr_in=
6
> > *src_in,
> > >  	fl6.saddr =3D src_in->sin6_addr;
> > >  	fl6.flowi6_oif =3D addr->bound_dev_if;
> > >
> > > -	dst =3D ip6_route_output(&init_net, NULL, &fl6);
> > > +	dst =3D ip6_route_output(addr->net, NULL, &fl6);
> > >  	if ((ret =3D dst->error))
> > >  		goto put;
> > >
> > >  	if (ipv6_addr_any(&fl6.saddr)) {
> > > -		ret =3D ipv6_dev_get_saddr(&init_net, ip6_dst_idev(dst)->dev,
> > > +		ret =3D ipv6_dev_get_saddr(addr->net,
> > > +					 ip6_dst_idev(dst)->dev,
> > >  					 &fl6.daddr, 0, &fl6.saddr);
> > >  		if (ret)
> > >  			goto put;
> > > @@ -458,7 +460,7 @@ static void resolve_cb(int status, struct soc=
kaddr
> > *src_addr,
> > >  }
> > >
> > >  int rdma_addr_find_dmac_by_grh(union ib_gid *sgid, union ib_gid
> > *dgid, u8 *dmac,
> > > -			       u16 *vlan_id)
> > > +			       u16 *vlan_id, struct net *net)
> > >  {
> > >  	int ret =3D 0;
> > >  	struct rdma_dev_addr dev_addr;
> > > @@ -481,6 +483,7 @@ int rdma_addr_find_dmac_by_grh(union ib_gid *=
sgid,
> > union ib_gid *dgid, u8 *dmac,
> > >  		return ret;
> > >
> > >  	memset(&dev_addr, 0, sizeof(dev_addr));
> > > +	dev_addr.net =3D net;
> >=20
> > Should be get_net() be used somewhere to grab a reference on the ne=
t
> > namespace ?
> >=20
>=20
> Not needed, as dev_addr.net is used only inside this function. Assumi=
ng that the caller guarantees that the network namespace doesn't disapp=
ear until the function returns, there is no need to take a reference he=
re. This kind of assumption makes sense, as otherwise we will not be ab=
le to use the argument at all.
>=20
> > >
> > >  	ctx.addr =3D &dev_addr;
> > >  	init_completion(&ctx.comp);
> > > @@ -492,7 +495,7 @@ int rdma_addr_find_dmac_by_grh(union ib_gid *=
sgid,
> > union ib_gid *dgid, u8 *dmac,
> > >  	wait_for_completion(&ctx.comp);
> > >
> > >  	memcpy(dmac, dev_addr.dst_dev_addr, ETH_ALEN);
> > > -	dev =3D dev_get_by_index(&init_net, dev_addr.bound_dev_if);
> > > +	dev =3D dev_get_by_index(net, dev_addr.bound_dev_if);
> > >  	if (!dev)
> > >  		return -ENODEV;
> > >  	if (vlan_id)
> > > @@ -502,7 +505,8 @@ int rdma_addr_find_dmac_by_grh(union ib_gid *=
sgid,
> > union ib_gid *dgid, u8 *dmac,
> > >  }
> > >  EXPORT_SYMBOL(rdma_addr_find_dmac_by_grh);
> > >
> > > -int rdma_addr_find_smac_by_sgid(union ib_gid *sgid, u8 *smac, u1=
6
> > *vlan_id)
> > > +int rdma_addr_find_smac_by_sgid(union ib_gid *sgid, u8 *smac, u1=
6
> > *vlan_id,
> > > +				struct net *net)
> > >  {
> > >  	int ret =3D 0;
> > >  	struct rdma_dev_addr dev_addr;
> > > @@ -517,6 +521,7 @@ int rdma_addr_find_smac_by_sgid(union ib_gid
> > *sgid, u8 *smac, u16 *vlan_id)
> > >  	if (ret)
> > >  		return ret;
> > >  	memset(&dev_addr, 0, sizeof(dev_addr));
> > > +	dev_addr.net =3D net;
> >=20
> > get_net() ?
> >=20
>=20
> Same as before - used only in the function, caller must make sure it =
doesn't disappear.
>=20
> > >  	ret =3D rdma_translate_ip(&gid_addr._sockaddr, &dev_addr, vlan_=
id);
> > >  	if (ret)
> > >  		return ret;
> > > diff --git a/drivers/infiniband/core/cma.c
> > b/drivers/infiniband/core/cma.c
> > > index 6e5e11ca7702..aeb2417ec928 100644
> > > --- a/drivers/infiniband/core/cma.c
> > > +++ b/drivers/infiniband/core/cma.c
> > > @@ -512,6 +512,7 @@ struct rdma_cm_id
> > *rdma_create_id(rdma_cm_event_handler event_handler,
> > >  	INIT_LIST_HEAD(&id_priv->listen_list);
> > >  	INIT_LIST_HEAD(&id_priv->mc_list);
> > >  	get_random_bytes(&id_priv->seq_num, sizeof id_priv->seq_num);
> > > +	id_priv->id.route.addr.dev_addr.net =3D &init_net;
> > >
> > >  	return &id_priv->id;
> > >  }
> > > @@ -637,7 +638,8 @@ static int cma_modify_qp_rtr(struct
> > rdma_id_private *id_priv,
> > >  	    =3D=3D RDMA_TRANSPORT_IB &&
> > >  	    rdma_port_get_link_layer(id_priv->id.device, id_priv-
> > >id.port_num)
> > >  	    =3D=3D IB_LINK_LAYER_ETHERNET) {
> > > -		ret =3D rdma_addr_find_smac_by_sgid(&sgid, qp_attr.smac, NULL)=
;
> > > +		ret =3D rdma_addr_find_smac_by_sgid(&sgid, qp_attr.smac, NULL,
> > > +						  &init_net);
> > >
> > >  		if (ret)
> > >  			goto out;
> > > diff --git a/drivers/infiniband/core/verbs.c
> > b/drivers/infiniband/core/verbs.c
> > > index f93eb8da7b5a..ca5c4dd8a67a 100644
> > > --- a/drivers/infiniband/core/verbs.c
> > > +++ b/drivers/infiniband/core/verbs.c
> > > @@ -212,7 +212,9 @@ int ib_init_ah_from_wc(struct ib_device *devi=
ce,
> > u8 port_num, struct ib_wc *wc,
> > >  			ah_attr->vlan_id =3D wc->vlan_id;
> > >  		} else {
> > >  			ret =3D rdma_addr_find_dmac_by_grh(&grh->dgid, &grh->sgid,
> > > -					ah_attr->dmac, &ah_attr->vlan_id);
> > > +							 ah_attr->dmac,
> > > +							 &ah_attr->vlan_id,
> > > +							 &init_net);
> > >  			if (ret)
> > >  				return ret;
> > >  		}
> > > @@ -882,11 +884,15 @@ int ib_resolve_eth_l2_attrs(struct ib_qp *q=
p,
> > >  			if (!(*qp_attr_mask & IB_QP_VID))
> > >  				qp_attr->vlan_id =3D rdma_get_vlan_id(&sgid);
> > >  		} else {
> > > -			ret =3D rdma_addr_find_dmac_by_grh(&sgid, &qp_attr-
> > >ah_attr.grh.dgid,
> > > -					qp_attr->ah_attr.dmac, &qp_attr->vlan_id);
> > > +			ret =3D rdma_addr_find_dmac_by_grh(
> > > +				&sgid,
> > > +				&qp_attr->ah_attr.grh.dgid,
> > > +				qp_attr->ah_attr.dmac, &qp_attr->vlan_id,
> > > +				&init_net);
> > >  			if (ret)
> > >  				goto out;
> > > -			ret =3D rdma_addr_find_smac_by_sgid(&sgid, qp_attr->smac,
> > NULL);
> > > +			ret =3D rdma_addr_find_smac_by_sgid(&sgid, qp_attr->smac,
> > > +							  NULL, &init_net);
> > >  			if (ret)
> > >  				goto out;
> > >  		}
> > > diff --git a/drivers/infiniband/hw/ocrdma/ocrdma_ah.c
> > b/drivers/infiniband/hw/ocrdma/ocrdma_ah.c
> > > index f3cc8c9e65ae..debaac2b6ee8 100644
> > > --- a/drivers/infiniband/hw/ocrdma/ocrdma_ah.c
> > > +++ b/drivers/infiniband/hw/ocrdma/ocrdma_ah.c
> > > @@ -119,7 +119,8 @@ struct ib_ah *ocrdma_create_ah(struct ib_pd *=
ibpd,
> > struct ib_ah_attr *attr)
> > >
> > >  	if (pd->uctx) {
> > >  		status =3D rdma_addr_find_dmac_by_grh(&sgid, &attr->grh.dgid,
> > > -                                        attr->dmac, &attr->vlan_=
id);
> > > +						    attr->dmac, &attr->vlan_id,
> > > +						    &init_net);
> > >  		if (status) {
> > >  			pr_err("%s(): Failed to resolve dmac from gid."
> > >  				"status =3D %d\n", __func__, status);
> > > diff --git a/include/rdma/ib_addr.h b/include/rdma/ib_addr.h
> > > index ce55906b54a0..40ccf8b83755 100644
> > > --- a/include/rdma/ib_addr.h
> > > +++ b/include/rdma/ib_addr.h
> > > @@ -47,6 +47,7 @@
> > >  #include <rdma/ib_verbs.h>
> > >  #include <rdma/ib_pack.h>
> > >  #include <net/ipv6.h>
> > > +#include <net/net_namespace.h>
> > >
> > >  struct rdma_addr_client {
> > >  	atomic_t refcount;
> > > @@ -64,6 +65,16 @@ void rdma_addr_register_client(struct
> > rdma_addr_client *client);
> > >   */
> > >  void rdma_addr_unregister_client(struct rdma_addr_client *client=
);
> > >
> > > +/**
> > > + * struct rdma_dev_addr - Contains resolved RDMA hardware addres=
ses
> > > + * @src_dev_addr:	Source MAC address.
> > > + * @dst_dev_addr:	Destination MAC address.
> > > + * @broadcast:		Broadcast address of the device.
> > > + * @dev_type:		The interface hardware type of the device.
> > > + * @bound_dev_if:	An optional device interface index.
> > > + * @transport:		The transport type used.
> > > + * @net:		Network namespace containing the bound_dev_if
> > net_dev.
> > > + */
> > >  struct rdma_dev_addr {
> > >  	unsigned char src_dev_addr[MAX_ADDR_LEN];
> > >  	unsigned char dst_dev_addr[MAX_ADDR_LEN];
> > > @@ -71,11 +82,14 @@ struct rdma_dev_addr {
> > >  	unsigned short dev_type;
> > >  	int bound_dev_if;
> > >  	enum rdma_transport_type transport;
> > > +	struct net *net;
> > >  };
> > >
> > >  /**
> > >   * rdma_translate_ip - Translate a local IP address to an RDMA
> > hardware
> > >   *   address.
> > > + *
> > > + * The dev_addr->net field must be initialized.
> > >   */
> > >  int rdma_translate_ip(struct sockaddr *addr, struct rdma_dev_add=
r
> > *dev_addr,
> > >  		      u16 *vlan_id);
> > > @@ -90,7 +104,7 @@ int rdma_translate_ip(struct sockaddr *addr, s=
truct
> > rdma_dev_addr *dev_addr,
> > >   * @dst_addr: The destination address to resolve.
> > >   * @addr: A reference to a data location that will receive the
> > resolved
> > >   *   addresses.  The data location must remain valid until the
> > callback has
> > > - *   been invoked.
> > > + *   been invoked. The net field of the addr struct must be vali=
d.
> > >   * @timeout_ms: Amount of time to wait for the address resolutio=
n to
> > complete.
> > >   * @callback: Call invoked once address resolution has completed=
,
> > timed out,
> > >   *   or been canceled.  A status of 0 indicates success.
> > > @@ -110,9 +124,29 @@ int rdma_copy_addr(struct rdma_dev_addr
> > *dev_addr, struct net_device *dev,
> > >
> > >  int rdma_addr_size(struct sockaddr *addr);
> > >
> > > -int rdma_addr_find_smac_by_sgid(union ib_gid *sgid, u8 *smac, u1=
6
> > *vlan_id);
> > > -int rdma_addr_find_dmac_by_grh(union ib_gid *sgid, union ib_gid
> > *dgid, u8 *smac,
> > > -			       u16 *vlan_id);
> > > +/** rdma_addr_find_smac_by_sgid() - Find the src MAC and VLAN ID=
 for
> > a src GID
> > > + * @sgid:	Source GID to find the MAC and VLAN for.
> > > + * @smac:	A buffer to contain the resulting MAC address.
> > > + * @vlan_id:	Will contain the resulting VLAN ID.
> > > + * @net:	Network namespace to use for the address resolution.
> > > + *
> > > + * It is the caller's responsibility to keep the network namespa=
ce
> > alive until
> > > + * the function returns.
> >=20
> > Why ?
> >=20
>=20
> So that we could use the argument. Otherwise, we will need to have ug=
ly code like:
> ------------------------
> struct net *local_net =3D NULL;
> rcu_read_lock();
> for_each_net_rcu(local_net)
> 	if (local_net =3D=3D net)
> 		break;
> if (local_net =3D=3D net)
> 	get_net(local_net);
> else
> 	local_net =3D NULL;
> rcu_read_unlock();
> ------------------------
> however, the callers (in following patches), can easily ensure that t=
he network namespace is here to stay. This is much easier to understand=
 and maintain.
>=20
>=20
> > > + */
> > > +int rdma_addr_find_smac_by_sgid(union ib_gid *sgid, u8 *smac, u1=
6
> > *vlan_id,
> > > +				struct net *net);
> > > +/** rdma_addr_find_dmac_by_grh() - Find the dst MAC and VLAN ID =
for a
> > GID pair
> > > + * @sgid:	Source GID to use for the search.
> > > + * @dgid:	Destination GID to find the details for.
> > > + * @dmac:	Contains the resulting destination MAC address.
> > > + * @vlan_id:	Contains the resulting VLAN ID.
> > > + * @net:	Network namespace to use for the address resolution.
> > > + *
> > > + * It is the caller's responsibility to keep the network namespa=
ce
> > alive until
> > > + * the function returns.
> >=20
> > Why ?
> >=20
>=20
> See above.
>=20
> >=20
> >=20
> > I believe this patch lack proper reference counting in form of
> > get_net() / put_net(), but cannot say for sure.
> >=20
>=20
> If you could point to specific issues or race conditions, that would =
be great.
> We have thoroughly tested and reviewed the code, and couldn't find an=
y such issues with the submitted patches.
>=20

OK, that's enough for me: I was just concerned about the various=20
references that were copied to data structure inside the functions
and the functions were asking for the caller to manage the reference
for them, which seems wrong.

So I think the messages "It is the caller's responsibility to keep the
network namespace alive until the function returns" are obvious,
and could be removed.

Regards.

--=20
Yann Droneaud
OPTEYA



--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
