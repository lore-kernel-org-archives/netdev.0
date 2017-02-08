From: Parav Pandit <parav@mellanox.com>
Subject: RE: [RFC v3 02/11] IB/hfi-vnic: Virtual Network Interface Controller
 (VNIC) interface
Date: Wed, 8 Feb 2017 00:43:40 +0000
Message-ID: <VI1PR0502MB3008911E9587F4C004BFEF13D1420@VI1PR0502MB3008.eurprd05.prod.outlook.com>
References: <1486498990-76562-1-git-send-email-niranjana.vishwanathapura@intel.com>
 <1486498990-76562-3-git-send-email-niranjana.vishwanathapura@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "dennis.dalessandro@intel.com" <dennis.dalessandro@intel.com>,
        "ira.weiny@intel.com" <ira.weiny@intel.com>
To: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura@intel.com>,
        "dledford@redhat.com" <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr30081.outbound.protection.outlook.com ([40.107.3.81]:17920
        "EHLO EUR03-AM5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753026AbdBHAob (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 7 Feb 2017 19:44:31 -0500
In-Reply-To: <1486498990-76562-3-git-send-email-niranjana.vishwanathapura@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi=20

> -----Original Message-----
> From: linux-rdma-owner@vger.kernel.org [mailto:linux-rdma-
> owner@vger.kernel.org] On Behalf Of Vishwanathapura, Niranjana
> Sent: Tuesday, February 7, 2017 2:23 PM
> To: dledford@redhat.com
> Cc: linux-rdma@vger.kernel.org; netdev@vger.kernel.org;
> dennis.dalessandro@intel.com; ira.weiny@intel.com; Niranjana
> Vishwanathapura <niranjana.vishwanathapura@intel.com>
> Subject: [RFC v3 02/11] IB/hfi-vnic: Virtual Network Interface Controller
> (VNIC) interface
>=20
> Add rdma netdev interface to ib device structure allowing rdma netdev
> devices to be allocated by ib clients.
> Define HFI VNIC interface between hardware independent VNIC
> functionality and the hardware dependent VNIC functionality.
>=20
> Reviewed-by: Dennis Dalessandro <dennis.dalessandro@intel.com>
> Reviewed-by: Ira Weiny <ira.weiny@intel.com>
> Signed-off-by: Niranjana Vishwanathapura
> <niranjana.vishwanathapura@intel.com>
> ---
>  struct ib_device {
>  	struct device                *dma_device;
>=20
> @@ -2096,6 +2114,15 @@ struct ib_device {
>  							   struct
> ib_rwq_ind_table_init_attr *init_attr,
>  							   struct ib_udata
> *udata);
>  	int                        (*destroy_rwq_ind_table)(struct ib_rwq_ind_t=
able
> *wq_ind_table);
> +	/* rdma netdev operations */
> +	struct net_device *(*alloc_rdma_netdev)(
> +					struct ib_device *device,
> +					u8 port_num,
> +					enum rdma_netdev_t type,
> +					const char *name,
> +					unsigned char name_assign_type,
> +					void (*setup)(struct net_device *));
> +	void (*free_rdma_netdev)(struct net_device *netdev);
>  	struct ib_dma_mapping_ops   *dma_ops;
>=20
>  	struct module               *owner;

As its clear from the cover letter and from the request to place this in dr=
ivers/infiniband/ulp,
Instead of increasing the ib_dev structure further,
Can you change the code to make use of ib_register_client() and friend func=
tions to register vnic as ULP.
(similar to other ULP such as uverbs, srp, ipoib).
This will also allow you get to get notified for removing the vnic device w=
hen underlying rdma device gets removed.
Based on the property that gets exposed by the ibdev, vnic driver filters w=
hether it needs to load its vnic to specific device or not.
This way modules are isolated between core and ULP little better.
Would it work for you?
