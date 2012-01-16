From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [Xen-devel] [RFC PATCH 3/6] netback: switch to NAPI + kthread
 model
Date: Mon, 16 Jan 2012 10:14:33 +0000
Message-ID: <291EDFCB1E9E224A99088639C4762022B5991BEC49@LONPMAILBOX01.citrite.net>
References: <1326473949-22389-1-git-send-email-wei.liu2@citrix.com>
 <1326473949-22389-4-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Wei Liu (Intern)" <wei.liu2@citrix.com>
To: "Wei Liu (Intern)" <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:5778 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751877Ab2APKOg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2012 05:14:36 -0500
In-Reply-To: <1326473949-22389-4-git-send-email-wei.liu2@citrix.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: xen-devel-bounces@lists.xensource.com [mailto:xen-devel-
> bounces@lists.xensource.com] On Behalf Of Wei Liu
> Sent: 13 January 2012 16:59
> To: Ian Campbell; konrad.wilk@oracle.com; xen-
> devel@lists.xensource.com; netdev@vger.kernel.org
> Cc: Wei Liu (Intern)
> Subject: [Xen-devel] [RFC PATCH 3/6] netback: switch to NAPI + kthread
> model
> 
> This patch implements 1:1 model netback. We utilizes NAPI and kthread to
> do the weight-lifting job:
> 
>   - NAPI is used for guest side TX (host side RX)
>   - kthread is used for guest side RX (host side TX)
> 
> This model provides better scheduling fairness among vifs. It also lays the
> foundation for future work.
> 
> The major defect for the current implementation is that in the NAPI poll
> handler we don't actually disable interrupt. Xen stuff is different from real
> hardware, it requires some other tuning of ring macros.
> 
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
> ---
[snip]
> 
>  	struct pending_tx_info pending_tx_info[MAX_PENDING_REQS];
>  	struct gnttab_copy tx_copy_ops[MAX_PENDING_REQS]; @@ -100,42
> +91,14 @@ struct xen_netbk {
>  	struct netbk_rx_meta meta[2*XEN_NETIF_RX_RING_SIZE];  };
> 

Keeping these big inline arrays might cause scalability issues. pending_tx_info should arguably me more closely tied in and possibly implemented within your page pool code.

  Paul
