From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [RFC v2 04/12] qedr: Add support for user context verbs
Date: Tue, 20 Sep 2016 09:27:29 -0600
Message-ID: <20160920152729.GC32020@obsidianresearch.com>
References: <1474367764-9555-1-git-send-email-Ram.Amrani@cavium.com>
 <1474367764-9555-5-git-send-email-Ram.Amrani@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, dledford@redhat.com, Ariel.Elior@cavium.com,
        Michal.Kalderon@cavium.com, Yuval.Mintz@cavium.com,
        rajesh.borundia@cavium.com, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org
To: Ram Amrani <Ram.Amrani@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:45595 "EHLO quartz.orcorp.ca"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752844AbcITP1e (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Sep 2016 11:27:34 -0400
Content-Disposition: inline
In-Reply-To: <1474367764-9555-5-git-send-email-Ram.Amrani@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 20, 2016 at 01:35:56PM +0300, Ram Amrani wrote:
> +++ b/include/uapi/rdma/providers/qedr-abi.h
> @@ -0,0 +1,27 @@
> +/* QLogic qed NIC Driver
> + * Copyright (c) 2015 QLogic Corporation
> + *
> + * This software is available under the terms of the GNU General Public License
> + * (GPL) Version 2, available from the file COPYING in the main directory of
> + * this source tree.
> + */
> +#ifndef __QEDR_USER_H__
> +#define __QEDR_USER_H__
> +
> +#define QEDR_ABI_VERSION		(6)
> +
> +/* user kernel communication data structures. */
> +
> +struct qedr_alloc_ucontext_resp {
> +	u64 db_pa;
> +	u32 db_size;
> +
> +	u32 max_send_wr;
> +	u32 max_recv_wr;
> +	u32 max_srq_wr;
> +	u32 sges_per_send_wr;
> +	u32 sges_per_recv_wr;
> +	u32 sges_per_srq_wr;

uapi headers need the __ varients and the #include <linux/types.h>

Follow what Leon has done.

> +	int max_cqes;

Do not use int here.

Is there really only 1 struct? Your driver never uses udata for
anything else?

Jason
