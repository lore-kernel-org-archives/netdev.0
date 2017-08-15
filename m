From: Leon Romanovsky <leonro@mellanox.com>
Subject: Re: [PATCH v4 iproute2 2/7] rdma: Add dev object
Date: Tue, 15 Aug 2017 19:43:50 +0300
Message-ID: <20170815164350.GU24282@mtr-leonro.local>
References: <20170815130020.29509-1-leonro@mellanox.com>
 <20170815130020.29509-3-leonro@mellanox.com>
 <20170815091205.2c39ea91@xeon-e3>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="3Shs6nLsUBL77Lfu"
Cc: Doug Ledford <dledford@redhat.com>, linux-rdma@vger.kernel.org,
        Dennis Dalessandro <dennis.dalessandro@intel.com>,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Ariel Almog <ariela@mellanox.com>,
        Linux Netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0042.outbound.protection.outlook.com ([104.47.2.42]:3308
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751573AbdHOQn7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Aug 2017 12:43:59 -0400
Content-Disposition: inline
In-Reply-To: <20170815091205.2c39ea91@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--3Shs6nLsUBL77Lfu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Aug 15, 2017 at 09:12:05AM -0700, Stephen Hemminger wrote:
> On Tue, 15 Aug 2017 16:00:15 +0300
> Leon Romanovsky <leonro@mellanox.com> wrote:
>
> > +
> > +static const char *dev_caps_to_str(uint32_t idx)
> > +{
> > +	uint64_t cap = 1 << idx;
> > +
> > +	switch (cap) {
> > +	case RDMA_DEV_RESIZE_MAX_WR: return "RESIZE_MAX_WR";
> > +	case RDMA_DEV_BAD_PKEY_CNTR: return "BAD_PKEY_CNTR";
> > +	case RDMA_DEV_BAD_QKEY_CNTR: return "BAD_QKEY_CNTR";
> > +	case RDMA_DEV_RAW_MULTI: return "RAW_MULTI";
> > +	case RDMA_DEV_AUTO_PATH_MIG: return "AUTO_PATH_MIG";
> > +	case RDMA_DEV_CHANGE_PHY_PORT: return "CHANGE_PHY_POR";
> > +	case RDMA_DEV_UD_AV_PORT_ENFORCE: return "UD_AV_PORT_ENFORCE";
> > +	case RDMA_DEV_CURR_QP_STATE_MOD: return "CURR_QP_STATE_MOD";
> > +	case RDMA_DEV_SHUTDOWN_PORT: return "SHUTDOWN_PORT";
> > +	case RDMA_DEV_INIT_TYPE: return "INIT_TYPE";
> > +	case RDMA_DEV_PORT_ACTIVE_EVENT: return "PORT_ACTIVE_EVENT";
> > +	case RDMA_DEV_SYS_IMAGE_GUID: return "SYS_IMAGE_GUID";
> > +	case RDMA_DEV_RC_RNR_NAK_GEN: return "RC_RNR_NAK_GEN";
> > +	case RDMA_DEV_SRQ_RESIZE: return "SRQ_RESIZE";
> > +	case RDMA_DEV_N_NOTIFY_CQ: return "N_NOTIFY_CQ";
> > +	case RDMA_DEV_LOCAL_DMA_LKEY: return "LOCAL_DMA_LKEY";
> > +	case RDMA_DEV_MEM_WINDOW: return "MEM_WINDOW";
> > +	case RDMA_DEV_UD_IP_CSUM: return "UD_IP_CSUM";
> > +	case RDMA_DEV_UD_TSO: return "UD_TSO";
> > +	case RDMA_DEV_XRC: return "XRC";
> > +	case RDMA_DEV_MEM_MGT_EXTENSIONS: return "MEM_MGT_EXTENSIONS";
> > +	case RDMA_DEV_BLOCK_MULTICAST_LOOPBACK:
> > +					return "BLOCK_MULTICAST_LOOPBACK";
> > +	case RDMA_DEV_MEM_WINDOW_TYPE_2A: return "MEM_WINDOW_TYPE_2A";
> > +	case RDMA_DEV_MEM_WINDOW_TYPE_2B: return "MEM_WINDOW_TYPE_2B";
> > +	case RDMA_DEV_RC_IP_CSUM: return "RC_IP_CSUM";
> > +	case RDMA_DEV_RAW_IP_CSUM: return "RAW_IP_CSUM";
> > +	case RDMA_DEV_CROSS_CHANNEL: return "CROSS_CHANNEL";
> > +	case RDMA_DEV_MANAGED_FLOW_STEERING: return "MANAGED_FLOW_STEERING";
> > +	case RDMA_DEV_SIGNATURE_HANDOVER: return "SIGNATURE_HANDOVER";
> > +	case RDMA_DEV_ON_DEMAND_PAGING: return "ON_DEMAND_PAGING";
> > +	case RDMA_DEV_SG_GAPS_REG: return "SG_GAPS_REG";
> > +	case RDMA_DEV_VIRTUAL_FUNCTION: return "VIRTUAL_FUNCTION";
> > +	case RDMA_DEV_RAW_SCATTER_FCS: return "RAW_SCATTER_FCS";
> > +	case RDMA_DEV_RDMA_NETDEV_OPA_VNIC: return "RDMA_NETDEV_OPA_VNIC";
> > +	default: return "UNKNOWN";
> > +	}
>
> Could this be a table in future versions?

The device capability is 64 bit field -> the table will have 64 entry,
while most of them should be marked as "UNKNOWN". Because we have holes
[1] in the fields (for example bit 9), I can't use simple
"if (idx > max_value) return "uknown"" logic.

So the answer is yes, I can do it as a table, but it won't look better than
it is now :)

By writing "future versions", are you asking me to resubmit? or followup patch
will be possible solution too?

Thanks

[1] http://marc.info/?l=linux-rdma&m=150278850520856&w=2

> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--3Shs6nLsUBL77Lfu
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlmTJMYACgkQ5GN7iDZy
WKde/RAAn/ImqEaGt2Io+KiEhXuLkSq+W3AroNrLJOe9Xrfdg6OLz5iMyBKzx3bJ
alFaiyek7cD8DILBGk33EPjyLC5gR6ueseyZLVU2HZURqpwrrVI8hOP/ki3M97cN
JEKUQuSvD58okjgBZljBcsan6SdtGQX1THJkZRpBvuhLTfkimgmsBKZsOLGNKEIV
xdJyvKdwmWVeLx0hgNbmnPa3ff/55mBR9t4w6HJ+W5byj44dnNQrnk0N07oabY+q
l9IoPyGccx3l3B2DUviUG8/QsxGZyvbtrMPTtqAakuaMoteGCJJ9HgC1Ox795X+f
yipfCsbdMqc5D+rt7UPVKlzP/WqXqbYoGSjnh3QGU4BsmhWepe91GfmMff9iqZi0
E2Si3sp7Kd0my2m4qh4ZPiJGRJnZzsq/cQkrl4PQ0OouQPeKvlH6uD3JTt1KmA+V
7hmohzmGtw/9350uYfb375/rnJDOLS0zFMoCriJT5EHkKqW7XevhZgbDVrAgpZdj
k2/wvdUSUMt/kDgF8lLtLZit7lsdO0yJb9p+69moE5nEg+WnH3cGLcPbTfbsC833
aItr93cVtLuhojc5xZss/MWpNaHUvh8FdcDA6nFu/EQAhRY2aHWA/X1tt3GNVi1c
b1HHV0MzyHSjQvj12abBGbPTCELzTYTBsQAoRKNloIcG1Orkls0=
=8Co0
-----END PGP SIGNATURE-----

--3Shs6nLsUBL77Lfu--
