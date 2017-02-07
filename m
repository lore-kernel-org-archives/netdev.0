From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [RFC v3 02/11] IB/hfi-vnic: Virtual Network Interface Controller
 (VNIC) interface
Date: Tue, 7 Feb 2017 14:19:01 -0700
Message-ID: <20170207211901.GB28922@obsidianresearch.com>
References: <1486498990-76562-1-git-send-email-niranjana.vishwanathapura@intel.com>
 <1486498990-76562-3-git-send-email-niranjana.vishwanathapura@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dledford@redhat.com, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org, dennis.dalessandro@intel.com,
        ira.weiny@intel.com, Liran Liss <liranl@mellanox.com>
To: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:56418 "EHLO quartz.orcorp.ca"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752657AbdBGVVa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 7 Feb 2017 16:21:30 -0500
Content-Disposition: inline
In-Reply-To: <1486498990-76562-3-git-send-email-niranjana.vishwanathapura@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 07, 2017 at 12:23:01PM -0800, Vishwanathapura, Niranjana wrote:
> Add rdma netdev interface to ib device structure allowing rdma netdev
> devices to be allocated by ib clients.
> Define HFI VNIC interface between hardware independent VNIC
> functionality and the hardware dependent VNIC functionality.

This commit message could be a bit clearer.

The alloc_rdma_netdev multiplexer is inteded as a new general
interface and this adds a protocol definition for ethernet VNIC on
OPA.

The hope is that ipoib can follow the same example and use the same
alloc_rdma_netdev entry point. Hopefully Mellanox will look at this
patch as I have talked to them in the past about doing this...

It looks like HFI turned out fairly well, the driver code and higher
level code have a reasonably nice split in my quick look.

>  	IB_DEVICE_RAW_SCATTER_FCS		= (1ULL << 34),
> +	IB_DEVICE_RDMA_NETDEV_HFI_VNIC		= (1ULL << 35),

What is this called HFI_VNIC anyhow? Shouldn't this be OPA_VNIC? There
is nothing really HFI specific, right?

> +/* hfi vnic rdma netdev's private data structure */
> +struct hfi_vnic_rdma_netdev {
> +	struct rdma_netdev rn;  /* keep this first */
> +	/* followed by device private data */
> +	char *dev_priv[0];
> +};
> +
> +static inline void *hfi_vnic_priv(const struct net_device *dev)
> +{
> +	struct rdma_netdev *rn = netdev_priv(dev);
> +
> +	return rn->clnt_priv;
> +}
> +
> +static inline void *hfi_vnic_dev_priv(const struct net_device *dev)
> +{
> +	struct rdma_netdev *rn = netdev_priv(dev);

Shouldn't this be hfi_vnic_rdma_netdev ?

> +	return rn + 1;

And this should be rn->dev_priv ?

Jason
