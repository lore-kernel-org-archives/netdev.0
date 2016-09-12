From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH v4 02/16] IB/pvrdma: Add user-level shared functions
Date: Mon, 12 Sep 2016 11:49:34 -0600
Message-ID: <20160912174934.GE5843@obsidianresearch.com>
References: <1473655766-31628-1-git-send-email-aditr@vmware.com>
 <1473655766-31628-3-git-send-email-aditr@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dledford@redhat.com, linux-rdma@vger.kernel.org,
        pv-drivers@vmware.com, netdev@vger.kernel.org,
        linux-pci@vger.kernel.org, jhansen@vmware.com, asarwade@vmware.com,
        georgezhang@vmware.com, bryantan@vmware.com
To: Adit Ranadive <aditr@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:38989 "EHLO quartz.orcorp.ca"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755570AbcILRth (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Sep 2016 13:49:37 -0400
Content-Disposition: inline
In-Reply-To: <1473655766-31628-3-git-send-email-aditr@vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 11, 2016 at 09:49:12PM -0700, Adit Ranadive wrote:
> We share some common structures with the user-level driver. This patch
> adds those structures and shared functions to traverse the QP/CQ rings.

>  create mode 100644 drivers/infiniband/hw/pvrdma/pvrdma_uapi.h
>  create mode 100644 drivers/infiniband/hw/pvrdma/pvrdma_user.h

The files that are intended to be shared with userspace must be under
include/uapi/, please coordinate with Leon on the path.

Same for all the new drivers.

> +static inline __s32 pvrdma_idx(atomic_t *var, __u32 max_elems)
> +{
> +	const unsigned int idx = atomic_read(var);

Eh? Does this even compile in userspace?

If this is not a userspace header then why does it use __u32 and
related ??

> +#define PVRDMA_UVERBS_ABI_VERSION	3
> +#define PVRDMA_BOARD_ID			1
> +#define PVRDMA_REV_ID			1
> +
> +struct pvrdma_alloc_ucontext_resp {
> +	u32 qp_tab_size;
> +	u32 reserved;
> +};

This certainly looks like a userspace header, shouldn't it use __u32?

NAK

Jason
