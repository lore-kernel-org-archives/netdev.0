From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH 1/1] Fix dst_neigh_lookup/dst_neigh_lookup_skb return
 value handling bug
Date: Thu, 14 Mar 2013 05:26:20 +0000 (UTC)
Message-ID: <khrn1r$j3t$1@ger.gmane.org>
References: <1363232492-4562-1-git-send-email-zhouzhouyi@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-rdma@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:52021 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751293Ab3CNF0i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Mar 2013 01:26:38 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1UG0gr-0007hD-Jb
	for netdev@vger.kernel.org; Thu, 14 Mar 2013 06:26:57 +0100
Received: from 112.116.191.231 ([112.116.191.231])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 14 Mar 2013 06:26:57 +0100
Received: from xiyou.wangcong by 112.116.191.231 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 14 Mar 2013 06:26:57 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 14 Mar 2013 at 03:41 GMT, Zhouyi Zhou <zhouzhouyi@gmail.com> wrote:
> Tested on my x86_64 machine
>
> Signed-off-by: Zhouyi Zhou <zhouzhouyi@gmail.com>
> ---
>  drivers/infiniband/hw/cxgb4/cm.c |   12 ++++++++++++
>  include/net/dst.h                |    6 ++++--
>  2 files changed, 16 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
> index 565bfb1..6b95851 100644
> --- a/drivers/infiniband/hw/cxgb4/cm.c
> +++ b/drivers/infiniband/hw/cxgb4/cm.c
> @@ -1575,6 +1575,12 @@ static int c4iw_reconnect(struct c4iw_ep *ep)
>  
>  	neigh = dst_neigh_lookup(ep->dst,
>  			&ep->com.cm_id->remote_addr.sin_addr.s_addr);
> +	if (!neigh) {
> +		pr_err("%s - cannot alloc neigh.\n", __func__);
> +		err = -ENOMEM;
> +		goto fail4;


You don't need to print error messages for OOM, the mm subsystem will
do.
