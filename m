From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [RFC 02/10] IB/hfi-vnic: Virtual Network Interface Controller
 (VNIC) Bus driver
Date: Sat, 19 Nov 2016 12:04:45 -0700
Message-ID: <20161119190445.GG22775@obsidianresearch.com>
References: <1479508938-63799-1-git-send-email-niranjana.vishwanathapura@intel.com>
 <1479508938-63799-3-git-send-email-niranjana.vishwanathapura@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Doug Ledford <dledford@redhat.com>, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org,
        Dennis Dalessandro <dennis.dalessandro@intel.com>
To: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:32949 "EHLO quartz.orcorp.ca"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752414AbcKSTEq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 19 Nov 2016 14:04:46 -0500
Content-Disposition: inline
In-Reply-To: <1479508938-63799-3-git-send-email-niranjana.vishwanathapura@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 18, 2016 at 02:42:10PM -0800, Vishwanathapura, Niranjana wrote:
> +HFI-VNIC DRIVER
> +M:	Dennis Dalessandro <dennis.dalessandro@intel.com>
> +M:	Niranjana Vishwanathapura <niranjana.vishwanathapura@intel.com>
> +L:	linux-rdma@vger.kernel.org
> +S:	Supported
> +F:	drivers/infiniband/sw/intel/vnic

This is either a net driver or a ULP, no idea why it should go in this
directory!?

It sounds like an ethernet driver, so you should probably put it
there...

> +/* hfi_vnic_bus_init - initialize the hfi vnic bus drvier */
> +static int hfi_vnic_bus_init(void)
> +{
> +	int rc;
> +
> +	ida_init(&hfi_vnic_ctrl_ida);
> +	idr_init(&hfi_vnic_idr);
> +
> +	rc = bus_register(&hfi_vnic_bus);

Why on earth do we need this? Didn't I give you enough grief for the
psm stuff and now you want to create an entire subystem hidden away!?

Use some netlink scheme to control your vnic like the rest of the net
stack..

Jason
