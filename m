From: Razvan Stefanescu <razvan.stefanescu@nxp.com>
Subject: RE: [RESEND PATCH 2/6] staging: fsl-dpaa2/ethsw: Add Freescale DPAA2
 Ethernet Switch driver
Date: Fri, 29 Sep 2017 13:59:18 +0000
Message-ID: <AM3PR04MB0743F62497ED0CB445F51524E67E0@AM3PR04MB0743.eurprd04.prod.outlook.com>
References: <1505825158-8192-1-git-send-email-razvan.stefanescu@nxp.com>
 <1505825158-8192-3-git-send-email-razvan.stefanescu@nxp.com>
 <DB5PR04MB12400025DF190790B4792B50EA7E0@DB5PR04MB1240.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "agraf@suse.de" <agraf@suse.de>, "arnd@arndb.de" <arnd@arndb.de>,
        Alexandru Marginean <alexandru.marginean@nxp.com>,
        Ruxandra Ioana Radulescu <ruxandra.radulescu@nxp.com>,
        Laurentiu Tudor <laurentiu.tudor@nxp.com>,
        "stuyoder@gmail.com" <stuyoder@gmail.com>
To: Bogdan Purcareata <bogdan.purcareata@nxp.com>,
        "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <DB5PR04MB12400025DF190790B4792B50EA7E0@DB5PR04MB1240.eurprd04.prod.outlook.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Bogdan Purcareata
