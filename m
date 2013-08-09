From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/4] drivers/net: enic: Adding support for Cisco Low
 Latency NIC
Date: Fri, 09 Aug 2013 11:45:39 -0700
Message-ID: <1376073939.2087.146.camel@joe-AO722>
References: <1376073535-17154-1-git-send-email-neepatel@cisco.com>
	 <1376073535-17154-2-git-send-email-neepatel@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Neel Patel <neepatel@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:49850 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S968272Ab3HISpk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Aug 2013 14:45:40 -0400
In-Reply-To: <1376073535-17154-2-git-send-email-neepatel@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-08-09 at 11:38 -0700, Neel Patel wrote:
> diff --git a/drivers/net/ethernet/cisco/enic/vnic_rq.c b/drivers/net/ethernet/cisco/enic/vnic_rq.c

> @@ -30,16 +30,15 @@
>  static int vnic_rq_alloc_bufs(struct vnic_rq *rq)
[]
>  		rq->bufs[i] = kzalloc(VNIC_RQ_BUF_BLK_SZ(count), GFP_ATOMIC);
> -		if (!rq->bufs[i])
> +		if (!rq->bufs[i]) {
> +			pr_err("Failed to alloc rq_bufs\n");

Please don't add OOM messages.

A generic dump_stack() showing the location is
already done by the mm subsystem.