> Sent: Friday, September 29, 2017 16:36
> To: Razvan Stefanescu <razvan.stefanescu@nxp.com>;
> gregkh@linuxfoundation.org
> Cc: devel@driverdev.osuosl.org; linux-kernel@vger.kernel.org;
> netdev@vger.kernel.org; agraf@suse.de; arnd@arndb.de; Alexandru Marginean
> <alexandru.marginean@nxp.com>; Ruxandra Ioana Radulescu
> <ruxandra.radulescu@nxp.com>; Laurentiu Tudor <laurentiu.tudor@nxp.com>;
> stuyoder@gmail.com
> Subject: RE: [RESEND PATCH 2/6] staging: fsl-dpaa2/ethsw: Add Freescale D=
PAA2
> Ethernet Switch driver
>=20
> > Introduce the DPAA2 Ethernet Switch driver, which manages Datapath Swit=
ch
> > (DPSW) objects discovered on the MC bus.
> >
> > Suggested-by: Alexandru Marginean <alexandru.marginean@nxp.com>
> > Signed-off-by: Razvan Stefanescu <razvan.stefanescu@nxp.com>
> > ---
> >  drivers/staging/fsl-dpaa2/ethsw/Makefile |    2 +-
> >  drivers/staging/fsl-dpaa2/ethsw/ethsw.c  | 1523
> ++++++++++++++++++++++++++++++
> >  drivers/staging/fsl-dpaa2/ethsw/ethsw.h  |   88 ++
> >  3 files changed, 1612 insertions(+), 1 deletion(-)
> >  create mode 100644 drivers/staging/fsl-dpaa2/ethsw/ethsw.c
> >  create mode 100644 drivers/staging/fsl-dpaa2/ethsw/ethsw.h
> >
> > diff --git a/drivers/staging/fsl-dpaa2/ethsw/Makefile b/drivers/staging=
/fsl-
> > dpaa2/ethsw/Makefile
> > index db137f7..a6d72d1 100644
> > --- a/drivers/staging/fsl-dpaa2/ethsw/Makefile
> > +++ b/drivers/staging/fsl-dpaa2/ethsw/Makefile
> > @@ -4,4 +4,4 @@
> >
> >  obj-$(CONFIG_FSL_DPAA2_ETHSW) +=3D dpaa2-ethsw.o
> >
> > -dpaa2-ethsw-objs :=3D dpsw.o
> > +dpaa2-ethsw-objs :=3D ethsw.o dpsw.o
> > diff --git a/drivers/staging/fsl-dpaa2/ethsw/ethsw.c b/drivers/staging/=
fsl-
> > dpaa2/ethsw/ethsw.c
> > new file mode 100644
> > index 0000000..ae86078
> > --- /dev/null
> > +++ b/drivers/staging/fsl-dpaa2/ethsw/ethsw.c
> > @@ -0,0 +1,1523 @@
> > +/* Copyright 2014-2016 Freescale Semiconductor Inc.
> > + * Copyright 2017 NXP
> > + *
> > + * Redistribution and use in source and binary forms, with or without
> > + * modification, are permitted provided that the following conditions =
are met:
> > + *     * Redistributions of source code must retain the above copyrigh=
t
> > + *	 notice, this list of conditions and the following disclaimer.
> > + *     * Redistributions in binary form must reproduce the above copyr=
ight
> > + *	 notice, this list of conditions and the following disclaimer in th=
e
> > + *	 documentation and/or other materials provided with the distributio=
n.
> > + *     * Neither the name of the above-listed copyright holders nor th=
e
> > + *	 names of any contributors may be used to endorse or promote produc=
ts
> > + *	 derived from this software without specific prior written permissi=
on.
> > + *
> > + *
> > + * ALTERNATIVELY, this software may be distributed under the terms of =
the
> > + * GNU General Public License ("GPL") as published by the Free Softwar=
e
> > + * Foundation, either version 2 of that License or (at your option) an=
y
> > + * later version.
> > + *
> > + * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
> CONTRIBUTORS "AS IS"
> > + * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
> LIMITED TO, THE
> > + * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
> PARTICULAR PURPOSE
> > + * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR
> CONTRIBUTORS BE
> > + * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
> > + * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
> PROCUREMENT OF
> > + * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
> BUSINESS
> > + * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
> WHETHER IN
> > + * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
> OTHERWISE)
> > + * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
> ADVISED OF THE
> > + * POSSIBILITY OF SUCH DAMAGE.
> > + */
> > +
> > +#include <linux/module.h>
> > +
> > +#include <linux/interrupt.h>
> > +#include <linux/msi.h>
> > +#include <linux/kthread.h>
> > +#include <linux/workqueue.h>
> > +
> > +#include "../../fsl-mc/include/mc.h"
> > +
> > +#include "ethsw.h"
> > +
> > +static struct workqueue_struct *ethsw_owq;
> > +
> > +/* Minimal supported DPSW version */
> > +#define DPSW_MIN_VER_MAJOR		8
> > +#define DPSW_MIN_VER_MINOR		0
> > +
> > +#define DEFAULT_VLAN_ID			1
> > +
> > +static int ethsw_add_vlan(struct ethsw_core *ethsw, u16 vid)
> > +{
> > +	int err;
> > +
> > +	struct dpsw_vlan_cfg	vcfg =3D {
> > +		.fdb_id =3D 0,
> > +	};
> > +
> > +	if (ethsw->vlans[vid]) {
> > +		dev_err(ethsw->dev, "VLAN already configured\n");
> > +		return -EEXIST;
> > +	}
> > +
> > +	err =3D dpsw_vlan_add(ethsw->mc_io, 0,
> > +			    ethsw->dpsw_handle, vid, &vcfg);
> > +	if (err) {
> > +		dev_err(ethsw->dev, "dpsw_vlan_add err %d\n", err);
> > +		return err;
> > +	}
> > +	ethsw->vlans[vid] =3D ETHSW_VLAN_MEMBER;/
> > +
> > +	return 0;
> > +}
> > +
> > +static int ethsw_port_add_vlan(struct ethsw_port_priv *port_priv,
> > +			       u16 vid, u16 flags)
> > +{
> > +	struct ethsw_core *ethsw =3D port_priv->ethsw_data;
> > +	struct net_device *netdev =3D port_priv->netdev;
> > +	struct dpsw_vlan_if_cfg vcfg;
> > +	bool is_oper;
> > +	int err, err2;
>=20
> Mild suggestion - s/err2/ret/, just because it sounds better, at least to=
 me (same
> for similar situations in the rest of the file).
>=20
Thank you for your suggestion. I will make the change and send v2.
> > +
> > +	if (port_priv->vlans[vid]) {
> > +		netdev_warn(netdev, "VLAN %d already configured\n", vid);
> > +		return -EEXIST;
> > +	}
> > +
> > +	vcfg.num_ifs =3D 1;
> > +	vcfg.if_id[0] =3D port_priv->idx;
> > +	err =3D dpsw_vlan_add_if(ethsw->mc_io, 0, ethsw->dpsw_handle, vid,
> &vcfg);
> > +	if (err) {
> > +		netdev_err(netdev, "dpsw_vlan_add_if err %d\n", err);
> > +		return err;
> > +	}
> > +
> > +	port_priv->vlans[vid] =3D ETHSW_VLAN_MEMBER;
> > +
> > +	if (flags & BRIDGE_VLAN_INFO_UNTAGGED) {
> > +		err =3D dpsw_vlan_add_if_untagged(ethsw->mc_io, 0,
> > +						ethsw->dpsw_handle,
> > +						vid, &vcfg);
> > +		if (err) {
> > +			netdev_err(netdev,
> > +				   "dpsw_vlan_add_if_untagged err %d\n", err);
> > +			return err;
> > +		}
> > +		port_priv->vlans[vid] |=3D ETHSW_VLAN_UNTAGGED;
> > +	}
> > +
> > +	if (flags & BRIDGE_VLAN_INFO_PVID) {
> > +		struct dpsw_tci_cfg tci_cfg =3D {
> > +			.pcp =3D 0,
> > +			.dei =3D 0,
> > +			.vlan_id =3D vid,
> > +		};
> > +
> > +		/* Interface needs to be down to change PVID */
> > +		is_oper =3D netif_oper_up(netdev);
> > +		if (is_oper) {
> > +			err =3D dpsw_if_disable(ethsw->mc_io, 0,
> > +					      ethsw->dpsw_handle,
> > +					      port_priv->idx);
> > +			if (err) {
> > +				netdev_err(netdev,
> > +					   "dpsw_if_disable err %d\n", err);
> > +				return err;
> > +			}
> > +		}
> > +
> > +		err =3D dpsw_if_set_tci(ethsw->mc_io, 0, ethsw->dpsw_handle,
> > +				      port_priv->idx, &tci_cfg);
> > +		if (!err) {
> > +			/* Delete previous PVID info and mark the new one */
> > +			if (port_priv->pvid)
> > +				port_priv->vlans[port_priv->pvid]
> > +						 ^=3D ETHSW_VLAN_PVID;
>=20
> Can it be " &=3D ~ETHSW_VLAN_PVID" ? Are there other implications?
>=20
You are right. Flag must be un-set. Will update in v2, along with the other=
 observations.
Thank you,
Razvan S.
> > +
> > +			port_priv->vlans[vid] |=3D ETHSW_VLAN_PVID;
> > +			port_priv->pvid =3D vid;
> > +		} else {
> > +			netdev_err(netdev, "dpsw_if_set_tci err %d\n", err);
> > +		}
> > +
> > +		if (is_oper) {
> > +			err2 =3D dpsw_if_enable(ethsw->mc_io, 0,
> > +					      ethsw->dpsw_handle,
> > +					      port_priv->idx);
> > +			if (err2) {
> > +				netdev_err(netdev,
> > +					   "dpsw_if_enable err %d\n", err2);
> > +				return err2;
> > +			}
> > +		}
> > +	}
> > +
> > +	return err;
> > +}
> > +
> > +static int ethsw_set_learning(struct ethsw_core *ethsw, u8 flag)
> > +{
> > +	enum dpsw_fdb_learning_mode learn_mode;
> > +	int err;
> > +
> > +	if (flag)
> > +		learn_mode =3D DPSW_FDB_LEARNING_MODE_HW;
> > +	else
> > +		learn_mode =3D DPSW_FDB_LEARNING_MODE_DIS;
> > +
> > +	err =3D dpsw_fdb_set_learning_mode(ethsw->mc_io, 0, ethsw-
> >dpsw_handle, 0,
> > +					 learn_mode);
> > +	if (err) {
> > +		dev_err(ethsw->dev, "dpsw_fdb_set_learning_mode err %d\n",
> err);
> > +		return err;
> > +	}
> > +	ethsw->learning =3D !!flag;
> > +
> > +	return 0;
> > +}
> > +
> > +static int ethsw_port_set_flood(struct ethsw_port_priv *port_priv, u8 =
flag)
> > +{
> > +	int err;
> > +
> > +	err =3D dpsw_if_set_flooding(port_priv->ethsw_data->mc_io, 0,
> > +				   port_priv->ethsw_data->dpsw_handle,
> > +				   port_priv->idx, (int)flag);
>=20
> Why is this cast necessary? Can't the API be reworked to use u8 (or, bett=
er yet,
> bool) instead of int?
>=20
> > +	if (err) {
> > +		netdev_err(port_priv->netdev,
> > +			   "dpsw_fdb_set_learning_mode err %d\n", err);
> > +		return err;
> > +	}
> > +	port_priv->flood =3D !!flag;
> > +
> > +	return 0;
> > +}
> > +
> > +static int ethsw_port_set_stp_state(struct ethsw_port_priv *port_priv,=
 u8
> > state)
> > +{
> > +	struct dpsw_stp_cfg stp_cfg =3D {
> > +		.vlan_id =3D DEFAULT_VLAN_ID,
> > +		.state =3D state,
> > +	};
> > +	int err;
> > +
> > +	if (!netif_oper_up(port_priv->netdev) || state =3D=3D port_priv->stp_=
state)
> > +		return 0;	/* Nothing to do */
> > +
> > +	err =3D dpsw_if_set_stp(port_priv->ethsw_data->mc_io, 0,
> > +			      port_priv->ethsw_data->dpsw_handle,
> > +			      port_priv->idx, &stp_cfg);
> > +	if (err) {
> > +		netdev_err(port_priv->netdev,
> > +			   "dpsw_if_set_stp err %d\n", err);
> > +		return err;
> > +	}
> > +
> > +	port_priv->stp_state =3D state;
> > +
> > +	return 0;
> > +}
> > +
> > +static int ethsw_dellink_switch(struct ethsw_core *ethsw, u16 vid)
> > +{
> > +	struct ethsw_port_priv *ppriv_local =3D NULL;
> > +	int i, err;
> > +
> > +	if (!ethsw->vlans[vid])
> > +		return -ENOENT;
> > +
> > +	err =3D dpsw_vlan_remove(ethsw->mc_io, 0, ethsw->dpsw_handle, vid);
> > +	if (err) {
> > +		dev_err(ethsw->dev, "dpsw_vlan_remove err %d\n", err);
> > +		return err;
> > +	}
> > +	ethsw->vlans[vid] =3D 0;
> > +
> > +	for (i =3D 0; i < ethsw->sw_attr.num_ifs; i++) {
> > +		ppriv_local =3D ethsw->ports[i];
> > +		ppriv_local->vlans[vid] =3D 0;
> > +	}
> > +
> > +	return 0;
> > +}
> > +
> > +static int ethsw_port_fdb_add_uc(struct ethsw_port_priv *port_priv,
> > +				 const unsigned char *addr)
> > +{
> > +	struct dpsw_fdb_unicast_cfg entry =3D {0};
> > +	int err;
> > +
> > +	entry.if_egress =3D port_priv->idx;
> > +	entry.type =3D DPSW_FDB_ENTRY_STATIC;
> > +	ether_addr_copy(entry.mac_addr, addr);
> > +
> > +	err =3D dpsw_fdb_add_unicast(port_priv->ethsw_data->mc_io, 0,
> > +				   port_priv->ethsw_data->dpsw_handle,
> > +				   0, &entry);
> > +	if (err)
> > +		netdev_err(port_priv->netdev,
> > +			   "dpsw_fdb_add_unicast err %d\n", err);
> > +	return err;
> > +}
> > +
> > +static int ethsw_port_fdb_del_uc(struct ethsw_port_priv *port_priv,
> > +				 const unsigned char *addr)
> > +{
> > +	struct dpsw_fdb_unicast_cfg entry =3D {0};
> > +	int err;
> > +
> > +	entry.if_egress =3D port_priv->idx;
> > +	entry.type =3D DPSW_FDB_ENTRY_STATIC;
> > +	ether_addr_copy(entry.mac_addr, addr);
> > +
> > +	err =3D dpsw_fdb_remove_unicast(port_priv->ethsw_data->mc_io, 0,
> > +				      port_priv->ethsw_data->dpsw_handle,
> > +				      0, &entry);
> > +	if (err)
> > +		netdev_err(port_priv->netdev,
> > +			   "dpsw_fdb_remove_unicast err %d\n", err);
> > +	return err;
> > +}
> > +
> > +static int ethsw_port_fdb_add_mc(struct ethsw_port_priv *port_priv,
> > +				 const unsigned char *addr)
> > +{
> > +	struct dpsw_fdb_multicast_cfg entry =3D {0};
> > +	int err;
> > +
> > +	ether_addr_copy(entry.mac_addr, addr);
> > +	entry.type =3D DPSW_FDB_ENTRY_STATIC;
> > +	entry.num_ifs =3D 1;
> > +	entry.if_id[0] =3D port_priv->idx;
> > +
> > +	err =3D dpsw_fdb_add_multicast(port_priv->ethsw_data->mc_io, 0,
> > +				     port_priv->ethsw_data->dpsw_handle,
> > +				     0, &entry);
> > +	if (err)
> > +		netdev_err(port_priv->netdev, "dpsw_fdb_add_multicast err
> %d\n",
> > +			   err);
> > +	return err;
> > +}
> > +
> > +static int ethsw_port_fdb_del_mc(struct ethsw_port_priv *port_priv,
> > +				 const unsigned char *addr)
> > +{
> > +	struct dpsw_fdb_multicast_cfg entry =3D {0};
> > +	int err;
> > +
> > +	ether_addr_copy(entry.mac_addr, addr);
> > +	entry.type =3D DPSW_FDB_ENTRY_STATIC;
> > +	entry.num_ifs =3D 1;
> > +	entry.if_id[0] =3D port_priv->idx;
> > +
> > +	err =3D dpsw_fdb_remove_multicast(port_priv->ethsw_data->mc_io, 0,
> > +					port_priv->ethsw_data->dpsw_handle,
> > +					0, &entry);
> > +	if (err)
> > +		netdev_err(port_priv->netdev,
> > +			   "dpsw_fdb_remove_multicast err %d\n", err);
> > +	return err;
> > +}
> > +
> > +static void port_get_stats(struct net_device *netdev,
> > +			   struct rtnl_link_stats64 *stats)
> > +{
> > +	struct ethsw_port_priv *port_priv =3D netdev_priv(netdev);
> > +	u64 tmp;
> > +	int err;
> > +
> > +	err =3D dpsw_if_get_counter(port_priv->ethsw_data->mc_io, 0,
> > +				  port_priv->ethsw_data->dpsw_handle,
> > +				  port_priv->idx,
> > +				  DPSW_CNT_ING_FRAME, &stats->rx_packets);
> > +	if (err)
> > +		goto error;
> > +
> > +	err =3D dpsw_if_get_counter(port_priv->ethsw_data->mc_io, 0,
> > +				  port_priv->ethsw_data->dpsw_handle,
> > +				  port_priv->idx,
> > +				  DPSW_CNT_EGR_FRAME, &stats->tx_packets);
> > +	if (err)
> > +		goto error;
> > +
> > +	err =3D dpsw_if_get_counter(port_priv->ethsw_data->mc_io, 0,
> > +				  port_priv->ethsw_data->dpsw_handle,
> > +				  port_priv->idx,
> > +				  DPSW_CNT_ING_BYTE, &stats->rx_bytes);
> > +	if (err)
> > +		goto error;
> > +
> > +	err =3D dpsw_if_get_counter(port_priv->ethsw_data->mc_io, 0,
> > +				  port_priv->ethsw_data->dpsw_handle,
> > +				  port_priv->idx,
> > +				  DPSW_CNT_EGR_BYTE, &stats->tx_bytes);
> > +	if (err)
> > +		goto error;
> > +
> > +	err =3D dpsw_if_get_counter(port_priv->ethsw_data->mc_io, 0,
> > +				  port_priv->ethsw_data->dpsw_handle,
> > +				  port_priv->idx,
> > +				  DPSW_CNT_ING_FRAME_DISCARD,
> > +				  &stats->rx_dropped);
> > +	if (err)
> > +		goto error;
> > +
> > +	err =3D dpsw_if_get_counter(port_priv->ethsw_data->mc_io, 0,
> > +				  port_priv->ethsw_data->dpsw_handle,
> > +				  port_priv->idx,
> > +				  DPSW_CNT_ING_FLTR_FRAME,
> > +				  &tmp);
> > +	if (err)
> > +		goto error;
> > +	stats->rx_dropped +=3D tmp;
> > +
> > +	err =3D dpsw_if_get_counter(port_priv->ethsw_data->mc_io, 0,
> > +				  port_priv->ethsw_data->dpsw_handle,
> > +				  port_priv->idx,
> > +				  DPSW_CNT_EGR_FRAME_DISCARD,
> > +				  &stats->tx_dropped);
> > +	if (err)
> > +		goto error;
> > +
> > +	return;
> > +
> > +error:
> > +	netdev_err(netdev, "dpsw_if_get_counter err %d\n", err);
> > +}
> > +
> > +static bool port_has_offload_stats(const struct net_device *netdev,
> > +				   int attr_id)
> > +{
> > +	return (attr_id =3D=3D IFLA_OFFLOAD_XSTATS_CPU_HIT);
> > +}
> > +
> > +static int port_get_offload_stats(int attr_id,
> > +				  const struct net_device *netdev,
> > +				  void *sp)
> > +{
> > +	switch (attr_id) {
> > +	case IFLA_OFFLOAD_XSTATS_CPU_HIT:
> > +		port_get_stats((struct net_device *)netdev, sp);
> > +		return 0;
> > +	}
> > +
> > +	return -EINVAL;
> > +}
> > +
> > +static int port_change_mtu(struct net_device *netdev, int mtu)
> > +{
> > +	struct ethsw_port_priv *port_priv =3D netdev_priv(netdev);
> > +	int err;
> > +
> > +	err =3D dpsw_if_set_max_frame_length(port_priv->ethsw_data->mc_io,
> > +					   0,
> > +					   port_priv->ethsw_data->dpsw_handle,
> > +					   port_priv->idx,
> > +					   (u16)ETHSW_L2_MAX_FRM(mtu));
> > +	if (err) {
> > +		netdev_err(netdev,
> > +			   "dpsw_if_set_max_frame_length() err %d\n", err);
> > +		return err;
> > +	}
> > +
> > +	netdev->mtu =3D mtu;
> > +	return 0;
> > +}
> > +
> > +static int port_carrier_state_sync(struct net_device *netdev)
> > +{
> > +	struct ethsw_port_priv *port_priv =3D netdev_priv(netdev);
> > +	struct dpsw_link_state state;
> > +	int err;
> > +
> > +	err =3D dpsw_if_get_link_state(port_priv->ethsw_data->mc_io, 0,
> > +				     port_priv->ethsw_data->dpsw_handle,
> > +				     port_priv->idx, &state);
> > +	if (err) {
> > +		netdev_err(netdev, "dpsw_if_get_link_state() err %d\n", err);
> > +		return err;
> > +	}
> > +
> > +	WARN_ONCE(state.up > 1, "Garbage read into link_state");
> > +
> > +	if (state.up !=3D port_priv->link_state) {
> > +		if (state.up)
> > +			netif_carrier_on(netdev);
> > +		else
> > +			netif_carrier_off(netdev);
> > +		port_priv->link_state =3D state.up;
> > +	}
> > +	return 0;
> > +}
> > +
> > +static int port_open(struct net_device *netdev)
> > +{
> > +	struct ethsw_port_priv *port_priv =3D netdev_priv(netdev);
> > +	int err;
> > +
> > +	/* No need to allow Tx as control interface is disabled */
> > +	netif_tx_stop_all_queues(netdev);
> > +
> > +	err =3D dpsw_if_enable(port_priv->ethsw_data->mc_io, 0,
> > +			     port_priv->ethsw_data->dpsw_handle,
> > +			     port_priv->idx);
> > +	if (err) {
> > +		netdev_err(netdev, "dpsw_if_enable err %d\n", err);
> > +		return err;
> > +	}
> > +
> > +	/* sync carrier state */
> > +	err =3D port_carrier_state_sync(netdev);
> > +	if (err) {
> > +		netdev_err(netdev,
> > +			   "port_carrier_state_sync err %d\n", err);
> > +		goto err_carrier_sync;
> > +	}
> > +
> > +	return 0;
> > +
> > +err_carrier_sync:
> > +	dpsw_if_disable(port_priv->ethsw_data->mc_io, 0,
> > +			port_priv->ethsw_data->dpsw_handle,
> > +			port_priv->idx);
> > +	return err;
> > +}
> > +
> > +static int port_stop(struct net_device *netdev)
> > +{
> > +	struct ethsw_port_priv *port_priv =3D netdev_priv(netdev);
> > +	int err;
> > +
> > +	err =3D dpsw_if_disable(port_priv->ethsw_data->mc_io, 0,
> > +			      port_priv->ethsw_data->dpsw_handle,
> > +			      port_priv->idx);
> > +	if (err) {
> > +		netdev_err(netdev, "dpsw_if_disable err %d\n", err);
> > +		return err;
> > +	}
> > +
> > +	return 0;
> > +}
> > +
> > +static netdev_tx_t port_dropframe(struct sk_buff *skb,
> > +				  struct net_device *netdev)
> > +{
> > +	/* we don't support I/O for now, drop the frame */
> > +	dev_kfree_skb_any(skb);
> > +
> > +	return NETDEV_TX_OK;
> > +}
> > +
> > +static const struct net_device_ops ethsw_port_ops =3D {
> > +	.ndo_open		=3D port_open,
> > +	.ndo_stop		=3D port_stop,
> > +
> > +	.ndo_set_mac_address	=3D eth_mac_addr,
> > +	.ndo_change_mtu		=3D port_change_mtu,
> > +	.ndo_has_offload_stats	=3D port_has_offload_stats,
> > +	.ndo_get_offload_stats	=3D port_get_offload_stats,
> > +
> > +	.ndo_start_xmit		=3D port_dropframe,
> > +};
> > +
> > +static void ethsw_links_state_update(struct ethsw_core *ethsw)
> > +{
> > +	int i;
> > +
> > +	for (i =3D 0; i < ethsw->sw_attr.num_ifs; i++)
> > +		port_carrier_state_sync(ethsw->ports[i]->netdev);
> > +}
> > +
> > +static irqreturn_t ethsw_irq0_handler(int irq_num, void *arg)
> > +{
> > +	return IRQ_WAKE_THREAD;
> > +}
> > +
> > +static irqreturn_t ethsw_irq0_handler_thread(int irq_num, void *arg)
> > +{
> > +	struct device *dev =3D (struct device *)arg;
> > +	struct ethsw_core *ethsw =3D dev_get_drvdata(dev);
> > +
> > +	/* Mask the events and the if_id reserved bits to be cleared on read =
*/
> > +	u32 status =3D DPSW_IRQ_EVENT_LINK_CHANGED | 0xFFFF0000;
> > +	int err;
> > +
> > +	err =3D dpsw_get_irq_status(ethsw->mc_io, 0, ethsw->dpsw_handle,
> > +				  DPSW_IRQ_INDEX_IF, &status);
> > +	if (err) {
> > +		dev_err(dev, "Can't get irq status (err %d)", err);
> > +
> > +		err =3D dpsw_clear_irq_status(ethsw->mc_io, 0, ethsw-
> >dpsw_handle,
> > +					    DPSW_IRQ_INDEX_IF, 0xFFFFFFFF);
> > +		if (err)
> > +			dev_err(dev, "Can't clear irq status (err %d)", err);
> > +		goto out;
> > +	}
> > +
> > +	if (status & DPSW_IRQ_EVENT_LINK_CHANGED)
> > +		ethsw_links_state_update(ethsw);
> > +
> > +out:
> > +	return IRQ_HANDLED;
> > +}
> > +
> > +static int ethsw_setup_irqs(struct fsl_mc_device *sw_dev)
> > +{
> > +	struct device *dev =3D &sw_dev->dev;
> > +	struct ethsw_core *ethsw =3D dev_get_drvdata(dev);
> > +	u32 mask =3D DPSW_IRQ_EVENT_LINK_CHANGED;
> > +	struct fsl_mc_device_irq *irq;
> > +	int err;
> > +
> > +	err =3D fsl_mc_allocate_irqs(sw_dev);
> > +	if (err) {
> > +		dev_err(dev, "MC irqs allocation failed\n");
> > +		return err;
> > +	}
> > +
> > +	if (WARN_ON(sw_dev->obj_desc.irq_count !=3D DPSW_IRQ_NUM)) {
> > +		err =3D -EINVAL;
> > +		goto free_irq;
> > +	}
> > +
> > +	err =3D dpsw_set_irq_enable(ethsw->mc_io, 0, ethsw->dpsw_handle,
> > +				  DPSW_IRQ_INDEX_IF, 0);
> > +	if (err) {
> > +		dev_err(dev, "dpsw_set_irq_enable err %d\n", err);
> > +		goto free_irq;
> > +	}
> > +
> > +	irq =3D sw_dev->irqs[DPSW_IRQ_INDEX_IF];
> > +
> > +	err =3D devm_request_threaded_irq(dev, irq->msi_desc->irq,
> > +					ethsw_irq0_handler,
> > +					ethsw_irq0_handler_thread,
> > +					IRQF_NO_SUSPEND | IRQF_ONESHOT,
> > +					dev_name(dev), dev);
> > +	if (err) {
> > +		dev_err(dev, "devm_request_threaded_irq(): %d", err);
> > +		goto free_irq;
> > +	}
> > +
> > +	err =3D dpsw_set_irq_mask(ethsw->mc_io, 0, ethsw->dpsw_handle,
> > +				DPSW_IRQ_INDEX_IF, mask);
> > +	if (err) {
> > +		dev_err(dev, "dpsw_set_irq_mask(): %d", err);
> > +		goto free_devm_irq;
> > +	}
> > +
> > +	err =3D dpsw_set_irq_enable(ethsw->mc_io, 0, ethsw->dpsw_handle,
> > +				  DPSW_IRQ_INDEX_IF, 1);
> > +	if (err) {
> > +		dev_err(dev, "dpsw_set_irq_enable(): %d", err);
> > +		goto free_devm_irq;
> > +	}
> > +
> > +	return 0;
> > +
> > +free_devm_irq:
> > +	devm_free_irq(dev, irq->msi_desc->irq, dev);
> > +free_irq:
> > +	fsl_mc_free_irqs(sw_dev);
> > +	return err;
> > +}
> > +
> > +static void ethsw_teardown_irqs(struct fsl_mc_device *sw_dev)
> > +{
> > +	struct device *dev =3D &sw_dev->dev;
> > +	struct ethsw_core *ethsw =3D dev_get_drvdata(dev);
> > +	struct fsl_mc_device_irq *irq;
> > +
> > +	irq =3D sw_dev->irqs[DPSW_IRQ_INDEX_IF];
> > +	dpsw_set_irq_enable(ethsw->mc_io, 0, ethsw->dpsw_handle,
> > +			    DPSW_IRQ_INDEX_IF, 0);
>=20
> You can still print an error message here, in case something goes wrong.
>=20
> > +	fsl_mc_free_irqs(sw_dev);
> > +}
> > +
> > +static int swdev_port_attr_get(struct net_device *netdev,
> > +			       struct switchdev_attr *attr)
> > +{
> > +	struct ethsw_port_priv *port_priv =3D netdev_priv(netdev);
> > +
> > +	switch (attr->id) {
> > +	case SWITCHDEV_ATTR_ID_PORT_PARENT_ID:
> > +		attr->u.ppid.id_len =3D 1;
> > +		attr->u.ppid.id[0] =3D port_priv->ethsw_data->dev_id;
> > +		break;
> > +	case SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS:
> > +		attr->u.brport_flags =3D
> > +			(port_priv->ethsw_data->learning ? BR_LEARNING : 0) |
> > +			(port_priv->flood ? BR_FLOOD : 0);
> > +		break;
> > +	case SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS_SUPPORT:
> > +		attr->u.brport_flags_support =3D BR_LEARNING | BR_FLOOD;
> > +		break;
> > +	default:
> > +		return -EOPNOTSUPP;
> > +	}
> > +
> > +	return 0;
> > +}
> > +
> > +static int port_attr_stp_state_set(struct net_device *netdev,
> > +				   struct switchdev_trans *trans,
> > +				   u8 state)
> > +{
> > +	struct ethsw_port_priv *port_priv =3D netdev_priv(netdev);
> > +
> > +	if (switchdev_trans_ph_prepare(trans))
> > +		return 0;
> > +
> > +	return ethsw_port_set_stp_state(port_priv, state);
> > +}
> > +
> > +static int port_attr_br_flags_set(struct net_device *netdev,
> > +				  struct switchdev_trans *trans,
> > +				  unsigned long flags)
> > +{
> > +	struct ethsw_port_priv *port_priv =3D netdev_priv(netdev);
> > +	int err =3D 0;
> > +
> > +	if (switchdev_trans_ph_prepare(trans))
> > +		return 0;
> > +
> > +	/* Learning is enabled per switch */
> > +	err =3D ethsw_set_learning(port_priv->ethsw_data, flags &
> BR_LEARNING);
> > +	if (err)
> > +		goto exit;
> > +
> > +	err =3D ethsw_port_set_flood(port_priv, flags & BR_FLOOD);
> > +
> > +exit:
> > +	return err;
> > +}
> > +
> > +static int swdev_port_attr_set(struct net_device *netdev,
> > +			       const struct switchdev_attr *attr,
> > +			       struct switchdev_trans *trans)
> > +{
> > +	int err =3D 0;
> > +
> > +	switch (attr->id) {
> > +	case SWITCHDEV_ATTR_ID_PORT_STP_STATE:
> > +		err =3D port_attr_stp_state_set(netdev, trans,
> > +					      attr->u.stp_state);
> > +		break;
> > +	case SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS:
> > +		err =3D port_attr_br_flags_set(netdev, trans,
> > +					     attr->u.brport_flags);
> > +		break;
> > +	case SWITCHDEV_ATTR_ID_BRIDGE_VLAN_FILTERING:
> > +		/* VLANs are supported by default  */
> > +		break;
> > +	default:
> > +		err =3D -EOPNOTSUPP;
> > +		break;
> > +	}
> > +
> > +	return err;
> > +}
> > +
> > +static int port_vlans_add(struct net_device *netdev,
> > +			  const struct switchdev_obj_port_vlan *vlan,
> > +			  struct switchdev_trans *trans)
> > +{
> > +	struct ethsw_port_priv *port_priv =3D netdev_priv(netdev);
> > +	int vid, err;
> > +
> > +	if (switchdev_trans_ph_prepare(trans))
> > +		return 0;
> > +
> > +	for (vid =3D vlan->vid_begin; vid <=3D vlan->vid_end; vid++) {
> > +		if (!port_priv->ethsw_data->vlans[vid]) {
> > +			/* this is a new VLAN */
> > +			err =3D ethsw_add_vlan(port_priv->ethsw_data, vid);
> > +			if (err)
> > +				return err;
> > +
> > +			port_priv->ethsw_data->vlans[vid] |=3D
> ETHSW_VLAN_GLOBAL;
> > +		}
> > +		err =3D ethsw_port_add_vlan(port_priv, vid, vlan->flags);
> > +		if (err)
> > +			break;
> > +	}
> > +
> > +	return err;
> > +}
> > +
> > +static int port_lookup_address(struct net_device *netdev, int is_uc,
> > +			       const unsigned char *addr)
> > +{
> > +	struct netdev_hw_addr_list *list =3D (is_uc) ? &netdev->uc : &netdev-=
>mc;
> > +	struct netdev_hw_addr *ha;
> > +
> > +	netif_addr_lock_bh(netdev);
> > +	list_for_each_entry(ha, &list->list, list) {
> > +		if (ether_addr_equal(ha->addr, addr)) {
> > +			netif_addr_unlock_bh(netdev);
> > +			return 1;
> > +		}
> > +	}
> > +	netif_addr_unlock_bh(netdev);
> > +	return 0;
> > +}
> > +
> > +static int port_mdb_add(struct net_device *netdev,
> > +			const struct switchdev_obj_port_mdb *mdb,
> > +			struct switchdev_trans *trans)
> > +{
> > +	struct ethsw_port_priv *port_priv =3D netdev_priv(netdev);
> > +	int err;
> > +
> > +	if (switchdev_trans_ph_prepare(trans))
> > +		return 0;
> > +
> > +	/* Check if address is already set on this port */
> > +	if (port_lookup_address(netdev, 0, mdb->addr))
> > +		return -EEXIST;
> > +
> > +	err =3D ethsw_port_fdb_add_mc(port_priv, mdb->addr);
> > +	if (err)
> > +		return err;
> > +
> > +	err =3D dev_mc_add(netdev, mdb->addr);
> > +	if (err)
> > +		netdev_err(netdev, "dev_mc_add err %d\n", err);
>=20
> In the error case, shouldn't there be a "ethsw_port_fdb_del_mc" ?
>=20
> > +
> > +	return err;
> > +}
> > +
> > +static int swdev_port_obj_add(struct net_device *netdev,
> > +			      const struct switchdev_obj *obj,
> > +			      struct switchdev_trans *trans)
> > +{
> > +	int err;
> > +
> > +	switch (obj->id) {
> > +	case SWITCHDEV_OBJ_ID_PORT_VLAN:
> > +		err =3D port_vlans_add(netdev,
> > +				     SWITCHDEV_OBJ_PORT_VLAN(obj),
> > +				     trans);
> > +		break;
> > +	case SWITCHDEV_OBJ_ID_PORT_MDB:
> > +		err =3D port_mdb_add(netdev,
> > +				   SWITCHDEV_OBJ_PORT_MDB(obj),
> > +				   trans);
> > +		break;
> > +	default:
> > +		err =3D -EOPNOTSUPP;
> > +		break;
> > +	}
> > +
> > +	return err;
> > +}
> > +
> > +static int ethsw_port_del_vlan(struct ethsw_port_priv *port_priv, u16 =
vid)
> > +{
> > +	struct ethsw_core *ethsw =3D port_priv->ethsw_data;
> > +	struct net_device *netdev =3D port_priv->netdev;
> > +	struct dpsw_vlan_if_cfg vcfg;
> > +	int i, err, err2;
> > +	bool is_oper;
> > +
> > +	if (!port_priv->vlans[vid])
> > +		return -ENOENT;
> > +
> > +	if (port_priv->vlans[vid] & ETHSW_VLAN_PVID) {
> > +		struct dpsw_tci_cfg tci_cfg =3D { 0 };
> > +		/* Interface needs to be down to change PVID */
> > +		is_oper =3D netif_oper_up(netdev);
> > +
> > +		if (is_oper) {
> > +			err =3D dpsw_if_disable(ethsw->mc_io, 0,
> > +					      ethsw->dpsw_handle,
> > +					      port_priv->idx);
> > +			if (err) {
> > +				netdev_err(netdev, "dpsw_if_disable err %d\n",
> > +					   err);
> > +				goto exit_err;
> > +			}
> > +		}
> > +
> > +		err =3D dpsw_if_set_tci(ethsw->mc_io, 0,
> > +				      ethsw->dpsw_handle,
> > +				      port_priv->idx, &tci_cfg);
> > +		if (!err) {
> > +			port_priv->vlans[vid] &=3D ~ETHSW_VLAN_PVID;
> > +			port_priv->pvid =3D 0;
> > +		} else {
> > +			netdev_err(netdev, "dpsw_if_set_tci err %d\n", err);
> > +		}
> > +
> > +		if (is_oper) {
> > +			err2 =3D dpsw_if_enable(ethsw->mc_io, 0,
> > +					      ethsw->dpsw_handle,
> > +					      port_priv->idx);
> > +			if (err2) {
> > +				netdev_err(netdev, "dpsw_if_enable err %d\n",
> > +					   err2);
> > +				return err2;
> > +			}
> > +		}
> > +
> > +		if (err)
> > +			goto exit_err;
> > +	}
> > +
> > +	vcfg.num_ifs =3D 1;
> > +	vcfg.if_id[0] =3D port_priv->idx;
> > +	if (port_priv->vlans[vid] & ETHSW_VLAN_UNTAGGED) {
> > +		err =3D dpsw_vlan_remove_if_untagged(ethsw->mc_io, 0,
> > +						   ethsw->dpsw_handle,
> > +						   vid, &vcfg);
> > +		if (err) {
> > +			netdev_err(netdev,
> > +				   "dpsw_vlan_remove_if_untagged err %d\n",
> > +				   err);
> > +		}
> > +		port_priv->vlans[vid] &=3D ~ETHSW_VLAN_UNTAGGED;
> > +	}
> > +
> > +	if (port_priv->vlans[vid] & ETHSW_VLAN_MEMBER) {
> > +		err =3D dpsw_vlan_remove_if(ethsw->mc_io, 0, ethsw-
> >dpsw_handle,
> > +					  vid, &vcfg);
> > +		if (err) {
> > +			netdev_err(netdev,
> > +				   "dpsw_vlan_remove_if err %d\n", err);
> > +			return err;
> > +		}
> > +		port_priv->vlans[vid] &=3D ~ETHSW_VLAN_MEMBER;
> > +
> > +		/* Delete VLAN from switch if it is no longer configured on
> > +		 * any port
> > +		 */
> > +		for (i =3D 0; i < ethsw->sw_attr.num_ifs; i++)
> > +			if (ethsw->ports[i]->vlans[vid] &
> ETHSW_VLAN_MEMBER)
> > +				return 0; /* Found a port member in VID */
> > +
> > +		ethsw->vlans[vid] &=3D ~ETHSW_VLAN_GLOBAL;
> > +
> > +		err =3D ethsw_dellink_switch(ethsw, vid);
> > +		if (err)
> > +			goto exit_err;
> > +	}
> > +
> > +	return 0;
> > +exit_err:
> > +	return err;
> > +}
> > +
> > +static int port_vlans_del(struct net_device *netdev,
> > +			  const struct switchdev_obj_port_vlan *vlan)
> > +{
> > +	struct ethsw_port_priv *port_priv =3D netdev_priv(netdev);
> > +	int vid, err;
> > +
> > +	for (vid =3D vlan->vid_begin; vid <=3D vlan->vid_end; vid++) {
> > +		err =3D ethsw_port_del_vlan(port_priv, vid);
> > +		if (err)
> > +			break;
> > +	}
> > +
> > +	return err;
> > +}
> > +
> > +static int port_mdb_del(struct net_device *netdev,
> > +			const struct switchdev_obj_port_mdb *mdb)
> > +{
> > +	struct ethsw_port_priv *port_priv =3D netdev_priv(netdev);
> > +	int err;
> > +
> > +	if (!port_lookup_address(netdev, 0, mdb->addr))
> > +		return -ENOENT;
> > +
> > +	err =3D ethsw_port_fdb_del_mc(port_priv, mdb->addr);
> > +	if (err)
> > +		return err;
> > +
> > +	err =3D dev_mc_del(netdev, mdb->addr);
> > +	if (err) {
> > +		netdev_err(netdev, "dev_mc_del err %d\n", err);
> > +		return err;
> > +	}
> > +
> > +	return err;
> > +}
> > +
> > +static int swdev_port_obj_del(struct net_device *netdev,
> > +			      const struct switchdev_obj *obj)
> > +{
> > +	int err;
> > +
> > +	switch (obj->id) {
> > +	case SWITCHDEV_OBJ_ID_PORT_VLAN:
> > +		err =3D port_vlans_del(netdev,
> SWITCHDEV_OBJ_PORT_VLAN(obj));
> > +		break;
> > +	case SWITCHDEV_OBJ_ID_PORT_MDB:
> > +		err =3D port_mdb_del(netdev, SWITCHDEV_OBJ_PORT_MDB(obj));
> > +		break;
> > +	default:
> > +		err =3D -EOPNOTSUPP;
> > +		break;
> > +	}
> > +	return err;
> > +}
> > +
> > +static const struct switchdev_ops ethsw_port_switchdev_ops =3D {
> > +	.switchdev_port_attr_get	=3D swdev_port_attr_get,
> > +	.switchdev_port_attr_set	=3D swdev_port_attr_set,
> > +	.switchdev_port_obj_add		=3D swdev_port_obj_add,
> > +	.switchdev_port_obj_del		=3D swdev_port_obj_del,
> > +};
> > +
> > +/* For the moment, only flood setting needs to be updated */
> > +static int port_bridge_join(struct net_device *netdev)
> > +{
> > +	struct ethsw_port_priv *port_priv =3D netdev_priv(netdev);
> > +
> > +	/* Enable flooding */
> > +	return ethsw_port_set_flood(port_priv, 1);
> > +}
> > +
> > +static int port_bridge_leave(struct net_device *netdev)
> > +{
> > +	struct ethsw_port_priv *port_priv =3D netdev_priv(netdev);
> > +
> > +	/* Disable flooding */
> > +	return ethsw_port_set_flood(port_priv, 0);
> > +}
> > +
> > +static int port_netdevice_event(struct notifier_block *unused,
> > +				unsigned long event, void *ptr)
> > +{
> > +	struct net_device *netdev =3D netdev_notifier_info_to_dev(ptr);
> > +	struct netdev_notifier_changeupper_info *info =3D ptr;
> > +	struct net_device *upper_dev;
> > +	int err =3D 0;
> > +
> > +	if (netdev->netdev_ops !=3D &ethsw_port_ops)
> > +		return NOTIFY_DONE;
> > +
> > +	/* Handle just upper dev link/unlink for the moment */
> > +	if (event =3D=3D NETDEV_CHANGEUPPER) {
> > +		upper_dev =3D info->upper_dev;
> > +		if (netif_is_bridge_master(upper_dev)) {
> > +			if (info->linking)
> > +				err =3D port_bridge_join(netdev);
> > +			else
> > +				err =3D port_bridge_leave(netdev);
> > +		}
> > +	}
> > +
> > +	return notifier_from_errno(err);
> > +}
> > +
> > +static struct notifier_block port_nb __read_mostly =3D {
> > +	.notifier_call =3D port_netdevice_event,
> > +};
> > +
> > +struct ethsw_switchdev_event_work {
> > +	struct work_struct work;
> > +	struct switchdev_notifier_fdb_info fdb_info;
> > +	struct net_device *dev;
> > +	unsigned long event;
> > +};
> > +
> > +static void ethsw_switchdev_event_work(struct work_struct *work)
> > +{
> > +	struct ethsw_switchdev_event_work *switchdev_work =3D
> > +		container_of(work, struct ethsw_switchdev_event_work, work);
> > +	struct net_device *dev =3D switchdev_work->dev;
> > +	struct switchdev_notifier_fdb_info *fdb_info;
> > +	struct ethsw_port_priv *port_priv;
> > +
> > +	rtnl_lock();
> > +	port_priv =3D netdev_priv(dev);
> > +	fdb_info =3D &switchdev_work->fdb_info;
> > +
> > +	switch (switchdev_work->event) {
> > +	case SWITCHDEV_FDB_ADD_TO_DEVICE:
> > +		ethsw_port_fdb_add_uc(netdev_priv(dev), fdb_info->addr);
> > +		break;
> > +	case SWITCHDEV_FDB_DEL_TO_DEVICE:
> > +		ethsw_port_fdb_del_uc(netdev_priv(dev), fdb_info->addr);
> > +		break;
> > +	}
> > +
> > +	rtnl_unlock();
> > +	kfree(switchdev_work->fdb_info.addr);
> > +	kfree(switchdev_work);
> > +	dev_put(dev);
> > +}
> > +
> > +/* Called under rcu_read_lock() */
> > +static int port_switchdev_event(struct notifier_block *unused,
> > +				unsigned long event, void *ptr)
> > +{
> > +	struct net_device *dev =3D switchdev_notifier_info_to_dev(ptr);
> > +	struct ethsw_switchdev_event_work *switchdev_work;
> > +	struct switchdev_notifier_fdb_info *fdb_info =3D ptr;
> > +
> > +	switchdev_work =3D kzalloc(sizeof(*switchdev_work), GFP_ATOMIC);
> > +	if (!switchdev_work)
> > +		return NOTIFY_BAD;
> > +
> > +	INIT_WORK(&switchdev_work->work, ethsw_switchdev_event_work);
> > +	switchdev_work->dev =3D dev;
> > +	switchdev_work->event =3D event;
> > +
> > +	switch (event) {
> > +	case SWITCHDEV_FDB_ADD_TO_DEVICE:
> > +	case SWITCHDEV_FDB_DEL_TO_DEVICE:
> > +		memcpy(&switchdev_work->fdb_info, ptr,
> > +		       sizeof(switchdev_work->fdb_info));
> > +		switchdev_work->fdb_info.addr =3D kzalloc(ETH_ALEN,
> GFP_ATOMIC);
> > +		if (!switchdev_work->fdb_info.addr)
> > +			goto err_addr_alloc;
> > +
> > +		ether_addr_copy((u8 *)switchdev_work->fdb_info.addr,
> > +				fdb_info->addr);
> > +
> > +		/* Take a reference on the device to avoid being freed. */
> > +		dev_hold(dev);
> > +		break;
> > +	default:
> > +		return NOTIFY_DONE;
> > +	}
> > +
> > +	queue_work(ethsw_owq, &switchdev_work->work);
> > +
> > +	return NOTIFY_DONE;
> > +
> > +err_addr_alloc:
> > +	kfree(switchdev_work);
> > +	return NOTIFY_BAD;
> > +}
> > +
> > +static struct notifier_block port_switchdev_nb =3D {
> > +	.notifier_call =3D port_switchdev_event,
> > +};
> > +
> > +static int ethsw_register_notifier(struct device *dev)
> > +{
> > +	int err;
> > +
> > +	err =3D register_netdevice_notifier(&port_nb);
> > +	if (err) {
> > +		dev_err(dev, "Failed to register netdev notifier\n");
> > +		return err;
> > +	}
> > +
> > +	err =3D register_switchdev_notifier(&port_switchdev_nb);
> > +	if (err) {
> > +		dev_err(dev, "Failed to register switchdev notifier\n");
> > +		goto err_switchdev_nb;
> > +	}
> > +
> > +	return 0;
> > +
> > +err_switchdev_nb:
> > +	unregister_netdevice_notifier(&port_nb);
> > +	return err;
> > +}
> > +
> > +static int ethsw_open(struct ethsw_core	*ethsw)
>=20
> Minor formatting error, tab in function signature - see following functio=
n as well.
>=20
> > +{
> > +	struct ethsw_port_priv *port_priv =3D NULL;
> > +	int i, err;
> > +
> > +	err =3D dpsw_enable(ethsw->mc_io, 0, ethsw->dpsw_handle);
> > +	if (err) {
> > +		dev_err(ethsw->dev, "dpsw_enable err %d\n", err);
> > +		return err;
> > +	}
> > +
> > +	for (i =3D 0; i < ethsw->sw_attr.num_ifs; i++) {
> > +		port_priv =3D ethsw->ports[i];
> > +		err =3D dev_open(port_priv->netdev);
> > +		if (err) {
> > +			netdev_err(port_priv->netdev, "dev_open err %d\n",
> err);
> > +			return err;
> > +		}
> > +	}
> > +
> > +	return 0;
> > +}
> > +
> > +static int ethsw_stop(struct ethsw_core	*ethsw)
> > +{
> > +	struct ethsw_port_priv *port_priv =3D NULL;
> > +	int i, err;
> > +
> > +	destroy_workqueue(ethsw_owq);
>=20
> If workqueue is destroyed here, shouldn't it be alloc'd in ethsw_open?
>=20
> > +
> > +	for (i =3D 0; i < ethsw->sw_attr.num_ifs; i++) {
> > +		port_priv =3D ethsw->ports[i];
> > +		dev_close(port_priv->netdev);
> > +	}
> > +
> > +	err =3D dpsw_disable(ethsw->mc_io, 0, ethsw->dpsw_handle);
> > +	if (err) {
> > +		dev_err(ethsw->dev, "dpsw_disable err %d\n", err);
> > +		return err;
> > +	}
> > +
> > +	return 0;
> > +}
> > +
> > +static int ethsw_init(struct fsl_mc_device *sw_dev)
> > +{
> > +	struct device *dev =3D &sw_dev->dev;
> > +	struct ethsw_core *ethsw =3D dev_get_drvdata(dev);
> > +	u16 version_major, version_minor, i;
> > +	struct dpsw_stp_cfg stp_cfg;
> > +	int err;
> > +
> > +	ethsw->dev_id =3D sw_dev->obj_desc.id;
> > +
> > +	err =3D dpsw_open(ethsw->mc_io, 0, ethsw->dev_id, &ethsw-
> >dpsw_handle);
> > +	if (err) {
> > +		dev_err(dev, "dpsw_open err %d\n", err);
> > +		return err;
> > +	}
> > +
> > +	err =3D dpsw_get_attributes(ethsw->mc_io, 0, ethsw->dpsw_handle,
> > +				  &ethsw->sw_attr);
> > +	if (err) {
> > +		dev_err(dev, "dpsw_get_attributes err %d\n", err);
> > +		goto err_close;
> > +	}
> > +
> > +	err =3D dpsw_get_api_version(ethsw->mc_io, 0,
> > +				   &version_major,
> > +				   &version_minor);
> > +	if (err) {
> > +		dev_err(dev, "dpsw_get_api_version err %d\n", err);
> > +		goto err_close;
> > +	}
> > +
> > +	/* Minimum supported DPSW version check */
> > +	if (version_major < DPSW_MIN_VER_MAJOR ||
> > +	    (version_major =3D=3D DPSW_MIN_VER_MAJOR &&
> > +	     version_minor < DPSW_MIN_VER_MINOR)) {
> > +		dev_err(dev, "DPSW version %d:%d not supported. Use %d.%d
> or
> > greater.\n",
> > +			version_major,
> > +			version_minor,
> > +			DPSW_MIN_VER_MAJOR, DPSW_MIN_VER_MINOR);
> > +		err =3D -ENOTSUPP;
> > +		goto err_close;
> > +	}
> > +
> > +	err =3D dpsw_reset(ethsw->mc_io, 0, ethsw->dpsw_handle);
> > +	if (err) {
> > +		dev_err(dev, "dpsw_reset err %d\n", err);
> > +		goto err_close;
> > +	}
> > +
> > +	err =3D dpsw_fdb_set_learning_mode(ethsw->mc_io, 0, ethsw-
> >dpsw_handle, 0,
> > +					 DPSW_FDB_LEARNING_MODE_HW);
> > +	if (err) {
> > +		dev_err(dev, "dpsw_fdb_set_learning_mode err %d\n", err);
> > +		goto err_close;
> > +	}
> > +
> > +	stp_cfg.vlan_id =3D DEFAULT_VLAN_ID;
> > +	stp_cfg.state =3D DPSW_STP_STATE_FORWARDING;
> > +
> > +	for (i =3D 0; i < ethsw->sw_attr.num_ifs; i++) {
> > +		err =3D dpsw_if_set_stp(ethsw->mc_io, 0, ethsw->dpsw_handle, i,
> > +				      &stp_cfg);
> > +		if (err) {
> > +			dev_err(dev, "dpsw_if_set_stp err %d for port %d\n",
> > +				err, i);
> > +			goto err_close;
> > +		}
> > +
> > +		err =3D dpsw_if_set_broadcast(ethsw->mc_io, 0,
> > +					    ethsw->dpsw_handle, i, 1);
> > +		if (err) {
> > +			dev_err(dev,
> > +				"dpsw_if_set_broadcast err %d for port %d\n",
> > +				err, i);
> > +			goto err_close;
> > +		}
> > +	}
> > +
> > +	ethsw_owq =3D alloc_ordered_workqueue("%s_ordered",
> WQ_MEM_RECLAIM,
> > +					    "ethsw");
> > +	if (!ethsw_owq) {
> > +		err =3D -ENOMEM;
> > +		goto err_close;
> > +	}
> > +
> > +	err =3D ethsw_register_notifier(dev);
> > +	if (err)
> > +		goto err_destroy_ordered_workqueue;
> > +
> > +	return 0;
> > +
> > +err_destroy_ordered_workqueue:
> > +	destroy_workqueue(ethsw_owq);
> > +
> > +err_close:
> > +	dpsw_close(ethsw->mc_io, 0, ethsw->dpsw_handle);
> > +	return err;
> > +}
> > +
> > +static int ethsw_port_init(struct ethsw_port_priv *port_priv, u16 port=
)
> > +{
> > +	const char def_mcast[ETH_ALEN] =3D {0x01, 0x00, 0x5e, 0x00, 0x00, 0x0=
1};
> > +	struct net_device *netdev =3D port_priv->netdev;
> > +	struct ethsw_core *ethsw =3D port_priv->ethsw_data;
> > +	struct dpsw_tci_cfg tci_cfg =3D {0};
> > +	struct dpsw_vlan_if_cfg vcfg;
> > +	int err;
> > +
> > +	/* Switch starts with all ports configured to VLAN 1. Need to
> > +	 * remove this setting to allow configuration at bridge join
> > +	 */
> > +	vcfg.num_ifs =3D 1;
> > +	vcfg.if_id[0] =3D port_priv->idx;
> > +
> > +	err =3D dpsw_vlan_remove_if_untagged(ethsw->mc_io, 0, ethsw-
> >dpsw_handle,
> > +					   DEFAULT_VLAN_ID, &vcfg);
> > +	if (err) {
> > +		netdev_err(netdev, "dpsw_vlan_remove_if_untagged err
> %d\n",
> > +			   err);
> > +		return err;
> > +	}
> > +
> > +	err =3D dpsw_if_set_tci(ethsw->mc_io, 0, ethsw->dpsw_handle,
> > +			      port_priv->idx, &tci_cfg);
> > +	if (err) {
> > +		netdev_err(netdev, "dpsw_if_set_tci err %d\n", err);
> > +		return err;
> > +	}
> > +
> > +	err =3D dpsw_vlan_remove_if(ethsw->mc_io, 0, ethsw->dpsw_handle,
> > +				  DEFAULT_VLAN_ID, &vcfg);
> > +	if (err) {
> > +		netdev_err(netdev, "dpsw_vlan_remove_if err %d\n", err);
> > +		return err;
> > +	}
> > +
> > +	err =3D ethsw_port_fdb_add_mc(port_priv, def_mcast);
> > +
> > +	return err;
> > +}
> > +
> > +static void ethsw_takedown(struct fsl_mc_device *sw_dev)
> > +{
> > +	struct device *dev =3D &sw_dev->dev;
> > +	struct ethsw_core *ethsw =3D dev_get_drvdata(dev);
> > +	int err;
> > +
> > +	err =3D unregister_switchdev_notifier(&port_switchdev_nb);
> > +	if (err)
> > +		dev_err(dev,
> > +			"Failed to unregister switchdev notifier (%d)\n", err);
> > +
> > +	err =3D unregister_netdevice_notifier(&port_nb);
> > +	if (err)
> > +		dev_err(dev,
> > +			"Failed to unregister netdev notifier (%d)\n", err);
>=20
> Above 2 can be grouped into ethsw_unregister_notifier.
>=20
> > +
> > +	err =3D dpsw_close(ethsw->mc_io, 0, ethsw->dpsw_handle);
> > +	if (err)
> > +		dev_warn(dev, "dpsw_close err %d\n", err);
> > +}
> > +
> > +static int ethsw_remove(struct fsl_mc_device *sw_dev)
> > +{
> > +	struct ethsw_port_priv *port_priv;
> > +	struct ethsw_core *ethsw;
> > +	struct device *dev;
> > +	int i;
> > +
> > +	dev =3D &sw_dev->dev;
> > +	ethsw =3D dev_get_drvdata(dev);
> > +
> > +	ethsw_teardown_irqs(sw_dev);
> > +
> > +	rtnl_lock();
> > +	ethsw_stop(ethsw);
> > +	rtnl_unlock();
> > +
> > +	for (i =3D 0; i < ethsw->sw_attr.num_ifs; i++) {
> > +		port_priv =3D ethsw->ports[i];
> > +		unregister_netdev(port_priv->netdev);
> > +		free_netdev(port_priv->netdev);
> > +	}
> > +	kfree(ethsw->ports);
> > +
> > +	ethsw_takedown(sw_dev);
> > +	fsl_mc_portal_free(ethsw->mc_io);
> > +
> > +	kfree(ethsw);
> > +
> > +	dev_set_drvdata(dev, NULL);
> > +
> > +	return 0;
> > +}
> > +
> > +static int ethsw_probe_port(struct ethsw_core *ethsw, u16 port_idx)
> > +{
> > +	struct ethsw_port_priv *port_priv;
> > +	struct device *dev =3D ethsw->dev;
> > +	struct net_device *port_netdev;
> > +	int err;
> > +
> > +	port_netdev =3D alloc_etherdev(sizeof(struct ethsw_port_priv));
> > +	if (!port_netdev) {
> > +		dev_err(dev, "alloc_etherdev error\n");
> > +		return -ENOMEM;
> > +	}
> > +
> > +	port_priv =3D netdev_priv(port_netdev);
> > +	port_priv->netdev =3D port_netdev;
> > +	port_priv->ethsw_data =3D ethsw;
> > +
> > +	port_priv->idx =3D port_idx;
> > +	port_priv->stp_state =3D BR_STATE_FORWARDING;
> > +
> > +	/* Flooding is implicitly enabled */
> > +	port_priv->flood =3D true;
> > +
> > +	SET_NETDEV_DEV(port_netdev, dev);
> > +	port_netdev->netdev_ops =3D &ethsw_port_ops;
> > +	port_netdev->switchdev_ops =3D &ethsw_port_switchdev_ops;
> > +
> > +	/* Set MTU limits */
> > +	port_netdev->min_mtu =3D ETH_MIN_MTU;
> > +	port_netdev->max_mtu =3D ETHSW_MAX_FRAME_LENGTH;
> > +
> > +	err =3D register_netdev(port_netdev);
> > +	if (err < 0) {
> > +		dev_err(dev, "register_netdev error %d\n", err);
> > +			free_netdev(port_netdev);
> > +			return err;
> > +		}
> > +
> > +	ethsw->ports[port_idx] =3D port_priv;
> > +
> > +	return ethsw_port_init(port_priv, port_idx);
> > +}
> > +
> > +static int ethsw_probe(struct fsl_mc_device *sw_dev)
> > +{
> > +	struct device *dev =3D &sw_dev->dev;
> > +	struct ethsw_core *ethsw;
> > +	int err;
> > +	u16 i, j;
> > +
> > +	/* Allocate switch core*/
> > +	ethsw =3D kzalloc(sizeof(*ethsw), GFP_KERNEL);
> > +
> > +	if (!ethsw)
> > +		return -ENOMEM;
> > +
> > +	ethsw->dev =3D dev;
> > +	dev_set_drvdata(dev, ethsw);
> > +
> > +	err =3D fsl_mc_portal_allocate(sw_dev, 0, &ethsw->mc_io);
> > +	if (err) {
> > +		dev_err(dev, "fsl_mc_portal_allocate err %d\n", err);
> > +		goto err_free_drvdata;
> > +	}
> > +
> > +	err =3D ethsw_init(sw_dev);
> > +	if (err)
> > +		goto err_free_cmdport;
> > +
> > +	/* DEFAULT_VLAN_ID is implicitly configured on the switch */
> > +	ethsw->vlans[DEFAULT_VLAN_ID] =3D ETHSW_VLAN_MEMBER;
> > +
> > +	/* Learning is implicitly enabled */
> > +	ethsw->learning =3D true;
> > +
> > +	ethsw->ports =3D kcalloc(ethsw->sw_attr.num_ifs, sizeof(*ethsw->ports=
),
> > +			       GFP_KERNEL);
> > +	if (!(ethsw->ports)) {
> > +		err =3D -ENOMEM;
> > +		goto err_takedown;
> > +	}
> > +
> > +	for (i =3D 0; i < ethsw->sw_attr.num_ifs; i++) {
> > +		err =3D ethsw_probe_port(ethsw, i);
> > +		if (err) {
> > +			/* Cleanup previous ports only */
> > +			for (j =3D 0; j < i; j++) {
>=20
> I think you can go with
> for (i--; i >=3D 0; i--)
>=20
> or better yet:
> goto err_free_ports
> and refactor err_free_ports to look like:
> for (i--; i >=3D 0; i--) {
> ...
> }
>=20
> Best regards,
> Bogdan P.
>=20
> > +				unregister_netdev(ethsw->ports[j]->netdev);
> > +				free_netdev(ethsw->ports[j]->netdev);
> > +			}
> > +			goto err_takedown;
> > +		}
> > +	}
> > +
> > +	/* Switch starts up enabled */
> > +	rtnl_lock();
> > +	err =3D ethsw_open(ethsw);
> > +	rtnl_unlock();
> > +	if (err)
> > +		goto err_free_ports;
> > +
> > +	/* Setup IRQs */
> > +	err =3D ethsw_setup_irqs(sw_dev);
> > +	if (err)
> > +		goto err_stop;
> > +
> > +	dev_info(dev, "probed %d port switch\n", ethsw->sw_attr.num_ifs);
> > +	return 0;
> > +
> > +err_stop:
> > +	rtnl_lock();
> > +	ethsw_stop(ethsw);
> > +	rtnl_unlock();
> > +
> > +err_free_ports:
> > +	for (i =3D 0; i < ethsw->sw_attr.num_ifs; i++) {
> > +		unregister_netdev(ethsw->ports[i]->netdev);
> > +		free_netdev(ethsw->ports[i]->netdev);
> > +	}
> > +	kfree(ethsw->ports);
> > +
> > +err_takedown:
> > +	ethsw_takedown(sw_dev);
> > +
> > +err_free_cmdport:
> > +	fsl_mc_portal_free(ethsw->mc_io);
> > +
> > +err_free_drvdata:
> > +	kfree(ethsw);
> > +	dev_set_drvdata(dev, NULL);
> > +
> > +	return err;
> > +}
> > +
> > +static const struct fsl_mc_device_id ethsw_match_id_table[] =3D {
> > +	{
> > +		.vendor =3D FSL_MC_VENDOR_FREESCALE,
> > +		.obj_type =3D "dpsw",
> > +	},
> > +	{ .vendor =3D 0x0 }
> > +};
> > +MODULE_DEVICE_TABLE(fslmc, ethsw_match_id_table);
> > +
> > +static struct fsl_mc_driver eth_sw_drv =3D {
> > +	.driver =3D {
> > +		.name =3D KBUILD_MODNAME,
> > +		.owner =3D THIS_MODULE,
> > +	},
> > +	.probe =3D ethsw_probe,
> > +	.remove =3D ethsw_remove,
> > +	.match_id_table =3D ethsw_match_id_table
> > +};
> > +
> > +module_fsl_mc_driver(eth_sw_drv);
> > +
> > +MODULE_LICENSE("Dual BSD/GPL");
> > +MODULE_DESCRIPTION("DPAA2 Ethernet Switch Driver");
> > diff --git a/drivers/staging/fsl-dpaa2/ethsw/ethsw.h b/drivers/staging/=
fsl-
> > dpaa2/ethsw/ethsw.h
> > new file mode 100644
> > index 0000000..8c1d645
> > --- /dev/null
> > +++ b/drivers/staging/fsl-dpaa2/ethsw/ethsw.h
> > @@ -0,0 +1,88 @@
> > +/* Copyright 2014-2017 Freescale Semiconductor Inc.
> > + * Copyright 2017 NXP
> > + *
> > + * Redistribution and use in source and binary forms, with or without
> > + * modification, are permitted provided that the following conditions =
are met:
> > + *     * Redistributions of source code must retain the above copyrigh=
t
> > + *	 notice, this list of conditions and the following disclaimer.
> > + *     * Redistributions in binary form must reproduce the above copyr=
ight
> > + *	 notice, this list of conditions and the following disclaimer in th=
e
> > + *	 documentation and/or other materials provided with the distributio=
n.
> > + *     * Neither the name of the above-listed copyright holders nor th=
e
> > + *	 names of any contributors may be used to endorse or promote produc=
ts
> > + *	 derived from this software without specific prior written permissi=
on.
> > + *
> > + *
> > + * ALTERNATIVELY, this software may be distributed under the terms of =
the
> > + * GNU General Public License ("GPL") as published by the Free Softwar=
e
> > + * Foundation, either version 2 of that License or (at your option) an=
y
> > + * later version.
> > + *
> > + * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
> CONTRIBUTORS "AS IS"
> > + * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
> LIMITED TO, THE
> > + * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
> PARTICULAR PURPOSE
> > + * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR
> CONTRIBUTORS BE
> > + * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
> > + * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
> PROCUREMENT OF
> > + * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
> BUSINESS
> > + * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
> WHETHER IN
> > + * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
> OTHERWISE)
> > + * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
> ADVISED OF THE
> > + * POSSIBILITY OF SUCH DAMAGE.
> > + */
> > +
> > +#ifndef __ETHSW_H
> > +#define __ETHSW_H
> > +
> > +#include <linux/netdevice.h>
> > +#include <linux/etherdevice.h>
> > +#include <linux/rtnetlink.h>
> > +#include <linux/if_vlan.h>
> > +#include <uapi/linux/if_bridge.h>
> > +#include <net/switchdev.h>
> > +#include <linux/if_bridge.h>
> > +
> > +#include "dpsw.h"
> > +
> > +/* Number of IRQs supported */
> > +#define DPSW_IRQ_NUM	2
> > +
> > +#define ETHSW_VLAN_MEMBER	1
> > +#define ETHSW_VLAN_UNTAGGED	2
> > +#define ETHSW_VLAN_PVID		4
> > +#define ETHSW_VLAN_GLOBAL	8
> > +
> > +/* Maximum Frame Length supported by HW (currently 10k) */
> > +#define DPAA2_MFL		(10 * 1024)
> > +#define ETHSW_MAX_FRAME_LENGTH	(DPAA2_MFL - VLAN_ETH_HLEN -
> ETH_FCS_LEN)
> > +#define ETHSW_L2_MAX_FRM(mtu)	((mtu) + VLAN_ETH_HLEN +
> ETH_FCS_LEN)
> > +
> > +struct ethsw_core;
> > +
> > +/* Per port private data */
> > +struct ethsw_port_priv {
> > +	struct net_device	*netdev;
> > +	u16			idx;
> > +	struct ethsw_core	*ethsw_data;
> > +	u8			link_state;
> > +	u8			stp_state;
> > +	bool			flood;
> > +
> > +	u8			vlans[VLAN_VID_MASK + 1];
> > +	u16			pvid;
> > +};
> > +
> > +/* Switch data */
> > +struct ethsw_core {
> > +	struct device			*dev;
> > +	struct fsl_mc_io		*mc_io;
> > +	u16				dpsw_handle;
> > +	struct dpsw_attr		sw_attr;
> > +	int				dev_id;
> > +	struct ethsw_port_priv		**ports;
> > +
> > +	u8				vlans[VLAN_VID_MASK + 1];
> > +	bool				learning;
> > +};
> > +
> > +#endif	/* __ETHSW_H */
> > --
> > 1.9.1
